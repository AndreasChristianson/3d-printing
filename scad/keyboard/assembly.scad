// assembly.scad — case + plate together (plate lifted onto its ledge).
// A visual check of how the parts stack; render each part separately to print.
// `include` (not `use`) so floor_t / inner_h are visible for the plate lift.
include <keyboard_layout.scad>
include <keyboard_lib.scad>

case(supports);
translate([0, 0, floor_t + inner_h]) plate(keys, encoders, supports);
