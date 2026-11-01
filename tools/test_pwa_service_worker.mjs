import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import vm from "node:vm";

const root = path.resolve(import.meta.dirname, "..");
const source = fs.readFileSync(path.join(root, "pwa", "service-worker.js"), "utf8").replaceAll("__MEMEMOM_BUILD_VERSION__", "test-build");
const listeners = new Map();
const cacheEntries = new Map();
const deletedCaches = [];
const cached = new Response("cached-index", { status: 200 });
const cachesApi = {
  async open(name) {
    assert.equal(name, "mememom-pwa-test-build");
    return {
      async addAll(assets) {
        for (const asset of assets) cacheEntries.set(asset, new Response(`asset:${asset}`, { status: 200 }));
      },
    };
  },
  async keys() {
    return ["mememom-pwa-test-build", "mememom-pwa-old"];
  },
  async delete(name) {
    deletedCaches.push(name);
    return true;
  },
  async match(request) {
    const key = typeof request === "string" ? request : new URL(request.url).pathname.endsWith("/index.html") || new URL(request.url).pathname === "/" ? "./index.html" : request.url;
    return key === "./index.html" ? cached : cacheEntries.get(key) || null;
  },
};
let networkMode = "online";
const context = {
  URL,
  Request,
  Response,
  caches: cachesApi,
  fetch: async () => {
    if (networkMode === "offline") throw new Error("offline");
    return new Response("network", { status: 200 });
  },
  self: {
    location: { origin: "https://app.test" },
    clients: { claim: async () => {} },
    skipWaiting: () => {},
    addEventListener(type, handler) { listeners.set(type, handler); },
  },
};
vm.runInNewContext(source, context, { filename: "pwa/service-worker.js" });

const installWaits = [];
listeners.get("install")({ waitUntil(promise) { installWaits.push(promise); } });
await Promise.all(installWaits);
assert.ok(cacheEntries.has("./index.html"));
assert.ok(cacheEntries.has("./version.json"));

const activateWaits = [];
listeners.get("activate")({ waitUntil(promise) { activateWaits.push(promise); } });
await Promise.all(activateWaits);
assert.deepEqual(deletedCaches, ["mememom-pwa-old"]);

networkMode = "offline";
let navigationResponse;
listeners.get("fetch")({
  request: { method: "GET", mode: "navigate", url: "https://app.test/" },
  respondWith(promise) { navigationResponse = promise; },
});
assert.equal((await navigationResponse).status, 200);
assert.equal(await (await navigationResponse).text(), "cached-index");

let staticResponse;
listeners.get("fetch")({
  request: { method: "GET", mode: "cors", url: "https://app.test/index.html" },
  respondWith(promise) { staticResponse = promise; },
});
assert.equal((await staticResponse).status, 200);

let ignored = false;
listeners.get("fetch")({
  request: { method: "POST", mode: "cors", url: "https://app.test/index.html" },
  respondWith() { ignored = true; },
});
assert.equal(ignored, false);

console.log("[mememom] PWA service-worker checks PASS");
