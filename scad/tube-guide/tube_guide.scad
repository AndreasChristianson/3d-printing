// tube_guide.scad
// Bowden guide for the AFC tube on the Kobra Max left Z carriage. It bolts to
// the old runout-sensor tab (tapped M3) and holds ONE continuous PTFE run, so
// there's no coupler joint for a cut tip to snag on. The tube is gripped by a
// light pinch clamp that PIVOTS on the post, so its angle follows the tube:
// flatter with the toolhead far +X, steeper far -X.
//
// Built around kobra_xmotor_env.scad (same axes; origin = the tab's M3 hole).
//
// Two printed parts:
//   post  - keyed foot + post. M3x6 SHCS into the tab, driven down the post's
//           bore with a hex key. Prints foot down.
//   clamp - pivoting pinch clamp. Prints on its post-side face.
// Hardware: M3x6 SHCS (tab), M3x30 SHCS + M3 nyloc (pivot; snug it until the
//           clamp swings without flopping), M3x12 SHCS + M3 nut (pinch).
//
// Renders:
//   openscad -o tube_guide_post.stl  -D 'part="post"'  tube_guide.scad
//   openscad -o tube_guide_clamp.stl -D 'part="clamp"' tube_guide.scad
//   openscad -o fit_iso.png --render --imgsize=1200,900 --colorscheme=Tomorrow \
//     --camera=-10,0,20,65,0,200,280 tube_guide.scad

include <kobra_xmotor_env.scad>
env_standalone = false;

part = "fit";   // "post" | "clamp" | "fit"

/* ---------- Fit ---------- */
clr       = 0.2;
key_w     = tab_in_w - 2 * clr;     // slides between the tab walls (anti-rotation)
key_h     = wall_h + 0.3;           // key bottoms on the tab; ledge clears the wall tops
floor_z   = 3.5;                    // M3 head seat height; 3.5 + 1.5 sheet -> M3x6
bore_d    = 6.4;                    // passes the M3 head down the post

/* ---------- Post ---------- */
post_x0   = -12;                    // outboard face (past the tab end, well inside the motor)
post_x1   = tab_x1 - 0.5;           // inboard face, at the gantry plate edge
post_y    = 7;                      // half-width in Y
pivot     = [-7.5, 36];             // pivot axis (x, z); runs along Y
post_top  = pivot[1] + 6;
nyloc_af  = 5.7;                    // M3 nyloc across flats (+clr)
nyloc_h   = 4;
post_ch   = 1.5;                    // edge chamfer
win_x     = [-10, -5.2];            // lightening window through the post (Y), outboard of the bore
win_z     = [9, 29];
xwin_y    = 3.5;                    // see-through window across the post (X); narrower than the
xwin_z    = [11, 27];               //   M3 head so the screw can't fall out of the bore

/* ---------- Clamp ---------- */
// Local clamp frame: +Z along the tube (rising inboard), +X across it toward the
// pivot side, Y = world Y. The tube sits at the local origin.
gap       = 0.4;                    // clamp <-> post face
chan_d    = tube_od + 0.3;          // slides when the pinch screw is loose
blk_len   = 26;                     // along the tube
blk_back  = 5;                      // bore -> post-side face (hinge)
blk_front = 9.5;                    // bore -> slotted face
blk_x0    = -5;                     // pinched jaw
blk_x1    = 10;                     // pivot jaw
piv_off   = 6.5;                    // tube axis -> pivot axis, local +X
slot_w    = 1.0;
pinch_y   = 5.5;                    // pinch screw offset from the bore, along Y
pinch_z   = 7;                      // ... and along the tube, clear of the pivot
flare_d   = 7.5;
flare_len = 4;
nut_af    = 5.7;                    // M3 nut across flats (+clr)
blk_ch    = 1;                      // edge chamfer
bwin_x    = [4, 8];                 // lightening window through the pivot jaw (Y)
bwin_z    = [-10.5, -4.5];

tube_y    = post_y + gap + blk_back;   // world Y of the tube centreline

// Box with chamfered edges; cb = bottom-edge chamfer (0 keeps a sharp bed face).
module cbox(size, c, cb = undef) {
    b = is_undef(cb) ? c : cb;
    hull() {
        translate([c, c, b]) cube([size[0] - 2 * c, size[1] - 2 * c, size[2] - b - c]);
        translate([c, 0, b]) cube([size[0] - 2 * c, size[1], size[2] - b - c]);
        translate([0, c, b]) cube([size[0], size[1] - 2 * c, size[2] - b - c]);
        translate([c, c, 0]) cube([size[0] - 2 * c, size[1] - 2 * c, size[2]]);
    }
}

// Rounded-end slot from (x0, z0) to (x1, z1), cut through Y.
module stadium_y(xr, zr, len = 60) {
    r = (xr[1] - xr[0]) / 2;
    hull() for (z = [zr[0] + r, zr[1] - r])
        translate([xr[0] + r, 0, z]) rotate([90, 0, 0]) cylinder(r = r, h = len, center = true);
}

// Clamp frame at tube angle a: the pivot stays put, the tube swings around it.
module at_clamp(a = tube_angle) {
    translate([pivot[0], tube_y, pivot[1]]) rotate([0, 90 - a, 0])
        translate([-piv_off, 0, 0]) children();
}

function tube_point(a = tube_angle) =
    [pivot[0] - piv_off * cos(90 - a), tube_y, pivot[1] + piv_off * sin(90 - a)];

module clamp() {
    difference() {
        translate([blk_x0, -blk_back, -blk_len / 2])
            cbox([blk_x1 - blk_x0, blk_back + blk_front, blk_len], blk_ch);
        stadium_y(bwin_x, bwin_z);
        // tube channel with flared entries both ends
        translate([0, 0, -50]) cylinder(d = chan_d, h = 100);
        for (s = [-1, 1]) translate([0, 0, s * blk_len / 2])
            rotate([s > 0 ? 0 : 180, 0, 0]) translate([0, 0, -flare_len])
                cylinder(d1 = chan_d, d2 = flare_d, h = flare_len + 0.01);
        // pinch slot: from the bore out through the front face
        translate([-slot_w / 2, 0, -50]) cube([slot_w, 30, 100]);
        // pinch screw across the slot: head on the pinched jaw, nut in the pivot jaw
        translate([0, pinch_y, pinch_z]) rotate([0, 90, 0]) {
            cylinder(d = 3.4, h = 40, center = true);
            translate([0, 0, blk_x0 - 10 + 2]) cylinder(d = 6.0, h = 10);
            translate([0, 0, 6]) cylinder(d = nut_af / cos(30), h = 10, $fn = 6);
        }
        // pivot bolt, along Y; head counterbored in the front face
        translate([piv_off, 0, 0]) rotate([-90, 0, 0]) {
            translate([0, 0, -20]) cylinder(d = 3.4, h = 40);
            translate([0, 0, blk_front - 2]) cylinder(d = 6.0, h = 10);
        }
    }
}

module post() {
    difference() {
        union() {
            // key between the walls + ledge over the wall tops, then the post
            translate([tab_x0 + clr, -key_w / 2, 0]) cube([post_x1 - tab_x0 - clr, key_w, key_h + 0.01]);
            translate([post_x0, -post_y, key_h])
                cbox([post_x1 - post_x0, 2 * post_y, post_top - key_h], post_ch, 0);
        }
        stadium_y(win_x, win_z);
        rotate([0, 0, 90]) stadium_y([-xwin_y / 2, xwin_y / 2], xwin_z);
        // lead-in for the screw + hex key at the top of the bore
        translate([0, 0, post_top - 1.5]) cylinder(d1 = bore_d, d2 = bore_d + 3, h = 1.51);
        // M3 into the tab, and the access bore down the post for head + key
        translate([0, 0, -1]) cylinder(d = 3.4, h = 10);
        translate([0, 0, floor_z]) cylinder(d = bore_d, h = 100);
        // pivot bolt through the post, nyloc recessed in the front face
        translate([pivot[0], 0, pivot[1]]) rotate([-90, 0, 0]) {
            translate([0, 0, -20]) cylinder(d = 3.4, h = 40);
            translate([0, 0, -post_y - 1]) cylinder(d = nyloc_af / cos(30), h = nyloc_h + 1, $fn = 6);
        }
    }
}

if (part == "post") {
    post();
} else if (part == "clamp") {
    // print on the post-side face
    rotate([90, 0, 0]) translate([0, blk_back, 0]) clamp();
} else {
    env();
    color("Orange") post();
    color("Gold") at_clamp() clamp();
    // swing range, ghosted
    for (a = [20, 80]) %at_clamp(a) clamp();
    tube_path(tube_point());
}
