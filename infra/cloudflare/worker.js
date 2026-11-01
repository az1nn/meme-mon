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
    const encodings = [
      ["br", "/index.wasm.br"],
      ["gzip", "/index.wasm.gz"],
    ]
      .map(([encoding, path], priority) => [encoding, path, _quality(accepted, encoding), priority])
      .filter(([, , quality]) => quality > 0)
      .sort((left, right) => right[2] - left[2] || left[3] - right[3]);

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

function _quality(header, encoding) {
  var wildcard = -1;
  var exact = -1;
  for (const rawPart of header.split(",")) {
    const parts = rawPart.trim().toLowerCase().split(";");
    const name = parts.shift().trim();
    if (!name) continue;
    let quality = 1;
    for (const parameter of parts) {
      const [key, value] = parameter.trim().split("=", 2);
      if (key === "q") {
        const parsed = Number(value);
        quality = Number.isFinite(parsed) ? Math.max(0, Math.min(1, parsed)) : 0;
      }
    }
    if (name === encoding) exact = Math.max(exact, quality);
    if (name === "*") wildcard = Math.max(wildcard, quality);
  }
  return exact >= 0 ? exact : wildcard;
}
