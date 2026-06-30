// eero_pro6.scad
// Reference model of the eero Pro 6, built from measured dimensions.
// This is the GROUND TRUTH the mount will be designed around.
//
// FORM: the top is the base outline projected upward — same rounded corners —
// scaled in slightly (taper), sitting on a plane that tilts up toward the back
// and bulges with a slight dome.
//
// Axes: X = side-to-side, Y = front(-Y) / back(+Y), Z = up. Base sits on z=0.
// Wiring (power + ethernet) exits the BACK (+Y).
//
// Preview:  openscad -o eero_pro6.png --render --viewall --autocenter \
//             --imgsize=950,850 --colorscheme=Tomorrow eero_pro6.scad

$fn = 160;

/* ---------- Measured dimensions ---------- */
// Base (flat, rounded corners)
base_x = 139.1;   // side-to-side
base_y = 138.9;   // front-to-back
base_r = 34;      // corner radius (from 168.3 mm / 6-5/8" corner-to-corner)

// Base bevel (chamfer around the bottom edge)
bevel_h     = 2.5;
bevel_inset = 2.0;

// Top: same rounded corners as the base, projected up and scaled in (taper)
top_x = 135;      // side-to-side
top_y = 132;      // front-to-back

// Top-surface heights (base to top) used to set the tilt and dome
h_front_mid = 33.3;
h_back_mid  = 49.2;
h_side_mid  = 42.3;   // for reference
dome_crown  = 2.5;    // gentle center bulge above the tilted plane

/* ---------- Derived ---------- */
tilt_deg = atan2(h_back_mid - h_front_mid, top_y);   // front-low / back-high tilt
top_z    = (h_front_mid + h_back_mid) / 2;           // height of the tilt axis (y=0)

/* ---------- Helpers ---------- */
module rrect(x, y, r) { offset(r = r) square([x - 2*r, y - 2*r], center = true); }

// Top cap: the top rounded-rect with a slight central dome, same corner radius.
module top_cap() {
    hull() {
        linear_extrude(0.1) rrect(top_x, top_y, base_r);
        translate([0, 0, dome_crown])
            linear_extrude(0.1) rrect(top_x*0.55, top_y*0.55, base_r*0.55);
    }
}

/* ---------- Model ---------- */
module eero_pro6() {
    hull() {
        // beveled flat base
        linear_extrude(0.1)
            rrect(base_x - 2*bevel_inset, base_y - 2*bevel_inset, base_r - bevel_inset);
        translate([0, 0, bevel_h]) linear_extrude(0.1) rrect(base_x, base_y, base_r);

        // same-cornered top, scaled in, tilted up toward the back, slightly domed
        translate([0, 0, top_z]) rotate([tilt_deg, 0, 0]) top_cap();
    }
}

eero_pro6();
