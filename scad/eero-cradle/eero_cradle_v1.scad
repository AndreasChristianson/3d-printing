// eero_cradle.scad
// Ceiling cradle for an eero Pro 6 — mounts UPSIDE DOWN, slide-in + drop-behind-beam.
//
// The eero goes in upside down: domed top + LED point DOWN into the room (visible),
// flat base up toward the ceiling. The device is widest at the base (top here) and
// narrows to the dome (bottom). Three walls (front + left + right) hang from a
// ceiling plate, each with an inward LIP at the bottom that catches the eero's
// TOP (dome) end; the dome/LED pokes through the opening. The taper self-seats it.
//
// The BACK is open for insertion + wiring. A BEAM spans the back:
//   1. Lift slightly and slide the eero in from the back, front-first.
//   2. Let the back drop past the beam — it settles onto the three lips and the
//      beam blocks it from lifting/sliding back out.
//
// Axes match eero_pro6.scad: X = side-to-side, Y = front(-Y)/back(+Y), Z = up
// (toward ceiling). z = 0 is the lip plane (room-side opening).
//
// Preview:  openscad -o eero_cradle.png --render --viewall --autocenter \
//             --imgsize=950,850 --colorscheme=Tomorrow eero_cradle.scad

use <eero_pro6.scad>
$fn = 110;

/* ---------- eero footprint (keep in sync with eero_pro6.scad) ---------- */
base_x = 139.1;   base_y = 138.9;   base_r = 34;

/* ---------- fit & structure ---------- */
clr      = 1.5;   // loose clearance around the base, per side
wall_t   = 4.0;   // wall thickness
plate_t  = 4.0;   // ceiling plate thickness
lip_w    = 7.0;   // lip reach inward (sets the dome opening; eero seats on these)
lip_t    = 3.0;   // lip thickness (vertical)
base_z   = 42;    // height of the eero base above the lip plane (seated) -- tune
roomgap  = 3.0;   // gap between the base and the plate

/* ---------- back beam ---------- */
catch    = 6.0;   // beam height above the lip plane
beam_t   = 6.0;   // beam depth (Y)

/* ---------- ceiling screws ---------- */
screw_d = 4.5;  screw_head_d = 9;  screw_inset = 14;

/* ---------- derived ---------- */
in_x  = base_x + 2*clr;    in_y  = base_y + 2*clr;    in_r  = base_r + clr;
out_x = in_x + 2*wall_t;   out_y = in_y + 2*wall_t;   out_r = in_r + wall_t;
op_x  = in_x - 2*lip_w;    op_y  = in_y - 2*lip_w;    op_r  = max(in_r - lip_w, 2);
wall_h = base_z + roomgap;            // lip plane up to the plate
y_open = in_y/2;                      // open the back beyond here

/* ---------- helpers ---------- */
module rrect(x, y, r) { offset(r = r) square([x - 2*r, y - 2*r], center = true); }
module open_back() { translate([0, y_open + 1000, 0]) cube([4000, 2000, 4000], center = true); }

/* ---------- parts ---------- */
module walls() {
    difference() {
        linear_extrude(wall_h) difference() { rrect(out_x, out_y, out_r); rrect(in_x, in_y, in_r); }
        open_back();
    }
}

module lips() {
    difference() {
        linear_extrude(lip_t)
            difference() { rrect(in_x, in_y, in_r); rrect(op_x, op_y, op_r); }
        open_back();
    }
}

module plate() {
    translate([0, 0, wall_h])
        difference() {
            linear_extrude(plate_t) rrect(out_x, out_y, out_r);
            px = out_x/2 - screw_inset;  py = out_y/2 - screw_inset;
            for (sx = [-1,1], sy = [-1,1])
                translate([sx*px, sy*py, -0.1]) {
                    cylinder(d = screw_d, h = plate_t + 0.2);
                    translate([0,0,plate_t-2.4]) cylinder(d1 = screw_d, d2 = screw_head_d, h = 2.5);
                }
        }
}

// Back beam across the open mouth, catching the eero's back as it drops past.
module beam() {
    yi = op_y/2;   // inner face aligned with the lip opening
    translate([-out_x/2, yi, 0]) cube([out_x, beam_t, catch]);
}

module cradle() { walls(); lips(); plate(); beam(); }

// eero seated upside down: base near the plate, dome poking down through the lips
module eero_seated() { translate([0, 0, base_z]) scale([1, 1, -1]) eero_pro6(); }

cradle();
// eero_seated();   // uncomment for fit check
