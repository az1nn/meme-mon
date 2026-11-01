import assert from "node:assert/strict";
import worker from "../infra/cloudflare/worker.js";

const calls = [];
const env = {
  ASSETS: {
    async fetch(request) {
      calls.push(request);
      const url = new URL(request.url);
      if (url.pathname === "/index.wasm.br") {
        return new Response("brotli-bytes", { status: 200, headers: { "Content-Length": "12" } });
      }
      if (url.pathname === "/index.wasm.gz") {
        return new Response("gzip-bytes", { status: 200, headers: { "Content-Length": "10" } });
      }
      return new Response("passthrough", { status: 200 });
    },
  },
};

const request = (headers = {}, method = "GET", path = "/index.wasm") => new Request(`https://mememom.test${path}`, { method, headers });

const brotli = await worker.fetch(request({ "Accept-Encoding": "br, gzip;q=0.5" }), env);
assert.equal(brotli.status, 200);
assert.equal(brotli.headers.get("Content-Encoding"), "br");
assert.equal(brotli.headers.get("Content-Type"), "application/wasm");
assert.equal(brotli.headers.get("Vary"), "Accept-Encoding");
assert.equal(brotli.headers.get("Content-Length"), null);
assert.equal(await brotli.text(), "brotli-bytes");

const gzip = await worker.fetch(request({ "Accept-Encoding": "br;q=0, gzip;q=1" }), env);
assert.equal(gzip.status, 200);
assert.equal(gzip.headers.get("Content-Encoding"), "gzip");
assert.equal(await gzip.text(), "gzip-bytes");

const wildcard = await worker.fetch(request({ "Accept-Encoding": "*" }), env);
assert.equal(wildcard.headers.get("Content-Encoding"), "br");

const notAcceptable = await worker.fetch(request({ "Accept-Encoding": "br;q=0, gzip;q=0" }), env);
assert.equal(notAcceptable.status, 406);

const head = await worker.fetch(request({ "Accept-Encoding": "gzip" }, "HEAD"), env);
assert.equal(head.status, 200);
assert.equal(head.headers.get("Content-Encoding"), "gzip");
assert.equal(await head.text(), "");

const method = await worker.fetch(request({ "Accept-Encoding": "gzip" }, "POST"), env);
assert.equal(method.status, 405);
assert.equal(method.headers.get("Allow"), "GET, HEAD");

const passthrough = await worker.fetch(request({}, "GET", "/index.html"), env);
assert.equal(passthrough.status, 200);
assert.equal(await passthrough.text(), "passthrough");
assert.ok(calls.some((entry) => new URL(entry.url).pathname === "/index.html"));

console.log("[mememom] Cloudflare Worker checks PASS");
