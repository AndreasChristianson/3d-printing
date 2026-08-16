// keyboard_lib.scad
// Reusable MX switch-plate geometry engine — the SHARED pieces only. Anything
// used by just one entry file lives in that file instead (sample.scad,
// preview.scad, assembly.scad). Parameters + geometry here; NO layout data
// (that's keyboard_layout.scad).
//
// For Gateron / Cherry MX-compatible switches (14.0 mm plate cutout, 19.05 mm pitch).
//
// ------------------------------------------------------------------ HOW TO USE
// Don't render this file directly. From an entry file:
//     use     <keyboard_lib.scad>      // just calling plate()/case()
//     include <keyboard_lib.scad>      // also need the parameters in scope
// `use` imports the modules/functions but NOT the parameters below; that's fine
// when you only call plate()/case() (each resolves its own params here). Files
// that define their own geometry (sample/preview/assembly) `include` instead so
// plate_t, U, etc. are visible to them.
//
// The shared part modules take your layout as ARGUMENTS (rather than reading
// globals) so the engine stays reusable across different boards.

$fn = 48;

/* ============================ BOARD / SWITCH ============================ */
board_w  = 16.5;       // KEY FIELD width  in U (extent the keys occupy)
board_h  = 6.75;       // KEY FIELD height in U
pad      = 0.25;       // padding added around the key field, per side, in U
U        = 19.05;      // 1U pitch (MX standard)
cutout   = 14.0;       // switch plate cutout (square), MX standard
plate_t    = 5.0;      // total plate thickness
clip_lip   = 1.5;      // top retention lip: 14 mm cutout only this deep (MX clips)
body_clear = 15.5;     // opening below the lip — switch body/clips clear here
corner_r   = 3;        // plate corner rounding (0 = square corners)

clip_notches = true;   // small side reliefs so switch clips grab the 1.5 mm lip
enc_hole_d   = 7.2;    // rotary encoder (EC11) shaft-bushing clearance hole

/* ---- case (case / assembly parts) ---- */
wall_t   = 3.0;        // outer wall thickness
floor_t  = 2.5;        // case floor thickness
inner_h  = 13.0;       // cavity depth below the plate (switch bodies + wiring)
ledge    = 3.0;        // inward shelf the plate rests on
plate_gap= 0.25;       // clearance around the plate where it drops into the case
usb_w    = 12.0;       // USB opening width  (back edge, +Y / function-row side)
usb_h    = 7.0;        // USB opening height
support_d = 4.0;       // support-post diameter (fits the ~5 mm row-boundary gaps)
seat_depth = 2.0;      // indent in the plate underside each post seats into
seat_d     = 3.0;      // registration peg diameter on top of each post
seat_fit   = 0.30;     // diametral clearance: the plate pocket is seat_d + seat_fit

/* ============================ ACCESSORS ============================ */
// key record: [ x, y, w, stab, "label" ]  (label accessor lives in preview.scad)
function kx(k) = k[0];
function ky(k) = k[1];
function kw(k) = k[2];
function ks(k) = k[3];

// key center in plate mm coords (origin at plate center; y up so row 0 is at top)
function key_cx(k) = (kx(k) + kw(k)/2 - board_w/2) * U;
function key_cy(k) = (board_h/2 - (ky(k) + 0.5)) * U;
// support-post center (given as [x,y] center in U field coords)
function sup_x(s) = (s[0] - board_w/2) * U;
function sup_y(s) = (board_h/2 - s[1]) * U;

// MX stabilizer stem spacing (mm, center-to-center) by width — approximate
function stab_span(w) = w >= 6 ? 100.0 : (w >= 2 ? 23.8 : 0);

/* ============================ GEOMETRY ============================ */
// stabilizer pockets (2D), centered at origin
module stab_2d(w) {
    span = stab_span(w);
    if (span > 0)
        for (sx = [-1, 1])
            translate([sx * span/2, -0.75]) square([7.0, 15.0], center = true);
}

// 3D stepped switch hole for a `plate_t`-thick plate, centered at origin:
//   top `clip_lip` mm  -> 14 mm square (+ clip notches): retains the MX clips
//   remainder (below)  -> `body_clear` opening: switch body + clips clear
//   stabilizer pockets -> full depth
module key_hole_3d(w, stab) {
    // retention lip at the TOP of the plate
    translate([0, 0, plate_t - clip_lip]) linear_extrude(clip_lip + 0.1) {
        square([cutout, cutout], center = true);
        if (clip_notches)
            for (sx = [-1, 1])
                translate([sx * cutout/2, 0]) square([1.0, cutout - 6], center = true);
    }
    // body relief below the lip, open through the bottom
    translate([0, 0, -0.1]) linear_extrude(plate_t - clip_lip + 0.1)
        square([body_clear, body_clear], center = true);
    // stabilizer pockets, full depth
    if (stab)
        translate([0, 0, -0.1]) linear_extrude(plate_t + 0.2) stab_2d(w);
}

// rounded rectangular plate blank, centered on the origin (key field + pad/side)
module plate_blank_2d() {
    w = (board_w + 2*pad) * U; h = (board_h + 2*pad) * U; r = max(corner_r, 0.001);
    translate([-w/2, -h/2])
        translate([r, r]) offset(r = r) square([w - 2*r, h - 2*r]);
}

/* ============================ PARTS ============================ */
// printable 5 mm plate with stepped switch cutouts (origin at plate center, z=0 bottom)
module plate(keys, encoders, supports) {
    color("SteelBlue")
    difference() {
        linear_extrude(plate_t) plate_blank_2d();
        for (k = keys)
            translate([key_cx(k), key_cy(k), 0]) key_hole_3d(kw(k), ks(k));
        for (e = encoders)
            translate([key_cx(e), key_cy(e), -0.1]) cylinder(d = enc_hole_d, h = plate_t + 0.2);
        // blind seat pockets in the underside (z=0) for the case support pegs
        for (s = supports)
            translate([sup_x(s), sup_y(s), -0.01])
                cylinder(d = seat_d + seat_fit, h = seat_depth + 0.01);
    }
}

// tray case: walls + perimeter ledge the plate drops onto, floor, USB slot, support posts
module case(supports) {
    H       = floor_t + inner_h + plate_t;      // total case height
    plate_hh = (board_h/2 + pad) * U;           // plate half-height (to back edge, +Y)
    color("Gainsboro")
    union() {
        difference() {
            linear_extrude(H) offset(r = wall_t) plate_blank_2d();               // outer shell
            translate([0,0,floor_t]) linear_extrude(H) offset(r = -ledge) plate_blank_2d(); // cavity (leaves ledge)
            translate([0,0,H - plate_t - plate_gap])                             // plate rebate (drop-in)
                linear_extrude(plate_t + plate_gap + 1) offset(r = plate_gap) plate_blank_2d();
            translate([0, plate_hh + wall_t/2, floor_t + inner_h/2])             // USB slot (back)
                cube([usb_w, wall_t*4, usb_h], center = true);
        }
        // support posts: full-diameter shaft to the plate underside, then a
        // registration peg that seats into the plate's indent (shoulder bears flush)
        for (s = supports)
            translate([sup_x(s), sup_y(s), floor_t]) {
                cylinder(d = support_d, h = inner_h);
                translate([0, 0, inner_h]) cylinder(d = seat_d, h = seat_depth - 0.3);
            }
    }
}
