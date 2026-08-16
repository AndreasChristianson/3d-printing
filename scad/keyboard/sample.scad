// sample.scad — single-switch fit-test coupon (no layout needed).
//   openscad -o sample.stl sample.scad
// Same plate_t / clip_lip / body_clear as the real plate — print to check fit.
// `include` (not `use`) so the lib's parameters are visible to sample() below.
include <keyboard_lib.scad>

// one stepped cutout in a small handleable square
module sample() {
    s = U + 12;   // coupon side (~31 mm)
    color("SteelBlue")
    difference() {
        linear_extrude(plate_t)
            offset(r = corner_r) square([s - 2*corner_r, s - 2*corner_r], center = true);
        key_hole_3d(1.0, false);
    }
}

sample();
