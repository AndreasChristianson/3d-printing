// keycaps.scad — the full set of caps, one per key, with engraved legends,
// placed at each key's grid position (a whole board of caps).
//   openscad -o keycaps.stl keycaps.scad
// Arrange/duplicate in your slicer to print. Print top-face DOWN.
// Per-key behavior (flat top, no legend, homing bar) comes from each key's
// options list in keyboard_layout.scad — nothing is hardcoded here.
include <keyboard_layout.scad>   // keys = [ x, y, w, stab, "label", "shift", [opts] ]
include <keycap_lib.scad>

// grid placement from the key's top-left corner (y increases downward)
function cap_cx(k) = (k[0] + k[2]/2) * U;
function cap_cy(k) = -(k[1] + 0.5) * U;

// key-record accessors (shift + options are optional trailing fields)
function k_shift(k) = len(k) > 5 ? k[5] : "";
function k_opts(k)  = len(k) > 6 ? k[6] : [];
function has_opt(k, name) = len([for (o = k_opts(k)) if (o == name) 1]) > 0;

for (k = keys) {
    nolabel = has_opt(k, "nolabel");
    translate([cap_cx(k), cap_cy(k), 0])
        keycap(k[2], k[3],
               nolabel ? "" : k[4],
               nolabel ? "" : k_shift(k),
               flat   = has_opt(k, "flat"),
               homing = has_opt(k, "homing"));
}
