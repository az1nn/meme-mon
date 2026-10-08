// The Godot loader requests /index.wasm. Serve a pre-compressed representation
// without shipping a >25 MiB raw file to Cloudflare Static Assets.
const WASM_ROUTE = "/index.wasm";

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname !== WASM_ROUTE) return env.ASSETS.fetch(request);

    if (request.method !== "GET" && request.method !== "HEAD") {
      return new Response("Method Not Allowed", {
        status: 405,
        headers: { Allow: "GET, HEAD" },
      });
    }

    const accepted = request.headers.get("accept-encoding") || "";
    const encodings = [];
    if (/(^|,)\s*br(?:\s*;|\s*,|\s*$)/i.test(accepted)) {
      encodings.push(["br", "/index.wasm.br"]);
    }
    if (/(^|,)\s*gzip(?:\s*;|\s*,|\s*$)/i.test(accepted)) {
      encodings.push(["gzip", "/index.wasm.gz"]);
    }

    for (const [encoding, path] of encodings) {
      const target = new URL(path, request.url);
      const asset = await env.ASSETS.fetch(new Request(target, { method: request.method }));
      if (!asset.ok) continue;

      const headers = new Headers(asset.headers);
      headers.set("Content-Type", "application/wasm");
      headers.set("Content-Encoding", encoding);
      headers.set("Vary", "Accept-Encoding");
      headers.set("Cache-Control", "public, max-age=0, must-revalidate");
      headers.delete("Content-Length");
      return new Response(request.method === "HEAD" ? null : asset.body, {
        status: 200,
        headers,
      });
    }

    return new Response("WebAssembly compression not supported by the client", {
      status: 406,
      headers: {
        "Content-Type": "text/plain; charset=utf-8",
        "Cache-Control": "no-store",
        "Vary": "Accept-Encoding",
      },
    });
  },
};
