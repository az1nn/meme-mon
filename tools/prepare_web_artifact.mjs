import fs from "node:fs";
import path from "node:path";
import zlib from "node:zlib";
import { execFileSync } from "node:child_process";

const root = path.resolve(import.meta.dirname, "..");
const dir = path.join(root, "web");
const pwa = path.join(root, "pwa");
const read = (name) => fs.readFileSync(path.join(dir, name));
const sizeLimit = 25 * 1024 * 1024;
for (const filename of ["index.html", "index.js", "index.pck", "index.wasm"]) {
  if (!fs.existsSync(path.join(dir, filename)) || fs.statSync(path.join(dir, filename)).size === 0) {
    throw new Error("Missing/empty Godot Web export: " + filename);
  }
}

let html = read("index.html").toString("utf8");
const fileSizes = html.match(/"fileSizes"\s*:\s*(\{[^}]*\})/s);
if (!fileSizes) throw new Error("Godot index.html lacks fileSizes metadata");
const declared = JSON.parse(fileSizes[1]);
for (const name of ["index.pck", "index.wasm"]) {
  if (declared[name] !== read(name).length) {
    throw new Error(name + " mismatch (HTML=" + declared[name] + ", file=" + read(name).length + ")");
  }
}

const wasm = read("index.wasm");
const brotli = zlib.brotliCompressSync(wasm, {
  params: { [zlib.constants.BROTLI_PARAM_QUALITY]: 9 },
});
const gzip = zlib.gzipSync(wasm, { level: 9 });
for (const [name, data] of [["index.wasm.br", brotli], ["index.wasm.gz", gzip]]) {
  if (data.length > sizeLimit) {
    throw new Error(name + " exceeds Cloudflare Static Assets 25 MiB limit: " + data.length);
  }
  fs.writeFileSync(path.join(dir, name), data);
}

fs.writeFileSync(path.join(dir, ".assetsignore"), "# Workers Static Assets: use compressed representations via Worker\nindex.wasm\n");
fs.writeFileSync(path.join(dir, "_headers"), `/*
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
/index.html
  Cache-Control: no-cache
/index.js
  Cache-Control: no-cache
/index.pck
  Cache-Control: no-cache
/version.json
  Cache-Control: no-cache
`);

for (const filename of fs.readdirSync(dir)) {
  if (filename === "index.wasm") continue;
  const entry = path.join(dir, filename);
  if (fs.statSync(entry).isFile() && fs.statSync(entry).size > sizeLimit) {
    throw new Error("Cloudflare Static Assets limit exceeded: " + filename);
  }
}

const commit = execFileSync("git", ["rev-parse", "HEAD"], { cwd: root, encoding: "utf8" }).trim();
const manifest = {
  schema: "mememom-web-v1",
  source_commit: commit,
  index_wasm_raw_bytes: wasm.length,
  index_wasm_brotli_bytes: brotli.length,
  index_wasm_gzip_bytes: gzip.length,
  index_pck_bytes: read("index.pck").length,
};
fs.writeFileSync(path.join(dir, "version.json"), JSON.stringify(manifest, null, 2) + "\n");

fs.cpSync(pwa, dir, { recursive: true });
const pwaHead = `  <meta name="theme-color" content="#7c3aed">\n  <link rel="manifest" href="manifest.webmanifest">\n  <link rel="icon" href="icons/mememom.svg" type="image/svg+xml">`;
const pwaScript = `\n<script>if ("serviceWorker" in navigator) { window.addEventListener("load", () => navigator.serviceWorker.register("service-worker.js")); }</script>`;
if (!html.includes("manifest.webmanifest")) {
  if (!html.includes("</head>")) throw new Error("Godot index.html lacks a closing head tag");
  html = html.replace("</head>", `${pwaHead}\n</head>`);
}
if (!html.includes("service-worker.js")) {
  if (!html.includes("</body>")) throw new Error("Godot index.html lacks a closing body tag");
  html = html.replace("</body>", `${pwaScript}\n</body>`);
}
fs.writeFileSync(path.join(dir, "index.html"), html);
console.log("[mememom] Web artifact PASS", JSON.stringify(manifest));
