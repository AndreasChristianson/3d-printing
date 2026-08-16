// preview.scad — flat layout review with legends (NOT for printing).
//   openscad -o preview.png --render --viewall --autocenter --imgsize=1600,780 \
//     --colorscheme=Tomorrow --camera=0,0,600,0,0,0,0 --projection=ortho preview.scad
// `include` (not `use`) so the lib's parameters + accessors are visible to the
// review-only geometry defined here.
include <keyboard_layout.scad>
include <keyboard_lib.scad>

// label accessors (only the review render needs legends)
function kl(k) = k[4];   // key label   ([x,y,w,stab,"label"])
function el(e) = e[3];   // encoder label ([x,y,w,"label"])

// 2D top opening (retention lip footprint + stab pockets) for the flat review
module key_cut_2d(w, stab) {
    square([cutout, cutout], center = true);
    if (clip_notches)
        for (sx = [-1, 1])
            translate([sx * cutout/2, 0]) square([1.0, cutout - 6], center = true);
    span = stab_span(w);
    if (stab && span > 0)
        for (sx = [-1, 1])
            translate([sx * span/2, -0.75]) square([7.0, 15.0], center = true);
}

module cutouts_2d() {
    for (k = keys)
        translate([key_cx(k), key_cy(k)]) key_cut_2d(kw(k), ks(k));
    for (e = encoders)
        translate([key_cx(e), key_cy(e)]) circle(d = enc_hole_d);
}

// keycap outlines + legends
module labels_2d() {
    for (k = keys)
        translate([key_cx(k), key_cy(k)]) {
            difference() {
                square([kw(k)*U - 1, U - 1], center = true);
                square([kw(k)*U - 3, U - 3], center = true);
            }
            text(kl(k), size = 3.2, halign = "center", valign = "center", $fn = 16);
        }
    for (e = encoders)
        translate([key_cx(e), key_cy(e)]) {
            difference() { circle(d = U - 1, $fn = 40); circle(d = U - 3, $fn = 40); }
            circle(d = enc_hole_d, $fn = 32);            // shaft hole marker
            text(el(e), size = 2.6, halign = "center", valign = "center", $fn = 16);
        }
}

module layout_view() {
    color("SteelBlue") linear_extrude(1) difference() { plate_blank_2d(); cutouts_2d(); }
    color("black")     translate([0,0,1]) linear_extrude(0.6) labels_2d();
}

layout_view();
