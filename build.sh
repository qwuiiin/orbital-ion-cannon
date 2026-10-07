#!/usr/bin/env bash
# Packs src/ into dist/<name>_<version>.zip with the folder layout the mod portal expects.
set -euo pipefail
cd "$(dirname "$0")"
python3 - <<'PY'
import json, os, zipfile
info = json.load(open("src/info.json"))
folder = f'{info["name"]}_{info["version"]}'
os.makedirs("dist", exist_ok=True)
target = f"dist/{folder}.zip"
with zipfile.ZipFile(target, "w", zipfile.ZIP_DEFLATED) as archive:
    for root, _, files in os.walk("src"):
        for name in sorted(files):
            path = os.path.join(root, name)
            archive.write(path, os.path.join(folder, os.path.relpath(path, "src")))
    for extra in ("LICENSE", "CREDITS.md"):
        archive.write(extra, os.path.join(folder, extra))
print(target)
PY
