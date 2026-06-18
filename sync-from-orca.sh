#!/usr/bin/env bash
#
# Copy OrcaSlicer user profiles from its app-support dir into configs/.
# Run this after editing profiles in the OrcaSlicer GUI to stage them for git.
#
# Usage:
#   ./sync-from-orca.sh           # copy and show what changed (git diff)
#   ./sync-from-orca.sh --quiet   # copy, no diff output
#
# Only .json files are copied; OrcaSlicer's .info sidecars are skipped.
# Existing files in configs/ are overwritten — review with `git diff` before committing.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCA_USER_DIR="${ORCA_USER_DIR:-$HOME/Library/Application Support/OrcaSlicer/user/default}"

QUIET=0
[[ "${1:-}" == "--quiet" ]] && QUIET=1

if [[ ! -d "$ORCA_USER_DIR" ]]; then
  echo "OrcaSlicer user dir not found: $ORCA_USER_DIR" >&2
  echo "Set ORCA_USER_DIR if your install lives elsewhere." >&2
  exit 1
fi

copied=0
for kind in machine filament process; do
  src_dir="$ORCA_USER_DIR/$kind"
  dst_dir="$REPO_DIR/configs/$kind"
  mkdir -p "$dst_dir"

  if [[ ! -d "$src_dir" ]]; then
    echo "skip: no $kind profiles in OrcaSlicer user dir"
    continue
  fi

  shopt -s nullglob
  for src in "$src_dir"/*.json; do
    name="$(basename "$src")"
    cp "$src" "$dst_dir/$name"
    echo "copied: $kind/$name"
    copied=$((copied + 1))
  done
  shopt -u nullglob
done

if [[ "$copied" -eq 0 ]]; then
  echo "no profiles found to copy." >&2
  exit 1
fi

if [[ "$QUIET" -eq 0 ]] && command -v git >/dev/null 2>&1 && [[ -d "$REPO_DIR/.git" ]]; then
  echo
  echo "--- changes in configs/ ---"
  git -C "$REPO_DIR" diff --stat -- configs/ || true
fi
