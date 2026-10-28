// hdmi_kit_mounts.scad
// Small parts for the CSI-to-HDMI camera extension on the Kobra Max:
//   - clip:   HDMI cable clip on one M3 T-nut (any 2020 / 4040 slot). The cable
//             lies in the groove on top; a zip tie through the tunnel holds it.
//   - ribbon: flat-ribbon clip on one M3 T-nut, for the 11.5 mm Pi ribbon. The ribbon
//             threads through a slot over the flush bolt head (feed it through before
//             plugging it in; bolt the clip down through the hole in its roof first).
//   - case / lid: the bottom UC-392 board in a small case on the OUTBOARD face of the
//             right base 4040, behind the Pi. One M3 T-nut in each of the face's two
//             slots, under the board (bolt the case on before fitting the board). No
//             kit hardware (the top pod uses it all): the board drops onto printed
//             standoffs, their pins through its four holes, and the lid's two posts
//             press it down at the middle holes (the ribbon-end holes are hard against
//             the socket's latch ears). The ribbon drops into a notch in one end wall;
//             the HDMI end is open. The lid screws on: 4 x M2.5 x 8-12, self-tapped
//             into pilots in the corner lugs.
//
// Coordinates: each part sits on the extrusion face at z=0 (the face it bolts to),
// X along the extrusion, Y across it. All print as modelled (lid upside down), no supports.
//
//   openscad -D 'part="clip"'   -o hdmi_clip.stl    hdmi_kit_mounts.scad
//   openscad -D 'part="ribbon"' -o ribbon_clip.stl  hdmi_kit_mounts.scad
//   openscad -D 'part="case"'   -o uc392_case.stl   hdmi_kit_mounts.scad
//   openscad -D 'part="lid"'    -o uc392_lid.stl    hdmi_kit_mounts.scad

use <rail_cam_mount.scad>   // rcube
use <uc392.scad>

part = "all";   // "clip", "ribbon", "case", "lid", "all" (preview)
$fn = 48;

m3_clear = 3.4;
m3_head  = 6.5;
m25_pilot = 2.1;      // M2.5 self-tapped into the print
m25_clear = 2.9;
er = 1.0;

/* ---------- HDMI cable clip ---------- */
clip_l   = 20;     // along the slot
clip_w   = 11;
clip_h   = 8;
clip_bolt_x = -5;  // from the centre
head_floor  = 4;   // under the bolt head: M3 x 8 into the T-nut
tie_w    = 4.5;    // zip-tie tunnel
tie_h    = 2.2;
tie_x    = 4.5;
cable_d  = 7.5;    // HDMI cable groove
groove   = 1.5;

module clip() {
    difference() {
        translate([-clip_l/2, -clip_w/2, 0]) rcube([clip_l, clip_w, clip_h]);
        translate([clip_bolt_x, 0, -1]) {
            cylinder(d = m3_clear, h = clip_h + 2);
            translate([0, 0, 1 + head_floor]) cylinder(d = m3_head, h = clip_h);
        }
        // tunnel across, for the zip tie
        translate([tie_x - tie_w/2, -clip_w, 2.5]) cube([tie_w, 2 * clip_w, tie_h]);
        // cable groove along the top, over the tunnel
        translate([-clip_l/2 - 1, 0, clip_h + cable_d/2 - groove]) rotate([0, 90, 0]) cylinder(d = cable_d, h = clip_l + 2);
    }
}

/* ---------- Ribbon clip ---------- */
rib_w     = 11.5;   // Pi 5 22-pin ribbon
rib_slot  = [rib_w + 0.8, 1.2];   // slot the ribbon threads through (width, height)
rc_l      = 22;     // along the slot
rc_w      = rib_slot[0] + 2 * 2.4;
rc_floor  = 4.5;    // the bolt head sits in the floor, flush, under the ribbon
rc_roof   = 1.6;
rc_h      = rc_floor + rib_slot[1] + rc_roof;
rc_head_floor = 2.5;   // M3 x 6-8 into the T-nut

module ribbon_clip() {
    difference() {
        translate([-rc_l/2, -rc_w/2, 0]) rcube([rc_l, rc_w, rc_h], r = 0.8);
        // ribbon runs along X, through the whole clip
        translate([-rc_l, -rib_slot[0]/2, rc_floor]) cube([2 * rc_l, rib_slot[0], rib_slot[1]]);
        // bolt in the middle; driver access through the roof
        translate([0, 0, -1]) cylinder(d = m3_clear, h = rc_h + 2);
        translate([0, 0, rc_head_floor]) cylinder(d = m3_head, h = rc_floor);
        translate([0, 0, rc_floor]) cylinder(d = 6, h = rc_h);
    }
}

/* ---------- UC-392 case ---------- */
face_h   = 40;               // 4040 face
slot_ys  = [10, 30];         // the face's two slots, from the bottom edge
base_t   = 4;                // the T-nut bolt heads sit in it, under the board
riser_h  = 6;                // standoffs: clear the 4.5 mm jack on the board's back
post_d   = 3.5;              // standoff; the corner ones just clear the back jack
pin_d    = 1.6;              // through the board's ~2.0 holes
pin_h    = 1.5 + 1;
wall     = 2;
gap      = 0.4;              // board edge to wall
jack_out = 0.8;              // the back jack overhangs one long edge
uc_l = 27.6;  uc_w = 24.77;
in_x  = [-uc_l/2 - gap, uc_l/2 + 1];          // HDMI end (+X) open; receptacle mouth ~1 past the board
in_y  = [face_h/2 - uc_w/2 - gap - jack_out, face_h/2 + uc_w/2 + gap];
in_h  = riser_h + 1.5 + 0.5 + 6 + 1.5;        // risers + PCB + receptacle + room
wall_top = base_t + in_h;
lid_t = 2;
lip   = 2;                   // lid lip down inside the walls
press_d = 4;                 // lid posts pressing on the board round the middle holes
lug_x = [in_x[0] + 2.5, in_x[1] - 3];   // lid screw lugs, outside the long walls
lug_l = 6;
case_bolt_x = 8;             // under the board, between the middle holes and the HDMI end
rib_notch = [17, 4];         // ribbon notch in the -X end wall (width, depth from the top)
rib_z = base_t + riser_h + 1.5 + 1.25;   // ribbon height at the socket

// UC-392 in case coords: model Y (toward ribbon) -> -X, model X -> +Y, face out (+Z)
uc_c = [0, face_h/2];
function uc_case(h) = [uc_c[0] + uc_l/2 - h[1], uc_c[1] - uc_w/2 + h[0]];

// lid screw lugs fill the face's margins outside the long walls: y 0..wall, wall..40
function lug_y(oy) = [oy[0] / 2, (oy[1] + face_h) / 2];

module case_body() {
    ox = [in_x[0] - wall, in_x[1]];
    oy = [in_y[0] - wall, in_y[1] + wall];
    difference() {
        union() {
            translate([ox[0], oy[0], 0]) rcube([ox[1] - ox[0], oy[1] - oy[0], wall_top]);
            for (x = lug_x) {
                translate([x - lug_l/2, 0, 0]) rcube([lug_l, oy[0] + 1, wall_top]);
                translate([x - lug_l/2, oy[1] - 1, 0]) rcube([lug_l, face_h - oy[1] + 1, wall_top]);
            }
        }
        // cavity, open at the HDMI end
        translate([in_x[0], in_y[0], base_t]) cube([in_x[1] - in_x[0] + 5, in_y[1] - in_y[0], in_h + 1]);
        // ribbon notch in the -X end wall, open to the top
        translate([ox[0] - 1, face_h/2 - rib_notch[0]/2, rib_z - 1.5]) cube([wall + 2, rib_notch[0], wall_top]);
        // T-nut bolts, one per slot, counterbored into the floor
        for (y = slot_ys) translate([case_bolt_x, y, -1]) {
            cylinder(d = m3_clear, h = base_t + 2);
            translate([0, 0, 1 + base_t - 1.8]) cylinder(d = m3_head, h = 5);
        }
        // lid screw pilots
        for (x = lug_x, y = lug_y(oy)) translate([x, y, wall_top - 12]) cylinder(d = m25_pilot, h = 13);
    }
    // standoffs + locating pins
    for (h = uc392_holes()) let(p = uc_case(h)) translate([p[0], p[1], base_t - 0.01]) {
        cylinder(d = post_d, h = riser_h + 0.01);
        cylinder(d = pin_d, h = riser_h + pin_h, $fn = 16);
    }
}

// Lid, modelled in place on the case (flip it to print, top face down)
module lid() {
    ox = [in_x[0] - wall, in_x[1]];
    oy = [in_y[0] - wall, in_y[1] + wall];
    board_top = base_t + riser_h + 1.5;
    difference() {
        union() {
        translate([ox[0], oy[0], wall_top]) rcube([ox[1] - ox[0], oy[1] - oy[0], lid_t]);
        for (x = lug_x) translate([x - lug_l/2, 0, wall_top]) rcube([lug_l, face_h, lid_t]);
        // locating lip inside the walls (not across the ribbon notch or the open end)
        difference() {
            translate([in_x[0] + 0.3, in_y[0] + 0.3, wall_top - lip]) cube([in_x[1] - in_x[0] - 0.6, in_y[1] - in_y[0] - 0.6, lip + 0.01]);
            translate([in_x[0] + 1.5, in_y[0] + 1.5, wall_top - lip - 1]) cube([in_x[1] - in_x[0], in_y[1] - in_y[0] - 3, lip + 2]);
        }
        // posts down onto the board round the middle holes (the pins poke up into them)
        for (h = [for (h = uc392_holes()) if (h[1] < 20) h]) let(p = uc_case(h))
            translate([p[0], p[1], board_top]) cylinder(d = press_d, h = wall_top - board_top + 0.01);
        }
        for (h = uc392_holes()) let(p = uc_case(h))
            translate([p[0], p[1], board_top - 1]) cylinder(d = pin_d + 0.6, h = pin_h + 0.5, $fn = 16);
        for (x = lug_x, y = lug_y(oy)) translate([x, y, wall_top - 1]) cylinder(d = m25_clear, h = lid_t + 2);
    }
}

module case_board()
    translate([uc_c[0] + uc_l/2, uc_c[1] - uc_w/2, base_t + riser_h + 1.5]) rotate([0, 0, 90]) uc392();

if (part == "clip") clip();
else if (part == "ribbon") ribbon_clip();
else if (part == "case") case_body();
else if (part == "lid") translate([0, 0, wall_top + lid_t]) mirror([0, 0, 1]) lid();
else {
    color("SteelBlue") case_body();
    case_board();
    color("LightSteelBlue", 0.6) translate([0, 0, 25]) lid();
    translate([0, -25, 0]) color("SteelBlue") clip();
    translate([35, -25, 0]) color("SteelBlue") ribbon_clip();
}
