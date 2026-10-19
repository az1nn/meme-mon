import fs from "node:fs";
import path from "node:path";

const root = path.resolve(import.meta.dirname, "..");
const dependencyDirectory = path.join(root, "node_modules");
if (fs.existsSync(dependencyDirectory)) {
  fs.writeFileSync(path.join(dependencyDirectory, ".gdignore"), "# npm dependencies are build tooling, never Godot resources.\n");
}
