#!/usr/bin/env bash
# Measure a font for the metrics table in scad/lib/provenance.scad.
#
#   scad/lib/font_metrics.sh "JetBrains Mono:style=ExtraBold" [...]
#
# Prints one table row per font, every value per unit of OpenSCAD text size:
#   stroke  the thinnest stroke: the narrower of the vertical stems (I, l)
#           and the horizontal bars (-, _), each found by insetting the glyph
#           until it vanishes. Bars are usually thinner than stems, and they're
#           what E, F, Z, 2, 7 and _ are made of, so this is the stroke the
#           slicer has to fill.
#   advance horizontal advance of one character (monospace fonts only)
#   above   height above the baseline (cap / ascender top)
#   below   depth below the baseline (descenders, underscore)
set -euo pipefail

openscad=${OPENSCAD:-$(command -v openscad || echo /usr/local/bin/openscad)}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
size=10

# stroke width of glyph $2 (its thickest part): twice the largest inset that
# leaves geometry. Run on single-stroke glyphs (I, l, -, _).
stem() {
    local lo=0 hi=$size mid
    for _ in 1 2 3 4 5 6 7 8 9 10 11 12; do
        mid=$(python3 -c "print(($lo + $hi) / 2)")
        echo "offset(r = -$mid) text(\"$2\", size = $size, font = \"$1\");" > "$tmp/s.scad"
        if "$openscad" -o "$tmp/s.svg" "$tmp/s.scad" >/dev/null 2>&1; then lo=$mid; else hi=$mid; fi
    done
    python3 -c "print(2 * $lo / $size)"
}

for font in "$@"; do
    cat > "$tmp/m.scad" <<EOF
a = textmetrics("0123456789ABCDEFabcdef", size = $size, font = "$font");
m = textmetrics("HIJKLMNOPQRSTUVWXYZ_gjpqy/.-", size = $size, font = "$font");
echo(adv = a.advance.x / 22 / $size, above = (m.size.y + m.position.y) / $size, below = -m.position.y / $size);
EOF
    "$openscad" --enable=textmetrics -o "$tmp/m.echo" "$tmp/m.scad" >/dev/null 2>&1
    read -r adv above below < <(sed -nE 's/.*adv = ([0-9.e-]+), above = ([0-9.e-]+), below = ([0-9.e-]+).*/\1 \2 \3/p' "$tmp/m.echo")
    s=$(python3 -c "print(min($(stem "$font" I), $(stem "$font" l), $(stem "$font" -), $(stem "$font" _)))")
    python3 -c "print(f'    [\"$font\", {$s:.3f}, {$adv:.3f}, {$above:.3f}, {$below:.3f}],')"
done
