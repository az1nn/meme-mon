import fs from "node:fs";
import path from "node:path";

const root = path.resolve(import.meta.dirname, "..");
const web = path.join(root, "web");
const required = [
  "index.html",
  "index.js",
  "index.pck",
  "index.wasm",
  "manifest.webmanifest",
  "service-worker.js",
  "version.json",
  "icons/mememom.svg",
];

for (const filename of required) {
  const file = path.join(web, filename);
  if (!fs.existsSync(file) || fs.statSync(file).size === 0) {
    throw new Error(`Missing or empty PWA artifact: ${filename}`);
  }
}

const html = fs.readFileSync(path.join(web, "index.html"), "utf8");
for (const marker of ["manifest.webmanifest", "service-worker.js", "theme-color"]) {
  if (!html.includes(marker)) throw new Error(`index.html is missing PWA marker: ${marker}`);
}
const version = JSON.parse(fs.readFileSync(path.join(web, "version.json"), "utf8"));
if (version.schema !== "mememom-web-v1" || !/^[0-9a-f]{7,40}$/.test(version.source_commit)) {
  throw new Error("version.json has an invalid build identity");
}
const serviceWorker = fs.readFileSync(path.join(web, "service-worker.js"), "utf8");
if (serviceWorker.includes("__MEMEMOM_BUILD_VERSION__")) {
  throw new Error("service worker still contains its build-version placeholder");
}
if (!serviceWorker.includes(`const CACHE_NAME = "mememom-pwa-${version.source_commit}"`)) {
  throw new Error("service worker cache is not bound to the artifact build identity");
}
for (const shellAsset of ["./index.html", "./index.js", "./index.pck", "./index.wasm", "./manifest.webmanifest", "./version.json", "./icons/mememom.svg"]) {
  if (!serviceWorker.includes(`"${shellAsset}"`)) {
    throw new Error(`service worker shell is missing ${shellAsset}`);
  }
}
for (const marker of ["skipWaiting", "clients.claim", "caches.delete", "caches.match(\"./index.html\")"]) {
  if (!serviceWorker.includes(marker)) throw new Error(`service worker is missing ${marker}`);
}
const manifest = JSON.parse(fs.readFileSync(path.join(web, "manifest.webmanifest"), "utf8"));
if (manifest.start_url !== "./" || manifest.scope !== "./" || manifest.display !== "standalone" || !Array.isArray(manifest.icons) || manifest.icons.length === 0) {
  throw new Error("manifest does not declare an installable standalone app shell");
}
console.log("[mememom] PWA artifact PASS");
