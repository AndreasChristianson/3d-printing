// eero_cradle.scad  -- v5
// v5: +15mm clearance; lip is a thick 45-deg ramp (self-supporting) sitting flush on the
//     lip plane; honeycomb rotated pointy-top on all walls; lip/bead cleared from the open
//     back; beam moved flush to the back over the lip; central material-saving opening in
//     the plate; output rotated 180 (plate-down) for printing.
// v4: honeycomb perforations (pointy-top, self-supporting) replacing the big windows;
//     countersink moved to the interior side. Full back bar kept (support it in the slicer).
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
lip_w   = 12.0;   // lip reach inward (dome opening; eero seats on these)
lip_t   = lip_w + 2;   // thick enough that the 45-deg eero-rest ramp leaves solid material
// --- vertical sizing DERIVED from the measured heights (so the eero fits) ---
roomgap     = 18.0; // vertical clearance: base to plate (+15 so the domed top clears on insertion)
seat_clr    = 1.0;  // lip plane sits this far below the eero's top edge
back_margin = 2.0;  // keep the lowest (back) lip above z=0
base_z = h_back + seat_clr + back_margin;              // eero base height above z=0
lip0   = base_z - ((h_front + h_back)/2 + seat_clr);   // lip plane height at y=0

/* ---------- back beam ---------- */
catch  = 6.0;     // beam height above the lip plane
beam_t = 6.0;     // beam depth (Y)

/* ---------- wall windows ---------- */
win_border = 8;   // solid frame band kept above the lips and below the plate
hex_af     = 10;  // honeycomb opening (across flats)
hex_wall   = 3;   // material between openings

/* ---------- ceiling screws ---------- */
screw_d = 4.5;  screw_head_d = 9;  screw_inset = 14;
drv_clear = 16;   // front screws: clearance from screw center to wall (straight driver)
chamfer  = 1.2;   // uniform chamfer on the outer bottom edge

/* ---------- central material-saving opening in the plate ---------- */
open_x  = 86;   open_y = 96;   open_r = 18;   open_yc = 6;   // shifted back toward the deeper back screws

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
// clears all lip/bead from the back region (none of it is needed around the open
// back); the side runs end cleanly at op_y/2, well forward of the opening
module back_strip()  { translate([0, op_y/2 + 2000, 0]) cube([4000, 4000, 4000], center = true); }
module below_tilt(z0) { multmatrix(shear) translate([0,0,z0-1000]) cube([6000,6000,2000], center = true); }

// windows pierced through the three walls (above the lips, inset by win_border)
// pointy-top hexagon (vertex up/down -> self-supporting, no flat overhang)
module hex() rotate(30) circle(r = hex_af/sqrt(3), $fn = 6);

// a field of hexagons filling a W x H area (centered), honeycomb-packed
module hex_field(W, H) {
    hr = hex_af/sqrt(3);
    px = hex_af + hex_wall;          // horizontal pitch
    py = 1.5*hr + hex_wall*0.75;     // vertical (row) pitch
    nx = ceil(W/px) + 1;  ny = ceil(H/py) + 1;
    for (j = [-ny:ny], i = [-nx:nx])
        translate([i*px + (j%2 ? px/2 : 0), j*py]) hex();
}

// honeycomb perforation, confined to the FLAT center of each wall (corners and the
// top/bottom bands stay solid, so the lattice stays tied to the structure)
module honeycomb() {
    z0 = lip0 + win_border;  z1 = Ht - win_border;  zc = (z0+z1)/2;  zh = z1 - z0;
    side_y  = base_y/2 - base_r - win_border;   // side-wall flat half-extent
    front_x = base_x/2 - base_r - win_border;   // front-wall flat half-extent
    union() {
        // side walls (pierce X) -- extra rotate(90) so the holes are pointy-top here too
        intersection() {
            rotate([0,90,0]) linear_extrude(out_x + 20, center = true) rotate([0,0,90]) hex_field(150, 150);
            translate([0, 0, zc]) cube([out_x + 40, 2*side_y, zh], center = true);
        }
        // front wall (pierce Y)
        intersection() {
            rotate([90,0,0]) linear_extrude(out_y + 20, center = true) hex_field(150, 150);
            translate([0, -out_y/2, zc]) cube([2*front_x, out_y + 40, zh], center = true);
        }
    }
}

/* ---------- parts ---------- */
module walls() {
    difference() {
        linear_extrude(Ht) difference() { rfront(out_x, out_y, out_r); rfront(in_x, in_y, in_r); }
        open_back();
        below_tilt(lip0);
        honeycomb();
    }
}

module lips() {
    difference() {
        // span op..OUT and extrude up past lip0 so the lip merges solidly with
        // the walls (avoids a coincident-face split into a separate volume)
        multmatrix(shear)
            translate([0, 0, lip0]) linear_extrude(lip_t + 1.5)
                difference() { rfront(out_x, out_y, out_r); rfront(op_x, op_y, op_r); }
        open_back();
        back_strip();      // no lip across the open back
        lip_ramp();        // make the eero-rest a 45 deg ramp (self-supporting in plate-down print)
    }
}

// Cuts the lip's eero-rest face into a 45-deg ramp that rises from the inner edge
// (op, at the lip plane lip0) up to the wall (in, lip0+lip_w). The lip sits ON the
// lip plane (flush with the walls/beam) and the ramp is self-supporting plate-down.
module lip_ramp() {
    multmatrix(shear) hull() {
        translate([0, 0, lip0 + lip_w]) linear_extrude(80) rfront(in_x, in_y, in_r);
        translate([0, 0, lip0])         linear_extrude(80) rfront(op_x, op_y, op_r);
    }
}

module plate() {
    pt = plate_t + 1;            // overlap 1 mm into the walls (avoid coincident face)
    translate([0, 0, Ht - 1])
        difference() {
            linear_extrude(pt) rfront(out_x, out_y, out_r);
            // central opening to save material (inset to clear the screws)
            translate([0, open_yc, -1]) linear_extrude(pt + 2) rrect(open_x, open_y, open_r);
            // back screws near the square back corners; front screws pulled in to
            // clear the rounded front corners (else the hole overlaps the wall)
            bx = out_x/2 - screw_inset;   by = out_y/2 - screw_inset;
            fcx = out_x/2 - out_r;        fcy = out_y/2 - out_r;     // front arc centers
            foff = in_r - drv_clear;                                 // pull in for straight driver access
            fx = fcx + foff*0.7071;       fy = fcy + foff*0.7071;
            for (s = [[bx, by], [-bx, by], [fx, -fy], [-fx, -fy]])
                translate([s[0], s[1], -0.1]) {
                    cylinder(d = screw_d, h = pt + 0.2);
                    // countersink opens on the INTERIOR (room) side: head seats inside
                    // the cradle, screw drives up into the boards above the ceiling
                    cylinder(d1 = screw_head_d, d2 = screw_d, h = 2.6);
                }
        }
}

// Back beam across the square mouth (flush within the side walls), sitting just
// above the (angled) lip plane at the back. The eero's back drops past it.
module beam() {
    yi = in_y/2 - beam_t;                    // flush with the open back
    z_at_back = lip0 - k*yi;                 // sits on the (tilted) lip plane -> lower at the back
    translate([-out_x/2, yi, z_at_back]) cube([out_x, beam_t, catch]);
}

// Envelope used to chamfer the outer bottom edge: full size above the chamfer,
// tapering in by `chamfer` over its height at the very bottom (in the tilted frame).
module chamfer_envelope() {
    bz = lip0;                               // model bottom (lip now sits on the lip plane)
    multmatrix(shear) union() {
        translate([0, 0, bz + chamfer]) linear_extrude(2000) rfront(out_x, out_y, out_r);
        hull() {
            translate([0, 0, bz])           linear_extrude(0.02) rfront(out_x - 2*chamfer, out_y - 2*chamfer, out_r);
            translate([0, 0, bz + chamfer]) linear_extrude(0.02) rfront(out_x, out_y, out_r);
        }
    }
}

// 3mm 45-deg fillet bead in the inner corner where the walls meet the plate
// (reinforces that join). Excluded from the open back.
module join_bead() {
    b = 3;  zt = Ht - 1;                         // plate underside
    difference() {
        // square ring band in the inner corner ...
        translate([0,0,zt-b]) linear_extrude(b)
            difference() { rfront(in_x, in_y, in_r); rfront(in_x-2*b, in_y-2*b, max(in_r-b,1)); }
        // ... minus a 45-deg cone, leaving the corner-filling fillet (hypotenuse faces in)
        hull() {
            translate([0,0,zt-b]) linear_extrude(0.02) rfront(in_x, in_y, in_r);
            translate([0,0,zt])   linear_extrude(0.02) rfront(in_x-2*b, in_y-2*b, max(in_r-b,1));
        }
        open_back();
        back_strip();      // no bead across the open back
    }
}

module cradle() {
    intersection() {
        union() { walls(); lips(); plate(); beam(); join_bead(); }
        chamfer_envelope();
    }
}

// eero seated upside down (base near plate, dome through the angled lips)
module eero_seated() { translate([0, 0, base_z]) scale([1, 1, -1]) eero_pro6(); }

// print orientation: plate flat on the bed (ceiling face down), opening up
translate([0, 0, Ht + plate_t]) rotate([180, 0, 0]) cradle();
// eero_seated();
