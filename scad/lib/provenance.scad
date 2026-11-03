// provenance.scad
// Provenance tag for functional parts: the .scad file and the git commit it
// was rendered from, so a printed part can be traced back to its pattern
// years later. When there's room, the tag also gets the repo-relative path
// and then the repo.
//
// The values are filled in at render time by scad/render.sh, which passes
// them with -D. A plain `openscad -o` render gets the placeholders below,
// which makes an untagged print obvious.
//
// Use:
//   include <../lib/provenance.scad>
//   with_provenance() {
//       part();                                   // the body
//       translate(...) provenance(w = 90, h = 16);  // the placed tag
//   }
// provenance() fills a w x h area centred on the origin. The text lies in
// XY and reads from +Z; the face it sits on is Z=0. The tag is its own
// part so it can print in a second filament: render.sh writes the body and
// the tag as two STLs (load both in Orca as one multi-part object). Give
// both parts the same filament to skip the swaps.
//
// Modes:
//   emboss - raised prov_depth above the face, on a face that prints facing
//            up (the default)
//   inlay  - flush, prov_depth into the face, for a face that prints DOWN on
//            the bed. Crispest text (it's the first layers); each text layer
//            costs a filament change.
//
// Legibility comes from the stroke width: a stem has to be about two
// extrusion lines wide (prov_min_stroke) or it prints as one wiggly bead.
// The tag is file + SHA, and stops the render if that can't reach
// prov_min_stroke in the given area. The path, and then the repo, are added
// only if the text still reaches prov_extra_stroke with them, so they never
// shrink the essentials to the bare minimum.

prov_repo  = "github.com/AndreasChristianson/3d-printing";
scad_path  = "untagged.scad";   // set by render.sh
git_sha    = "nosha";           // set by render.sh; a trailing + means dirty

prov_part  = "all";     // "all" (preview) | "body" | "tag", set by render.sh
prov_mode  = "emboss";  // "emboss" | "inlay"
prov_depth = 0.6;       // 3 layers at 0.2; use 0.8 for light text on a dark part
prov_font  = "JetBrains Mono:style=ExtraBold";
prov_min_stroke  = 0.9; // ~2 lines of a 0.4 nozzle
prov_extra_stroke = 1.2; // the path and repo only go on at this stroke or more
prov_max_stroke  = 1.5; // caps the size in a big area
prov_upper       = "auto";  // true | false | "auto": caps when the stroke is
prov_upper_below = 1.2;     //   thinner than this; the SHA is always caps
prov_lead  = 0.25;      // gap between lines, per unit of text size

// Monospace fonts only (the fit assumes a fixed advance). Per unit of
// OpenSCAD text size: [font, stem, advance, above baseline, below baseline].
// Add a font with scad/lib/font_metrics.sh.
prov_fonts = [
    ["JetBrains Mono:style=ExtraBold", 0.249, 0.833, 1.153, 0.250],
    ["JetBrains Mono:style=Bold", 0.208, 0.833, 1.153, 0.250],
    ["Overpass Mono:style=Bold", 0.203, 0.856, 0.999, 0.298],
    ["Atkinson Hyperlegible Mono:style=ExtraBold", 0.252, 0.878, 1.064, 0.285],
    ["Atkinson Hyperlegible Mono:style=Bold", 0.215, 0.878, 1.043, 0.279],
    ["Liberation Mono:style=Bold", 0.211, 0.833, 1.007, 0.294],
];

function prov_metrics(font) =
    let (rows = [for (r = prov_fonts) if (r[0] == font) r])
    assert(len(rows) > 0, str("provenance: no metrics for font \"", font,
                              "\"; measure it with scad/lib/font_metrics.sh"))
    rows[0];

function prov_upcase(s) = chr([for (c = s) let (o = ord(c)) o >= 97 && o <= 122 ? o - 32 : o]);

function prov_basename(p) =
    let (slashes = search("/", p, 0)[0])
    len(slashes) == 0 ? p : chr([for (i = [max(slashes) + 1 : len(p) - 1]) ord(p[i])]);

// Text size that fits lines in w x h, capped at prov_max_stroke.
function prov_fit(lines, w, h, m) =
    let (n = len(lines),
         longest = max([for (l = lines) len(l)]),
         line_h = m[3] + m[4])
    min(w / (longest * m[2]),
        h / (line_h + (n - 1) * (line_h + prov_lead)),
        prov_max_stroke / m[1]);

// The richest layout whose stroke is enough for its fields: [lines, size],
// or undef. Each field set is tried stacked and on one line.
function prov_layout(w, h, m) =
    let (sha  = prov_upcase(git_sha),
         sets = [[prov_repo, scad_path, sha], [scad_path, sha], [prov_basename(scad_path), sha]],
         fits = [for (f = sets)
                     let (one = [len(f) == 2 ? str(f[0], " ", f[1]) : str(f[0], " ", f[1], " ", f[2])],
                          s_stack = prov_fit(f, w, h, m),
                          s_one   = prov_fit(one, w, h, m))
                     s_stack >= s_one ? [f, s_stack] : [one, s_one]],
         need = [prov_extra_stroke, prov_extra_stroke, prov_min_stroke],
         ok = [for (i = [0 : len(fits) - 1]) if (fits[i][1] * m[1] >= need[i]) fits[i]])
    len(ok) > 0 ? ok[0] : undef;

module provenance(w, h, mode = prov_mode, depth = prov_depth, font = prov_font,
                  halign = "center") {
    m = prov_metrics(font);
    layout = let (l = prov_layout(w, h, m))
        assert(!is_undef(l),
               str("provenance: ", w, " x ", h, " mm is too small for \"",
                   prov_basename(scad_path), " ", prov_upcase(git_sha), "\" at a ",
                   prov_min_stroke, " mm stroke in ", font))
        l;
    lines = layout[0];
    size  = layout[1];
    stroke = size * m[1];
    upper = prov_upper == "auto" ? stroke < prov_upper_below : prov_upper;
    pitch = (m[3] + m[4] + prov_lead) * size;
    echo(str("provenance: ", lines, " size ", size, " stroke ", stroke, upper ? " caps" : ""));
    // emboss sinks 0.01 into the face so it touches the body
    translate([0, 0, mode == "inlay" ? -depth : -0.01])
        linear_extrude(depth + (mode == "inlay" ? 0 : 0.01))
            for (i = [0 : len(lines) - 1])
                // centre each line on its cap/descender box, not the baseline
                translate([0, (len(lines) - 1) / 2 * pitch - i * pitch - (m[3] - m[4]) / 2 * size])
                    text(upper ? prov_upcase(lines[i]) : lines[i], size = size, font = font,
                         halign = halign, valign = "baseline");
}

// children(0): the part; children(1): its placed provenance() tag. The body
// is cut by the tag (a flush pocket for an inlay), so the two never overlap.
module with_provenance() {
    if (prov_part != "tag") difference() { children(0); children(1); }
    if (prov_part != "body") color("white") children(1);
}
