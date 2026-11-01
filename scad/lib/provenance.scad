// provenance.scad
// Embossed provenance tag for functional parts: repo, the .scad's path in the
// repo, and the git commit it was rendered from, so a printed part can be
// traced back to its pattern years later.
//
// The values are filled in at render time by scad/render.sh, which passes
// them with -D. A plain `openscad -o` render gets the placeholders below,
// which makes an untagged print obvious.
//
// Use: include <../lib/provenance.scad>, then place provenance() on a flat
// face that isn't cosmetic (inside or back). The tag lies in XY, reads from
// +Z, and rises prov_depth above Z=0.

prov_repo  = "github.com/AndreasChristianson/3d-printing";
scad_path  = "unknown path (render with scad/render.sh)";
git_sha    = "nosha";
git_date   = "";

prov_size  = 3;     // cap height-ish, mm
prov_depth = 0.4;   // 2 layers at 0.2
prov_font  = "Liberation Sans:style=Bold";

module provenance(size = prov_size, depth = prov_depth, halign = "center") {
    lines = [prov_repo, scad_path, str(git_sha, git_date == "" ? "" : str("  ", git_date))];
    pitch = size * 1.6;
    linear_extrude(depth)
        for (i = [0 : len(lines) - 1])
            translate([0, (len(lines) - 1) / 2 * pitch - i * pitch])
                text(lines[i], size = size, font = prov_font,
                     halign = halign, valign = "center");
}
