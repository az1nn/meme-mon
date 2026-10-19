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
console.log("[mememom] PWA artifact PASS");
