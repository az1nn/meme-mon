import fs from "node:fs";
import path from "node:path";

const root = path.resolve(import.meta.dirname, "..");
const web = path.join(root, "web");
const android = path.join(root, "android", "app", "src", "main", "assets", "public");
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
  const webPath = path.join(web, filename);
  const androidPath = path.join(android, filename);
  if (!fs.existsSync(webPath) || !fs.existsSync(androidPath)) {
    throw new Error(`Missing synced Android artifact: ${filename}`);
  }
  if (!fs.readFileSync(webPath).equals(fs.readFileSync(androidPath))) {
    throw new Error(`Android artifact differs from verified Web artifact: ${filename}`);
  }
}

const version = JSON.parse(fs.readFileSync(path.join(android, "version.json"), "utf8"));
const serviceWorker = fs.readFileSync(path.join(android, "service-worker.js"), "utf8");
if (!serviceWorker.includes(`const CACHE_NAME = "mememom-pwa-${version.source_commit}"`)) {
  throw new Error("Android service worker cache is not bound to the synced artifact identity");
}
console.log(`[mememom] Android artifact PASS ${version.source_commit}`);
