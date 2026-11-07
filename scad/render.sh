#!/usr/bin/env bash
# Render a .scad with its provenance tag filled in (see scad/lib/provenance.scad).
#
#   scad/render.sh path/to/part.scad [out.stl] [extra openscad args...]
#
# The tag gets the file's repo-relative path and HEAD's short SHA. Commit
# first: a file with uncommitted changes gets a "+" on its SHA.
#
# A part that uses with_provenance() renders as two STLs, the body (out.stl)
# and the tag (out.tag.stl), so the tag can print in a second filament: load
# both in Orca at once and accept "load as a single object with multiple
# parts".
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
if ! git diff --quiet HEAD -- "$src" "$top/scad/lib" 2>/dev/null \
    || [ -z "$(git ls-files "$src")" ]; then
    sha="$sha+"
fi

echo "tag: $path @ $sha"
tag=(-D "scad_path=\"$path\"" -D "git_sha=\"$sha\"")
if grep -q "with_provenance" "$src"; then
    "$openscad" -o "$out" "${tag[@]}" -D 'prov_part="body"' "$@" "$src"
    # a part of the file may carry no tag (e.g. a lid when the base has it):
    # then there's no tag STL, and any stale one goes
    rm -f "${out%.stl}.tag.stl"
    if ! log=$("$openscad" -o "${out%.stl}.tag.stl" "${tag[@]}" -D 'prov_part="tag"' "$@" "$src" 2>&1); then
        if grep -q "top level object is empty" <<<"$log" && ! grep -q "ERROR" <<<"$log"; then
            echo "no tag in this part"
        else
            echo "$log" >&2
            exit 1
        fi
    fi
else
    "$openscad" -o "$out" "${tag[@]}" "$@" "$src"
fi
