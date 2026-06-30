// eero_cradle.scad  -- v2
// Ceiling cradle for an eero Pro 6 — mounts UPSIDE DOWN, slide-in + drop-behind-beam.
// (v1 snapshot: eero_cradle_v1.scad)
//
// v2 changes:
//   - Lips and the wall bottoms are ANGLED to match the modem's wedge, so the
//     domed top seats flush/even in the opening.
//   - Rounded FRONT corners, SQUARE open BACK: full-length straight side walls
//     for support, and a back beam that stays flush within the sides.
//   - Walls OPENED UP with windows (ventilation, less filament, more visible eero).
//
// Eero goes in upside down: domed top + LED point DOWN into the room (visible),
// flat base up toward the ceiling. Three walls (front + L + R) hang from the
// ceiling plate; angled lips catch the dome end and the dome pokes through. Slide
// in from the open back, front-first; the back drops past the beam, which retains.
//
// Axes match eero_pro6.scad: X = side-to-side, Y = front(-Y)/back(+Y), Z = up.
//
// Preview:  openscad -o eero_cradle.png --render --viewall --autocenter \
//             --imgsize=950,850 --colorscheme=Tomorrow eero_cradle.scad

use <eero_pro6.scad>
$fn = 96;

/* ---------- eero footprint + wedge (keep in sync with eero_pro6.scad) ---------- */
base_x = 139.1;   base_y = 138.9;   base_r = 34;
top_y  = 132;                        // top front-to-back (tilt span)
h_front = 33.3;   h_back = 49.2;     // measured top heights (base->top), front/back middle
tilt   = atan2(h_back - h_front, top_y);   // wedge tilt: back lower, ~6.9 deg
k      = tan(tilt);

/* ---------- fit & structure ---------- */
clr     = 1.6;    // loose horizontal clearance around the base, per side
wall_t  = 4.0;
plate_t = 4.0;
lip_w   = 7.0;    // lip reach inward (dome opening; eero seats on these)
lip_t   = 3.0;
// --- vertical sizing DERIVED from the measured heights (so the eero fits) ---
roomgap     = 3.0;  // vertical clearance: eero base to plate
seat_clr    = 1.0;  // lip plane sits this far below the eero's top edge
back_margin = 2.0;  // keep the lowest (back) lip above z=0
base_z = h_back + seat_clr + back_margin;              // eero base height above z=0
lip0   = base_z - ((h_front + h_back)/2 + seat_clr);   // lip plane height at y=0

/* ---------- back beam ---------- */
catch  = 6.0;     // beam height above the lip plane
beam_t = 6.0;     // beam depth (Y)

/* ---------- wall windows ---------- */
win_border = 13;  // solid frame left around each window

/* ---------- ceiling screws ---------- */
screw_d = 4.5;  screw_head_d = 9;  screw_inset = 14;

/* ---------- derived ---------- */
in_x  = base_x + 2*clr;    in_y  = base_y + 2*clr;    in_r  = base_r + clr;
out_x = in_x + 2*wall_t;   out_y = in_y + 2*wall_t;   out_r = in_r + wall_t;
op_x  = in_x - 2*lip_w;    op_y  = in_y - 2*lip_w;    op_r  = max(in_r - lip_w, 2);
Ht    = base_z + roomgap;          // top of walls (plate bottom)
y_open = in_y/2;
shear = [[1,0,0,0],[0,1,0,0],[0,-k,1,0],[0,0,0,1]];   // tilts horizontal -> wedge plane

/* ---------- helpers ---------- */
// rounded FRONT (-Y) corners, SQUARE back (+Y)
module rfront(x, y, r) {
    hull() {
        translate([-(x/2 - r), -(y/2 - r)]) circle(r);
        translate([ (x/2 - r), -(y/2 - r)]) circle(r);
        translate([-x/2,  y/2]) circle(0.001);
        translate([ x/2,  y/2]) circle(0.001);
    }
}
module open_back()  { translate([0, y_open + 1000, 0]) cube([4000, 2000, 4000], center = true); }
module below_tilt(z0) { multmatrix(shear) translate([0,0,z0-1000]) cube([6000,6000,2000], center = true); }

// windows pierced through the three walls (above the lips, inset by win_border)
module windows() {
    z0 = lip0 + win_border;  z1 = Ht - win_border;  zc = (z0+z1)/2;  zh = z1 - z0;
    // left & right (pierce X), around the straight side region
    wy = (base_y - base_r*2) ;                 // straight side length
    translate([0, 0, zc]) cube([4000, wy - win_border, zh], center = true);
    // front (pierce Y)
    wx = (base_x - base_r*2);
    translate([0, -out_y/2, zc]) cube([wx - win_border, 4000, zh], center = true);
}

/* ---------- parts ---------- */
module walls() {
    difference() {
        linear_extrude(Ht) difference() { rfront(out_x, out_y, out_r); rfront(in_x, in_y, in_r); }
        open_back();
        below_tilt(lip0);
        windows();
    }
}

module lips() {
    difference() {
        // span op..OUT and extrude up past lip0 so the lip merges solidly with
        // the walls (avoids a coincident-face split into a separate volume)
        multmatrix(shear)
            translate([0, 0, lip0 - lip_t]) linear_extrude(lip_t + 1.5)
                difference() { rfront(out_x, out_y, out_r); rfront(op_x, op_y, op_r); }
        open_back();
    }
}

module plate() {
    pt = plate_t + 1;            // overlap 1 mm into the walls (avoid coincident face)
    translate([0, 0, Ht - 1])
        difference() {
            linear_extrude(pt) rfront(out_x, out_y, out_r);
            px = out_x/2 - screw_inset;  py = out_y/2 - screw_inset;
            for (sx = [-1,1], sy = [-1,1])
                translate([sx*px, sy*py, -0.1]) {
                    cylinder(d = screw_d, h = pt + 0.2);
                    translate([0,0,pt-2.4]) cylinder(d1 = screw_d, d2 = screw_head_d, h = 2.5);
                }
        }
}

// Back beam across the square mouth (flush within the side walls), sitting just
// above the (angled) lip plane at the back. The eero's back drops past it.
module beam() {
    yi = op_y/2;
    z_at_back = lip0 - k*yi;                 // lip-plane height at the beam
    translate([-out_x/2, yi, z_at_back]) cube([out_x, beam_t, catch]);
}

module cradle() { walls(); lips(); plate(); beam(); }

// eero seated upside down (base near plate, dome through the angled lips)
module eero_seated() { translate([0, 0, base_z]) scale([1, 1, -1]) eero_pro6(); }

cradle();
// eero_seated();
