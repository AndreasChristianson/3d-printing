#!/usr/bin/env bash
# Render a .scad with its provenance tag filled in (see scad/lib/provenance.scad).
#
#   scad/render.sh path/to/part.scad [out.stl] [extra openscad args...]
#
# The tag gets the file's repo-relative path and HEAD's short SHA and commit
# date. Commit first: a file with uncommitted changes gets "-dirty" on its SHA.
set -euo pipefail

src=$1
shift
out=${1:-${src%.scad}.stl}
[ $# -gt 0 ] && shift
out="$(cd "$(dirname "$out")" && pwd)/$(basename "$out")"

openscad=${OPENSCAD:-$(command -v openscad || echo /usr/local/bin/openscad)}
cd "$(dirname "$src")"
src=$(basename "$src")
top=$(git rev-parse --show-toplevel)
path=$(git ls-files --full-name --error-unmatch "$src" 2>/dev/null \
    || echo "$(git rev-parse --show-prefix)$src")
sha=$(git rev-parse --short HEAD)
date=$(git log -1 --format=%cs HEAD)
if ! git diff --quiet HEAD -- "$src" "$top/scad/lib" 2>/dev/null \
    || [ -z "$(git ls-files "$src")" ]; then
    sha="$sha-dirty"
fi

echo "tag: $path @ $sha $date"
"$openscad" -o "$out" \
    -D "scad_path=\"$path\"" \
    -D "git_sha=\"$sha\"" \
    -D "git_date=\"$date\"" \
    "$@" "$src"
