#!/usr/bin/env bash
# Renders the real game's screens (native test harness, same grid code as the wasm build) to
# assets/screenshots/*.png at 3x.
set -euo pipefail
cd "$(dirname "$0")/.."
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
"${ODIN:-odin}" test odin -define:ODIN_TEST_THREADS=1 -define:DUMP_DIR="$tmp" -define:ODIN_TEST_NAMES=handies.dump_screens >/dev/null 2>&1
mkdir -p assets/screenshots
for f in "$tmp"/*.cells; do
	python3 tools/render_cells.py "$f" "assets/screenshots/$(basename "$f" .cells).png" 3
done
