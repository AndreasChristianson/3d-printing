#!/usr/bin/env bash
#
# Slice a model with OrcaSlicer CLI and optionally upload to Moonraker.
#
# Usage:
#   ./slice.sh <model.stl|model.3mf> [--upload]
#
# Configs are picked up from configs/{machine,filament,process}/ — set the
# defaults below to the filenames you want to use, or override via env vars:
#   MACHINE=kobra-max-klipper.json FILAMENT=pla-generic.json PROCESS=0.2mm-standard.json ./slice.sh foo.stl
#
# Requires:
#   - OrcaSlicer installed at /Applications/OrcaSlicer.app (macOS)
#   - curl (for --upload)

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCA_BIN="${ORCA_BIN:-/Applications/OrcaSlicer.app/Contents/MacOS/OrcaSlicer}"
MOONRAKER_URL="${MOONRAKER_URL:-http://klipper2}"

# Default profile filenames — edit these once your configs exist.
MACHINE="${MACHINE:-kobra-max-klipper.json}"
FILAMENT="${FILAMENT:-Generic pla.json}"
PROCESS="${PROCESS:-0.20mm Standard kobra max.json}"

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <model.stl|model.3mf> [--upload]" >&2
  exit 1
fi

MODEL="$1"
shift
UPLOAD=0
for arg in "$@"; do
  case "$arg" in
    --upload) UPLOAD=1 ;;
    *) echo "unknown arg: $arg" >&2; exit 1 ;;
  esac
done

if [[ ! -f "$MODEL" ]]; then
  echo "model not found: $MODEL" >&2
  exit 1
fi

if [[ ! -x "$ORCA_BIN" ]]; then
  echo "OrcaSlicer binary not found at: $ORCA_BIN" >&2
  echo "Install OrcaSlicer or set ORCA_BIN to its CLI path. See README.md." >&2
  exit 1
fi

MACHINE_PATH="$REPO_DIR/configs/machine/$MACHINE"
FILAMENT_PATH="$REPO_DIR/configs/filament/$FILAMENT"
PROCESS_PATH="$REPO_DIR/configs/process/$PROCESS"
for p in "$MACHINE_PATH" "$FILAMENT_PATH" "$PROCESS_PATH"; do
  if [[ ! -f "$p" ]]; then
    echo "missing profile: $p" >&2
    echo "Export profiles from OrcaSlicer GUI (see README.md) and drop them here." >&2
    exit 1
  fi
done

mkdir -p "$REPO_DIR/output"

"$ORCA_BIN" \
  --load-settings "$MACHINE_PATH;$PROCESS_PATH" \
  --load-filaments "$FILAMENT_PATH" \
  --slice 0 \
  --outputdir "$REPO_DIR/output" \
  "$MODEL"

# OrcaSlicer names the output after the input model.
MODEL_BASE="$(basename "${MODEL%.*}")"
GCODE_PATH="$(ls -t "$REPO_DIR/output/${MODEL_BASE}"*.gcode 2>/dev/null | head -n1 || true)"

if [[ -z "$GCODE_PATH" ]]; then
  echo "slice succeeded but no .gcode found in output/ — check OrcaSlicer output above." >&2
  exit 1
fi
echo "sliced: $GCODE_PATH"

if [[ "$UPLOAD" -eq 1 ]]; then
  echo "uploading to $MOONRAKER_URL ..."
  curl -fsS -F "file=@$GCODE_PATH" "$MOONRAKER_URL/server/files/upload" \
    && echo " uploaded."
fi
