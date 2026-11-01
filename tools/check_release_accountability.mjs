import fs from "node:fs";
import path from "node:path";

const root = path.resolve(import.meta.dirname, "..");
const read = (filename) => fs.readFileSync(path.join(root, filename), "utf8");
const requiredFiles = [
  "LICENSE",
  "CONTRIBUTING.md",
  "CODE_OF_CONDUCT.md",
  "SECURITY.md",
  "docs/policies/closed-beta-operating-policy.md",
  "docs/policies/content-provenance-policy.md",
  "docs/policies/first-party-assets-policy.md",
  "docs/release/V1-release-accountability-checklist.md",
];

for (const filename of requiredFiles) {
  if (!fs.existsSync(path.join(root, filename))) throw new Error(`Missing accountability artifact: ${filename}`);
}

const license = read("LICENSE");
if (!license.startsWith("MIT License")) throw new Error("Code license is not explicitly MIT");
const contributing = read("CONTRIBUTING.md");
if (!contributing.includes("DCO") || !contributing.includes("MIT")) throw new Error("Contribution/code-license boundary is incomplete");
const assets = read("docs/policies/first-party-assets-policy.md");
if (!assets.includes("no-redistribution") || !assets.includes("not a public asset license")) {
  throw new Error("Closed-beta first-party asset restriction is not explicit");
}
const checklist = read("docs/release/V1-release-accountability-checklist.md");
if (!checklist.includes("- [x] O release permanece beta fechado enquanto os gates públicos permanecerem pendentes.")) {
  throw new Error("Release checklist must explicitly keep public release closed");
}

const externalGates = [
  "browser/PWA install-update-touch acceptance",
  "signed Android install/device smoke",
  "human accessibility/visual/original-brand review",
  "provider deployment and live response verification",
  "operator/public-content and asset-license decisions",
];
console.log("[mememom] Closed-beta release accountability PASS");
console.log("[mememom] External gates remain: " + externalGates.join("; "));
