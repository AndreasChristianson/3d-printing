// revo_nozzle_case.scad
// Latching case for 8 E3D Revo nozzles plus spare silicone cuffs, sized for
// the 80 x 70 x 75 toolbox organiser bin.
//
// - 8 sockets, 2 rows x 4, nozzles stand tip-up so the cuff colours show.
//   The left 2x2 group is for High Flow nozzles: "HF" down the left edge and
//   a ridge between the groups (a 0.4 and a 0.4 HF look identical).
// - Spare-cuff well at the back: 3 pegs x 3 cuffs, plus a bay for the
//   HeaterCore sock.
// - Lid on a 1.75 filament pin hinge at the back, held shut by a rubber
//   band at the front (a printed snap arm would flex across its layer lines).
//   The band loops between two buttons on the front: one flush with the lid
//   top, one flush with the base bottom. Each is a short post with a cap; the
//   band sits on the post, 2 below the cap's edge, and the cap and wall keep
//   it from sliding off. Both buttons start on the bed as printed and the
//   posts bridge 3 mm wall-to-cap, so nothing needs supports.
//   Rings under the lid press on the cuffs (not the tips) so nozzles stay put
//   upside down.
//
// Axes: X = width (left to right), Y = front (latch) to back (hinge),
// Z = up. Origin = base front-left-bottom corner.
//
// Parts (render each with scad/render.sh, which also writes .tag.stl):
//   scad/render.sh revo_nozzle_case.scad base.stl -D 'part="base"'
//   scad/render.sh revo_nozzle_case.scad lid.stl  -D 'part="lid"'
// The base's .tag.stl is the bottom provenance inlay plus the "HF" label:
// give it a contrasting filament. Print the base upright, the lid upside
// down (top on the bed). Pin: a ~70 mm length of 1.75 filament.
// Band: the render echoes the loop length it is stretched to.
//
// Preview: part = "assembly" (lid closed), "open", or "exploded".

include <revo_nozzle.scad>
include <../lib/provenance.scad>
show_revo_nozzle = false;

$fn = 64;
part = "assembly";   // base | lid | assembly | open | exploded

/* ---------- Envelope (bin 80 x 70 x 75) ---------- */
body_x   = 77;
body_y   = 57;
wall     = 2.4;
floor_t  = 1.6;
corner_r = 3;

/* ---------- Nozzle sockets ---------- */
hole_d      = stem_max_d + 0.5;   // 6.5 loose fit on the 6.0 stem
stem_clear  = 0.5;                // under the stem end
cb_d        = cuff_od + 0.8;      // cuff counterbore
cb_depth    = 2.0;
deck_z      = floor_t + stem_clear + stem_len + cb_depth;   // 38.2
cuff_bot_z  = deck_z - cb_depth;
cuff_top_z  = cuff_bot_z + cuff_h;
tip_top_z   = cuff_top_z + tip_len;

label_x0    = 3.9;     // HF label strip, clear of the lid lip
label_w     = 6.7;
pitch       = 16;
col_x       = [for (i = [0:3]) label_x0 + label_w + cb_d/2 + i*pitch];   // 17.5 .. 65.5
row_y       = [11.1, 11.1 + pitch];
hf_cols     = [0, 1];
ridge_w     = 1.2;
ridge_h     = 1.6;
label_size  = 7.5;
label_depth = 0.8;
label_font  = "JetBrains Mono:style=ExtraBold";

/* ---------- Lid / rim ---------- */
z_rim       = deck_z + 2.2;     // base/lid parting plane, 40.4
lid_ceil_z  = tip_top_z + 1.2;  // lid inside
lid_top_t   = 1.6;
lid_top_z   = lid_ceil_z + lid_top_t;   // 46
lip_in      = 2.6;              // lid lip, inset from the outside
lip_t       = 1.2;
lip_h       = 1.8;
ring_od     = 12;               // hold-down rings, on the cuff only
ring_id     = 7;
ring_press  = 0.3;              // squeeze on the silicone

/* ---------- Spares well ---------- */
well_y0     = row_y[1] + cb_d/2 + 1.2;   // 35.2
well_y1     = body_y - wall;
well_z      = lid_ceil_z - 18;           // 26.4: 3 cuffs + finger room
peg_d       = cuff_id - 0.6;
peg_h       = 14;
peg_y       = (well_y0 + well_y1) / 2;
peg_x       = [for (i = [0:2]) wall + 1 + cuff_od/2 + 1 + i*15];   // 3 pegs
sock_div_x  = 50;
// HeaterCore sock (est, not measured): fits the bay x 51.2..74.6, 18 deep
sock_est    = [20, 16, 14];

/* ---------- Hinge ---------- */
hinge_r     = 3.2;
hinge_y     = body_y + 3.6;
hinge_z     = z_rim;
pin_d_base  = 1.9;   // grips the 1.75 filament
pin_d_lid   = 2.2;   // the lid turns on it
hinge_gap   = 0.4;
base_knuckles = [[6, 22], [55, 71]];
lid_knuckle   = [22 + hinge_gap, 55 - hinge_gap];

/* ---------- Rubber band latch ---------- */
band_x      = body_x / 2;
btn_seat    = 2.0;    // band seat (post top) below the lid top / above the base bottom
post_w      = 5;      // post, X; the band strands run either side of it
post_h      = 3;      // post, Z
post_out    = 3;      // post length out from the wall (Y): room for 2 wraps
cap_w       = 11;     // cap, X
cap_t       = 1.6;    // cap, Y
cap_h       = lid_top_z - z_rim;   // cap, Z: full lid height (5.6)
// Loop circumference when on: two strands between the seats plus the wrap
// over each post.
band_loop = 2 * ((lid_top_z - btn_seat) - btn_seat) + 2 * post_w;
echo(str("band loop (mm): ", round(band_loop)));

assert(z_rim - lip_h > deck_z + 0.3, "lid lip hits the deck");
assert(col_x[3] + cb_d/2 < body_x - lip_in - lip_t, "sockets reach the lid lip");
assert(row_y[0] - cb_d/2 > lip_in + lip_t, "front row reaches the lid lip");
assert(hinge_y + hinge_r + post_out + cap_t <= 70, "deeper than the bin");
assert(btn_seat + post_h < cap_h - 0.5, "post doesn't fit under the cap");

/* ---------- Helpers ---------- */
// x by y rounded rectangle, or the outline inset from it (corner radius
// shrinks with the inset, down to 0.5)
module rrect(x, y, r = corner_r, inset = 0) {
    rr = max(r - inset, 0.5);
    translate([inset, inset])
        offset(r = rr) offset(delta = -rr)
            square([x - 2*inset, y - 2*inset]);
}

module xcyl(r, x0, x1) {
    translate([x0, 0, 0]) rotate([0, 90, 0]) cylinder(r = r, h = x1 - x0);
}

/* ---------- Base ---------- */
module base_body() {
    difference() {
        union() {
            linear_extrude(z_rim) rrect(body_x, body_y);
            for (k = base_knuckles) base_knuckle(k[0], k[1]);
            band_button(btn_seat, up = false);
        }
        // interior above the deck / well
        translate([0, 0, deck_z]) linear_extrude(z_rim) rrect(body_x, body_y, inset = wall);
        translate([wall, well_y0, well_z]) cube([body_x - 2*wall, well_y1 - well_y0, z_rim]);
        // sockets
        for (x = col_x, y = row_y) translate([x, y, 0]) {
            translate([0, 0, floor_t]) cylinder(d = hole_d, h = deck_z);
            translate([0, 0, cuff_bot_z]) cylinder(d = cb_d, h = 10);
            translate([0, 0, cuff_bot_z - 0.6]) cylinder(d1 = hole_d, d2 = hole_d + 1.2, h = 0.6);
        }
        // pin
        translate([0, hinge_y, hinge_z]) xcyl(pin_d_base/2, -1, body_x + 1);
    }
    // spares: cuff pegs and the sock bay divider
    for (x = peg_x) translate([x, peg_y, well_z - 0.01]) {
        cylinder(d = peg_d, h = peg_h - 1);
        translate([0, 0, peg_h - 1]) cylinder(d1 = peg_d, d2 = peg_d - 2, h = 1);
    }
    translate([sock_div_x, well_y0, well_z - 0.01]) cube([1.2, well_y1 - well_y0, 14]);
    // ridge between the HF and standard groups
    translate([(col_x[1] + col_x[2] - ridge_w)/2, row_y[0] - cb_d/2, deck_z - 0.01])
        cube([ridge_w, row_y[1] - row_y[0] + cb_d, ridge_h]);
}

module base_knuckle(x0, x1) {
    translate([x0, 0, 0]) rotate([0, 90, 0]) linear_extrude(x1 - x0)
        // profile in (-z, y) after the rotate: draw in [y, z] then map
        polygon([for (p = knuckle_profile(-1)) [-p[1], p[0]]]);
}

// [y, z] outline of a knuckle and its gusset; dir -1 = below the axis
// (base, 45 deg gusset down to the wall), +1 = above (lid, a block to its top)
function knuckle_profile(dir) =
    let (arc = [for (a = [0 : 10 : 360]) [hinge_y + hinge_r*cos(a), hinge_z + hinge_r*sin(a)]])
    dir < 0
        ? concat([[body_y - 1, hinge_z + 0.0], [body_y - 1, hinge_z - hinge_r - (hinge_y - body_y) - 1]],
                 [for (a = [-90 : 10 : 90]) [hinge_y + hinge_r*cos(a), hinge_z + hinge_r*sin(a)]],
                 [[body_y, hinge_z]])
        : concat([[body_y - 1, lid_top_z], [body_y - 1, hinge_z], [body_y + 0.3, hinge_z]],
                 [for (a = [-90 : 10 : 90]) [hinge_y + hinge_r*cos(a), hinge_z + hinge_r*sin(a)]],
                 [[hinge_y + hinge_r, lid_top_z]]);

// Band button on the front wall. The band seats on the post face at z_seat
// (up = true: band over the post, lid; false: band under it, base); the cap
// stands btn_seat proud of the seat and runs flush to the lid top / base
// bottom, so it prints from the bed.
module band_button(z_seat, up) {
    pz0 = up ? z_seat - post_h : z_seat;
    cz0 = up ? z_seat + btn_seat - cap_h : 0;
    module rbox(w, h, y0, y1, z0)
        translate([band_x, y1, z0]) rotate([-90, 0, 0]) linear_extrude(y0 - y1)
            offset(r = 1) offset(delta = -1) translate([-w/2, -h]) square([w, h]);
    rbox(post_w, post_h, 0.01, -post_out - 0.01, pz0);
    rbox(cap_w, cap_h, -post_out, -post_out - cap_t, cz0);
}

module hf_label() {
    lx = label_x0 + label_w/2;
    translate([0, 0, deck_z - 0.01]) linear_extrude(label_depth + 0.01) {
        translate([lx, row_y[1]]) text("H", size = label_size, font = label_font,
                                       halign = "center", valign = "center");
        translate([lx, row_y[0]]) text("F", size = label_size, font = label_font,
                                       halign = "center", valign = "center");
    }
}

module base() with_provenance() {
    base_body();
    union() {
        translate([body_x/2, body_y/2, 0]) rotate([0, 180, 0])
            provenance(w = body_x - 4, h = 22, mode = "inlay");
        hf_label();
    }
}

/* ---------- Lid ---------- */
// tag inlaid in the lid top (on the bed as printed)
module lid() with_provenance() {
    lid_body();
    translate([body_x/2, body_y/2, lid_top_z]) provenance(w = body_x - 4, h = 30, mode = "inlay");
}

module lid_body() {
    difference() {
        union() {
            translate([0, 0, z_rim]) difference() {
                linear_extrude(lid_top_z - z_rim) rrect(body_x, body_y);
                translate([0, 0, -1]) linear_extrude(lid_ceil_z - z_rim + 1)
                    rrect(body_x, body_y, inset = wall);
            }
            // locating lip, front and sides only (the back would foul the hinge)
            translate([0, 0, z_rim - lip_h]) linear_extrude(lip_h + 0.01)
                intersection() {
                    difference() {
                        rrect(body_x, body_y, inset = lip_in);
                        rrect(body_x, body_y, inset = lip_in + lip_t);
                    }
                    square([body_x, body_y - 8]);
                }
            // hold-down rings
            for (x = col_x, y = row_y)
                translate([x, y, cuff_top_z - ring_press])
                    difference() {
                        cylinder(d = ring_od, h = lid_ceil_z - cuff_top_z + ring_press + 0.01);
                        translate([0, 0, -1]) cylinder(d = ring_id, h = 20);
                    }
            lid_knuckle();
            band_button(lid_top_z - btn_seat, up = true);
        }
        translate([0, hinge_y, hinge_z]) xcyl(pin_d_lid/2, -1, body_x + 1);
    }
}

module lid_knuckle() {
    translate([lid_knuckle[0], 0, 0]) rotate([0, 90, 0]) linear_extrude(lid_knuckle[1] - lid_knuckle[0])
        polygon([for (p = knuckle_profile(1)) [-p[1], p[0]]]);
}

/* ---------- Previews ---------- */
cuff_colors = ["red", "red", "blue", "red", "red", "blue", "yellow", "green"];

module contents() {
    for (i = [0:3], j = [0:1])
        translate([col_x[i], row_y[j], cuff_bot_z + cuff_z1])
            rotate([180, 0, 0]) revo_nozzle(cuff_colors[i*2 + j]);
    spare = ["red", "red", "red", "blue", "blue", "blue", "yellow", "green", "pink"];
    for (p = [0:2], k = [0:2]) translate([peg_x[p], peg_y, well_z + k*cuff_h]) revo_cuff(spare[p*3 + k]);
    color("dimgray", 0.8) translate([sock_div_x + 2 + 0.5, well_y0 + 1.5, well_z]) cube(sock_est);
    band_preview();
}

// The band in place: two strands beside the posts, over the lid post and
// under the base post.
module band_preview(t = 1.0) {
    y = -post_out / 2;
    top = lid_top_z - btn_seat + t/2;
    bot = btn_seat - t/2;
    color("saddlebrown") {
        for (dx = [-1, 1]) translate([band_x + dx * (post_w + t)/2 - t/2, y - 1.25, bot - t/2])
            cube([t, 2.5, top - bot + t]);
        for (z = [top, bot]) translate([band_x - post_w/2 - t, y - 1.25, z - t/2]) cube([post_w + 2*t, 2.5, t]);
    }
}

module lid_open(angle = 105) {
    translate([0, hinge_y, hinge_z]) rotate([-angle, 0, 0]) translate([0, -hinge_y, -hinge_z]) lid();
}

if (part == "base") base();
else if (part == "lid") translate([0, 0, lid_top_z]) rotate([180, 0, 0]) lid();   // print orientation
else if (part == "assembly") { base(); color("lightsteelblue") lid(); contents(); }
else if (part == "open") { base(); color("lightsteelblue") lid_open(); contents(); }
else if (part == "exploded") { base(); color("lightsteelblue") translate([0, 0, 25]) lid(); contents(); }
