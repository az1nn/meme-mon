import fs from "node:fs";
import path from "node:path";

const root = path.resolve(import.meta.dirname, "..");
const source = path.join(root, "web");
const output = path.join(root, ".vercel", "output");
const target = path.join(output, "static");

for (const name of ["index.html", "index.js", "index.wasm", "index.pck", "version.json"]) {
  if (!fs.existsSync(path.join(source, name))) throw new Error("Missing artifact: " + name);
}
fs.rmSync(output, { recursive: true, force: true });
fs.mkdirSync(target, { recursive: true });
for (const item of fs.readdirSync(source, { withFileTypes: true })) {
  if (item.name === ".assetsignore" || item.name === "_headers" || item.name.endsWith(".br") || item.name.endsWith(".gz")) continue;
  fs.cpSync(path.join(source, item.name), path.join(target, item.name), { recursive: item.isDirectory() });
}
fs.writeFileSync(path.join(output, "config.json"), JSON.stringify({
  version: 3,
  overrides: { "index.wasm": { contentType: "application/wasm" } },
}, null, 2) + "\n");
console.log("[mememom] Vercel Build Output API v3 ready, no Vercel build required");
