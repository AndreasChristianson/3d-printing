// chain_link.scad
// Openable cable-chain link for the Kobra Max X gantry and Z chains.
//
// Replaces the "Chain link 55 degree angle" link printed at 200%. It keeps
// that chain's 34 mm pitch, 28.6 mm height and 55 deg max bend per link (so
// the bend radius and the end heights stay the same), and widens it from
// 34 to 45 mm outside, 22 -> 33 mm clear inside. Straight, it stops 2 deg
// short of flat (178 deg), bowed toward the inside of the bend, so the
// plastic's give lets a self-supporting run settle flat instead of sagging.
//
// One crossbar per link is a separate snap-in bar (bar()): pry it off with
// a screwdriver, lay the wires in, press it back. Its two barbed legs click
// into pockets in the side plates.
//
// Frame: x along the chain (rear pivot hole at x=0, front pin at x=pitch),
// y across (0..width), z up (0..height). The chain bends toward z=0: the
// z=0 face is the INSIDE of the bend.
//   open_side = "inner"  removable bar on the inside of the bend (X chain)
//   open_side = "outer"  removable bar on the outside of the bend (Z chain)
//
// Each side plate is two layers: the outer layer carries the rear pivot
// hole, the inner layer carries the front pin. Their profiles come from
// sweeping the neighbor link through flat_stop..max_bend, so the clearance
// cuts are also the bend stops (straight stop on the outside, max_bend stop
// on the inside).
//
// part = "link" | "bar" | "print" (link + bar laid out for the bed)
//      | "link_print" (the link alone, as printed, with its provenance tag)
//      | "assembly" (a few links bent, for checking) | "check" (overlap of
//      two neighbors at bend; renders empty when they clear)

include <../lib/provenance.scad>
prov_fields = "sha";   // one chain pattern: the SHA alone reads best

part      = "print";
open_side = "inner";   // "inner" (X chain) | "outer" (Z chain)
check_a   = 55;      // bend for part = "check"

pitch    = 34;     // pin to pin
height   = 28.6;   // outside, z
inner_w  = 33;     // clear width between the inner plates
t        = 3;      // one plate layer; a side plate is 2 layers
max_bend = 55;     // deg per link
flat_stop = 2;     // deg: the straightest it goes (180 - 2 = 178 deg)
gap      = 0.4;    // running clearance between neighbors

pin_d    = 10;
hole_d   = 10.6;
pin_land = 0.4;    // pin: full-round band left at its root. Above it the
                   //   leading (+x) side is one flat ramp that reaches the
                   //   pin's centreline at the tip (about 27 deg off the
                   //   plate). The hole gets a parallel ramp: see side_plate().
ramp_k   = (pin_d / 2) / (t - pin_land);   // ramp run (x) per unit of rise (y)
nose_r   = 9.5;    // round end around the pin / pivot hole

bar_t    = 4;      // crossbar thickness (z)
bar_c    = 1;      // 45 deg chamfer on the bars' channel-side edges across
                   //   the chain, so pulled wires don't drag on a corner
edge_c   = 1;      // 45 deg chamfer on the link's four outside long edges
bar_x0   = 10;     // crossbar span along x: mid-link, where both plate
bar_x1   = 24;     //   layers are solid, clear of the pin and the hole
gusset   = 2;      // 45 deg fill in the channel's inside corners: fixed bar
                   //   to plates, and the snap-in bar's body to its legs

// snap-in bar. Each leg is a cantilever snap fit; sized by
// strain at the root = 1.5 * leg_t * (barb_d - fit) / (flex - barb_d)^2,
// flex = leg_l - gusset (the gusset stiffens the top of the leg). Keep it
// around 1% (PLA allows ~2%, PETG ~3.5%). At 15 / 1.2 / 1.0 it is 1.06%.
// (The first try, 7 / 1.5 / 0.9, was 4.2%: it would crack. v1, 11 / 1.2 /
// 0.7 with 0.2 fits, printed loose: 0.5 mm of barb in the pocket, 0.3 mm
// of rattle up/down, and 3 mm of slide along the chain in the ear seat.)
// Seated, the barbs' catch slopes sit snap_preload into the pocket's top
// edge, so the legs stay a little flexed and pull the ears down onto
// their seats: no rattle.
ear_t    = 2;      // ears rest on a seat cut into the inner plate's edge
fit      = 0.15;   // bar-to-link clearance, each side
leg_l    = 15;     // leg below the bar's underside (long = low strain)
leg_t    = 1.2;    // leg thickness (y): its flex
leg_w    = bar_x1 - bar_x0;   // legs run the bar's full length, so the bar
                   //   is one constant profile standing on its end: no
                   //   overhangs (see bar_print())
barb_d   = 1.0;    // barb reach: 1.0 - fit = 0.85 into the pocket
pocket_d = 1.2;    // barb pocket depth in the inner plate (of its 3 mm)
barb_h   = 2.4;    // barb height
barb_c   = 0.6;    // rise of the barb's catch slope (31 deg: pry-able)
snap_preload = 0.15; // barb top above the pocket top, seated
pry_gap  = 2;      // screwdriver slot behind the bar's rear end: 2 x pry_w,
pry_w    = 1.5;    //   in the outer half of the ear seat (the inner half
                   //   stays a stop for the ear)

width  = inner_w + 4 * t;
h      = height / 2;   // pivot height
$fn    = 72;

// ---------- 2D profiles in the x-z plane (2D x = chain x, 2D y = z) ----------

// The ends of a link around a pivot (local origin): a round nose of
// nose_r around the pin, and the body with square shoulders above and below
// it. The shoulders are radial faces, so they make the bend stops: as the
// neighbor turns, a shoulder runs straight into the cut face it was swept
// from. (A fully round end has no stop: it just rolls on.)
// Kept as two convex pieces so sweep() can hull them step by step.
module rear_body(len = pitch) { translate([0, -h]) square([len, height]); }
module front_body(len = pitch) { translate([-len, -h]) square([len, height]); }
module nose() { circle(r = nose_r); }

// Union of a convex shape rotated through a0..a1 about the origin.
module sweep(a0, a1, steps = 22) {
    for (i = [0 : steps - 1])
        hull() {
            rotate(a0 + (a1 - a0) * i / steps) children();
            rotate(a0 + (a1 - a0) * (i + 1) / steps) children();
        }
}
// The straight stop: the shoulder faces are radial and the cut is offset by
// gap, which lets the neighbor turn back gap / r past the sweep's start
// (1.6 deg at the shoulder's outer corner, r = h). So the sweep starts that
// much past flat_stop, and the shoulders touch at flat_stop. Each layer's
// body runs stop_ext past the neighbor's pivot line so the sweep has
// material to shape the stop from (at flat_stop = 0 it would end exactly on
// that line).
stop_a = flat_stop + gap / h * 180 / PI;
stop_ext = 2;

// Outer layer: rear end with the pivot hole, cut to clear the next link's
// rear end as it bends (clockwise, toward z=0).
module outer_profile() {
    difference() {
        translate([0, h]) { nose(); rear_body(pitch + stop_ext); }
        translate([pitch, h]) {
            offset(delta = gap) nose();
            sweep(-stop_a, -max_bend) offset(delta = gap) rear_body(pitch + 10);
        }
        translate([0, h]) circle(d = hole_d);
    }
}
// Inner layer: front end with the pin, cut to clear the previous link's
// front end (which turns counter-clockwise relative to this one).
module inner_profile() {
    difference() {
        translate([pitch, h]) { nose(); front_body(pitch + stop_ext); }
        translate([0, h]) {
            offset(delta = gap) nose();
            sweep(stop_a, max_bend) offset(delta = gap) front_body(pitch + 10);
        }
    }
}

// ---------- 3D ----------

module slab(y0, y1) {
    translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children();
}
// mirror about the pivot height: puts a top-side feature on the bottom
module flip_z(on) {
    if (on) translate([0, 0, h]) mirror([0, 0, 1]) translate([0, 0, -h]) children();
    else children();
}
open_bottom = open_side == "inner";

module side_plate() {          // the y=0 side; the other side is mirrored
    // outer layer, with the hole's lead-in: a flat ramp on its inside face
    // from the rear (leading) edge down into the hole, parallel to the pin's
    // ramp, so the previous link's pin slides along it as they're pushed
    // together. It meets the inside face right at the hole's edge, so the
    // hole wall that takes the pull is untouched. Only on the round end:
    // the shoulders are the bend stops and stay square.
    difference() {
        slab(0, t) outer_profile();
        translate([-hole_d / 2, t, h]) rotate([0, 0, atan2(ramp_k, -1)])
            translate([0, -50, -50]) cube(100);
    }
    slab(t, 2 * t) inner_profile();
    // pin: from 1 mm inside the inner layer out through the next link's
    // outer layer. Its leading (+x) side is one flat ramp from the tip's
    // centreline down to pin_land above the root, so the next link's plate
    // rides up over it as the two are pushed together.
    translate([pitch, 0, h]) difference() {
        rotate([-90, 0, 0]) cylinder(d = pin_d, h = t + 1);
        // half-space x > ramp_k * y: through the tip's centre at y = 0
        rotate([0, 0, -atan(ramp_k)]) translate([0, -50, -50]) cube(100);
    }
}
module both_sides() {
    children();
    translate([0, width, 0]) mirror([0, 1, 0]) children();
}

// A top-side crossbar box (x0..x0+l, y0..y0+w, top at z = height) with its
// underside (channel-side) edges across the chain chamfered by bar_c.
module bar_box(x0, l, y0, w) {
    hull() {
        translate([x0, y0, height - bar_t + bar_c]) cube([l, w, bar_t - bar_c]);
        translate([x0 + bar_c, y0, height - bar_t]) cube([l - 2 * bar_c, w, bar_c]);
    }
}

// 45 deg fill of `gusset` in the inside corners under a top crossbar,
// where it meets the inner plates. Its ends follow the bar's bar_c end
// chamfers down, so the bar's ends stay one 45 deg face.
module bar_gussets() {
    zb = height - bar_t;
    intersection() {
        both_sides() translate([0, 2 * t, zb]) rotate([90, 0, 90])
            linear_extrude(pitch) polygon([[-0.01, 0.01], [gusset, 0.01], [-0.01, -gusset]]);
        hull() {
            translate([bar_x0, 0, zb + bar_c - 0.01]) cube([bar_x1 - bar_x0, width, 0.01]);
            translate([bar_x0 + bar_c + gusset, 0, zb - gusset])
                cube([bar_x1 - bar_x0 - 2 * (bar_c + gusset), width, 0.01]);
        }
    }
}

// Fixed crossbar on the top face, or the bottom one (bottom = true), with
// its gussets, trimmed to the inner plate profile so it clears the
// neighbors.
module fixed_bar(bottom) {
    intersection() {
        slab(t, width - t) inner_profile();
        flip_z(bottom) {
            bar_box(bar_x0, bar_x1 - bar_x0, t, width - 2 * t);
            bar_gussets();
        }
    }
}

// Cuts for the snap-in bar, top side: the ear seat in the inner plate's
// edge, and a shallow pocket in the inner plate's inside face that the barb
// catches in. Not a through-window: at this height (the pivot height) the
// outer layer is only ~14 mm long between its clearance arcs, and a window
// would cut it open at the front edge. Release by prying at the pry gap.
module bar_cuts_top() {
    both_sides() {
        // seat for the ear: fit at each end, so the ears stop the bar
        // sliding along the chain
        translate([bar_x0 - fit, t - 0.01, height - ear_t])
            cube([bar_x1 - bar_x0 + 2 * fit, t + 0.02, ear_t + 1]);
        // pry slot: behind the ear's rear end, in the seat's outer half
        // only, and 1 mm under the ear so a small screwdriver can lever it
        translate([bar_x0 - pry_gap, t - 0.01, height - ear_t - 1])
            cube([pry_gap + 1, pry_w + 0.01, ear_t + 2]);
        // pocket: the barb's catch slope bears on its top edge
        wz1 = height - bar_t - leg_l + barb_h - snap_preload;
        wz0 = height - bar_t - leg_l - 0.6;
        translate([(bar_x0 + bar_x1) / 2 - leg_w / 2 - 0.3, 2 * t - pocket_d, wz0])
            cube([leg_w + 0.6, pocket_d + 0.01, wz1 - wz0]);
    }
}

module link() {
    difference() {
        union() {
            both_sides() side_plate();
            fixed_bar(!open_bottom);
        }
        flip_z(open_bottom) bar_cuts_top();
        // outside long edges, for handling
        both_sides() for (z = [0, height])
            translate([pitch / 2, 0, z]) rotate([45, 0, 0])
                cube([pitch + 60, edge_c * sqrt(2), edge_c * sqrt(2)], center = true);
    }
}

// The snap-in bar, in link coordinates for the top side.
module bar_in_place() {
    bl = bar_x1 - bar_x0;
    // body between the inner plates
    bar_box(bar_x0, bl, 2 * t + fit, width - 4 * t - 2 * fit);
    // ears, resting on the seats (the barbs hold them down)
    translate([bar_x0, t + fit, height - ear_t])
        cube([bl, width - 2 * t - 2 * fit, ear_t]);
    // legs + barbs
    both_sides() {
        x0 = (bar_x0 + bar_x1) / 2 - leg_w / 2;
        ly = 2 * t + fit;
        zb = height - bar_t - leg_l;
        translate([x0, ly, zb]) cube([leg_w, leg_t, leg_l + 0.01]);
        // fill the body's chamfer above the leg, so the leg root is solid
        translate([bar_x0, ly, height - bar_t]) cube([bl, leg_t, bar_t]);
        // gusset from the body's underside down the leg's inner face. Full
        // length, like the leg, so the bar stays one profile on its end.
        translate([bar_x0, ly + leg_t, height - bar_t]) rotate([90, 0, 90])
            linear_extrude(bl) polygon([[-0.01, 0.01], [gusset, 0.01], [-0.01, -gusset]]);
        // barb: 45 deg lead-in below, barb_c catch slope on top (pry-able)
        translate([x0, ly, zb]) rotate([90, 0, 90]) linear_extrude(leg_w)
            polygon([[0, 0], [-barb_d, barb_d], [-barb_d, barb_h - barb_c], [0, barb_h]]);
    }
}
module bar() { flip_z(open_bottom) bar_in_place(); }

// The bar as printed: standing on its rear end face (x = bar_x0 on the
// bed), legs horizontal. Every layer is a full cross-section of the top,
// both legs and both barbs, so the legs flex along the layer lines, not
// across them (printed on its back, the legs snap off at a layer line).
// The flat end is 4 x 39 mm on the bed: add a brim if it tips.
module bar_print() {
    rotate([0, -90, 0]) translate([-bar_x0, 0, -height]) bar_in_place();
}

// The link with its provenance tag: an inlay in the face that prints on the
// bed (the fixed bar's outside face, flat across the full width there),
// reading from outside the chain.
module link_tagged() with_provenance() {
    link();
    tag_w = width - 2 * edge_c - 2;
    tag_h = bar_x1 - bar_x0 - 2;
    if (open_bottom)    // fixed bar on top: the top face prints down
        translate([(bar_x0 + bar_x1) / 2, width / 2, height]) rotate([0, 0, 90])
            provenance(w = tag_w, h = tag_h, mode = "inlay");
    else                // fixed bar on the bottom
        translate([(bar_x0 + bar_x1) / 2, width / 2, 0]) rotate([0, 180, 0]) rotate([0, 0, 90])
            provenance(w = tag_w, h = tag_h, mode = "inlay");
}
// The link as printed: removable side up, so the fixed bar (and the tag)
// is on the bed.
module link_print() {
    if (open_bottom) translate([0, 0, height]) rotate([180, 0, 0]) translate([0, -width, 0]) link_tagged();
    else link_tagged();
}

// Print layout: removable side up (no bridges, the fixed bar is on the bed),
// bar standing on its end next to it.
module print_layout() {
    link_print();
    translate([pitch + nose_r + 15, 0, 0]) bar_print();   // clear of the link
}

// A few links in a bent run (each turned by `a` about the previous pin).
module chain(n = 4, a = max_bend) {
    module step(i) {
        if (i < n) {
            color(i % 2 ? "SteelBlue" : "SlateGray") { link(); bar(); }
            translate([pitch, 0, h]) rotate([0, a, 0]) translate([0, 0, -h]) step(i + 1);
        }
    }
    step(0);
}
// Overlap of two neighbors (with their bars) at bend a: empty from
// flat_stop to max_bend. And of a link with its own bar: just the
// snap_preload slivers where the barbs bear on the pocket tops.
module check(a = max_bend) {
    intersection() {
        union() { link(); bar(); }
        translate([pitch, 0, h]) rotate([0, a, 0]) translate([0, 0, -h]) union() { link(); bar(); }
    }
}
module check_bar() { intersection() { link(); bar(); } }

if (part == "link") link();
else if (part == "bar") bar_print();
else if (part == "print") print_layout();
else if (part == "assembly") chain();
else if (part == "check") check(check_a);
else if (part == "check_bar") check_bar();
else if (part == "link_print") link_print();
