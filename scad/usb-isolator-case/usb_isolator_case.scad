// usb_isolator_case.scad
// Two-part case (base + lid) for the ADuM3160 USB isolator board.
// Board geometry comes from adum3160_board.scad (same axes: X across, Y along with
// 0 = male-A PCB edge, Z up with 0 = PCB bottom face).
//
// - Board sits on four corner pads in the base, is boxed in X/Y by the base walls and
//   two end stops, and is pressed down by lid ribs on the two USB shells.
// - Male-A end: a sleeve the black cable's female overmold slides into.
// - Female-A end: the case end is flush with the receptacle mouth and the opening only
//   clears the metal shell, so any plug's overmold seats against the socket as normal.
// - Lid and base join with 4x M3 x 16 through side ears into M3 heat-set inserts
//   (5 mm OD x 4 mm) pressed into the top of the base ears.
// - Mounting: a flange along the +X side, flush with the base bottom, with 2x M3 holes
//   on a 2020 slot centreline. Screw the flange to the extrusion face and the case
//   hangs off the extrusion's edge, back against the face, out of the cable path.
// - All metal (inserts, screws) sits outside the board cavity, away from the
//   isolation gap across the middle of the board.
// - Vents over the B0505S; open LED slits on short shrouds that reach down to just
//   above each LED (works in black filament). The DIP switch is covered.
//
// part = "assembly" | "base" | "lid"
// Export:  openscad -D 'part="base"' -o usb_isolator_base.stl usb_isolator_case.scad
//          openscad -D 'part="lid"'  -o usb_isolator_lid.stl  usb_isolator_case.scad
// Both STLs come out in print orientation (lid flipped, top on the bed).

include <adum3160_board.scad>
board_standalone = false;

part = "assembly";
$fn = 48;

/* ---------- Parameters ---------- */
clr      = 0.3;    // clearance around the PCB
wall     = 2.0;
floor_t  = 2.0;    // below the lowest opening
top_clr  = 1.0;    // above the tallest part

// Male-A end: cable overmold envelope (black cable 17.7 x 10.1 + ~3 mm each side)
ma_plug_w = 24;
ma_plug_h = 16;
plug_r    = 4;

// Female-A end: clearance around the receptacle shell only
fa_open_clr = 0.5;
fa_flush    = 0.2;    // case end face sits this far behind the receptacle mouth

split_z  = pcb_top;   // base/lid parting plane: PCB top face
stop_h   = 1.3;       // male-end stop rises to just under the PCB top face
stop_t   = 1.5;       // male-end stop thickness (overmold seats against it)
pad      = 2.0;       // corner support pad size

// Lid screws
m3_hole   = 3.4;
m3_head_d = 6.0;
insert_hole  = 4.1;   // heat-set pilot for 5 mm OD M3 inserts (check the insert's spec)
insert_depth = 4.0;
insert_extra = 1.0;   // pocket deeper than the insert so melt has somewhere to go
screw_len = 16;       // lid-to-base screws (M3 x 16)
ear_r     = 4.5;
ear_off   = 4.0;      // hole centre outside the case side face
ear_y     = [-4, 37];

// 2020 mounting flange (+X side)
flange_t       = 4;
flange_hole_x  = 10;        // hole centre from the case side face = 2020 slot centre
flange_w       = 15;        // flange reach from the case side face
flange_hole_y  = [-11, 29]; // clear of the ears
m3_head_clr    = 7;         // spot-face for the screw head

vent_w    = 1.2;

// LED slits + shrouds
led_slit      = [2.2, 1.4];   // X x Y opening
led_shroud_t  = 0.8;
led_shroud_gap = 1.0;         // shroud bottom above the LED top

/* ---------- Derived ---------- */
ma_open_c = [ma_x, ma_axis_z];             // [X, Z] centre of the male-end sleeve

cav_x0 = -clr;            cav_x1 = pcb_w + clr;
cav_y0 = -0.2;            cav_y1 = pcb_l + 0.2;
cav_z0 = -(bottom_clear + 0.5);
cav_z1 = board_top + top_clr;

// female-end opening around the receptacle shell
fa_open0 = [fa_x - fa_w/2 - fa_open_clr, pcb_top + fa_z - fa_open_clr];
fa_open1 = [fa_x + fa_w/2 + fa_open_clr, pcb_top + fa_z + fa_h + fa_open_clr];

sleeve_y0 = ma_tip_y;                      // open end of the male sleeve

box_x0 = min(cav_x0, ma_open_c[0] - ma_plug_w/2, fa_open0[0]) - wall;
box_x1 = max(cav_x1, ma_open_c[0] + ma_plug_w/2, fa_open1[0]) + wall;
box_z0 = min(cav_z0, ma_open_c[1] - ma_plug_h/2) - floor_t;
box_z1 = max(cav_z1, ma_open_c[1] + ma_plug_h/2, fa_open1[1]) + wall;
box_y0 = sleeve_y0;
box_y1 = fa_mouth_y - fa_flush;
assert(box_y1 - cav_y1 >= 1.2, "female end wall too thin");

insert_z0    = split_z - insert_depth - insert_extra;   // bottom of the insert pocket
screw_tip_z  = split_z - insert_depth + 0.5;            // 3.5 mm of thread engaged
screw_seat_z = screw_tip_z + screw_len;
assert(screw_seat_z <= box_z1, "screw_len too long for the case height");
assert(screw_seat_z >= split_z + 4, "screw_len too short: lid flange under the head too thin");

ear_xs = [box_x0 - ear_off, box_x1 + ear_off];
led_top_z = pcb_top + led_sz[2];

echo(str("Case outer: ", box_x1 - box_x0, " x ", box_y1 - box_y0, " x ", box_z1 - box_z0,
         " mm (W x L x H, excl. ears/flange); mount holes ", flange_hole_y[1] - flange_hole_y[0],
         " mm apart, ", flange_hole_x, " mm out from the case side"));

/* ---------- Helpers ---------- */
// Rounded rectangle in the XZ plane, extruded along +Y from y0 to y1.
module xz_rrect(c, w, h, r, y0, y1)
    translate([c[0], y1, c[1]]) rotate([90, 0, 0])
        linear_extrude(y1 - y0)
            offset(r = r) square([w - 2*r, h - 2*r], center = true);

module box(p0, p1) translate(p0) cube(p1 - p0);

/* ---------- Solid ---------- */
module ears() {
    for (x = ear_xs, y = ear_y)
        hull() {
            translate([x, y, box_z0]) cylinder(r = ear_r, h = box_z1 - box_z0);
            box([x < box_x0 ? box_x0 : box_x1 - 0.01, y - ear_r, box_z0],
                [x < box_x0 ? box_x0 + 0.01 : box_x1, y + ear_r, box_z1]);
        }
}

module mount_flange()
    hull() {
        box([box_x1 - 0.01, box_y0, box_z0], [box_x1, box_y1, box_z0 + flange_t]);
        for (y = [box_y0 + 3, box_y1 - 3])
            translate([box_x1 + flange_w - 3, y, box_z0]) cylinder(r = 3, h = flange_t);
    }

module led_shrouds()
    for (p = [led_red, led_blue])
        difference() {
            translate([p[0] - led_slit[0]/2 - led_shroud_t, p[1] - led_slit[1]/2 - led_shroud_t,
                       led_top_z + led_shroud_gap])
                cube([led_slit[0] + 2*led_shroud_t, led_slit[1] + 2*led_shroud_t,
                      cav_z1 - led_top_z - led_shroud_gap + 0.01]);
            // keep clear of the female-A shell next to the red LED
            box([fa_x - fa_w/2 - clr, fa_y0 - clr, pcb_top + fa_z - clr],
                [fa_x + fa_w/2 + clr, fa_mouth_y + 1, pcb_top + fa_z + fa_h + clr]);
        }

module shell_solid() {
    box([box_x0, box_y0, box_z0], [box_x1, box_y1, box_z1]);
    ears();
    mount_flange();
}

/* ---------- Voids ---------- */
module cavity() {
    // main board cavity
    box([cav_x0, cav_y0, cav_z0], [cav_x1, cav_y1, cav_z1]);

    // male-A sleeve: overmold pocket, open at the end, running up to the board edge
    xz_rrect(ma_open_c, ma_plug_w, ma_plug_h, plug_r, sleeve_y0 - 1, cav_y0 + 0.01);

    // female-A opening: shell clearance through the end wall
    box([fa_open0[0], cav_y1 - 0.01, fa_open0[1]], [fa_open1[0], box_y1 + 1, fa_open1[1]]);
}

// Solid bits added back inside the voids
module inner_features() {
    // male-end stop: stops the PCB edge and the cable overmold
    intersection() {
        xz_rrect(ma_open_c, ma_plug_w, ma_plug_h, plug_r, cav_y0 - stop_t, cav_y0);
        box([box_x0, cav_y0 - stop_t, box_z0], [box_x1, cav_y0, stop_h]);
    }

    // corner support pads
    for (x = [cav_x0, pcb_w - pad], y = [cav_y0, pcb_l - pad])
        box([x, y, cav_z0 - 0.01], [x == cav_x0 ? pad : cav_x1, y == cav_y0 ? pad : cav_y1, 0]);

    // lid hold-down ribs on the USB shells
    box([ma_x - ma_w/2 + 1, 0.5, pcb_top + ma_h], [ma_x + ma_w/2 - 1, ma_inboard - 0.5, cav_z1 + 0.01]);
    box([fa_x - fa_w/2 + 1, fa_y0 + 2, pcb_top + fa_z + fa_h], [fa_x + fa_w/2 - 1, pcb_l - 1, cav_z1 + 0.01]);

    led_shrouds();
}

module vents() {
    // top slots over the B0505S
    for (i = [0 : 2])
        box([pcb_w - dcdc_w + 0.5 + i*2, dcdc_y0, cav_z1 - 0.01],
            [pcb_w - dcdc_w + 0.5 + i*2 + vent_w, dcdc_y0 + dcdc_l, box_z1 + 1]);
    // side slots in the +X wall beside it
    for (i = [0 : 3])
        box([cav_x1 - 0.01, dcdc_y0 + 1 + i*2.8, split_z + 2],
            [box_x1 + 1, dcdc_y0 + 1 + i*2.8 + vent_w, cav_z1 - 1]);
}

module led_slits()
    for (p = [led_red, led_blue])
        translate([p[0] - led_slit[0]/2, p[1] - led_slit[1]/2, led_top_z])
            cube([led_slit[0], led_slit[1], box_z1 + 1]);

module screw_holes() {
    for (x = ear_xs, y = ear_y) {
        translate([x, y, split_z - 0.01]) cylinder(d = m3_hole, h = box_z1);           // lid clearance
        translate([x, y, screw_seat_z]) cylinder(d = m3_head_d, h = box_z1);           // head counterbore
        translate([x, y, insert_z0]) cylinder(d = insert_hole, h = split_z - insert_z0 + 0.01);  // heat-set
    }
    for (y = flange_hole_y)
        translate([box_x1 + flange_hole_x, y, box_z0 - 1]) {
            cylinder(d = m3_hole, h = flange_t + 2);
            translate([0, 0, flange_t + 1]) cylinder(d = m3_head_clr, h = box_z1);   // head/driver clearance
        }
}

module case_body() {
    difference() {
        union() {
            difference() { shell_solid(); cavity(); }
            inner_features();
        }
        vents();
        led_slits();
        screw_holes();
    }
}

/* ---------- Parts ---------- */
module base() intersection() { case_body(); box([-100, -100, box_z0 - 1], [100, 100, split_z]); }
module lid()  intersection() { case_body(); box([-100, -100, split_z], [100, 100, box_z1 + 1]); }

if (part == "base") {
    translate([0, 0, -box_z0]) base();
} else if (part == "lid") {
    translate([0, 0, box_z1]) rotate([180, 0, 0]) lid();
} else if (part == "assembly") {
    color("DimGray", 0.9) base();
    color("DimGray", 0.35) lid();
    adum3160_board();
}
