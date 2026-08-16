// keyboard_plate.scad
// Hand-wired keyboard switch plate, built from an explicit per-key layout.
// You define every key; this renders a rectangular plate with the cutouts.
//
// For Gateron / Cherry MX-compatible switches (14.0 mm plate cutout, 19.05 mm pitch).
//
// ------------------------------------------------------------------ HOW TO USE
// Fill in the `keys` list below. Each key is:
//
//     [ x, y, w, stab, "label" ]
//
//   x, y   top-left corner of the key, in U, measured from the plate's
//          TOP-LEFT corner. y increases DOWNWARD (like keyboard-layout-editor).
//          Use 0.25U steps (e.g. 0, 0.25, 1.5, 15.5).
//   w      key width in U (1, 1.25, 1.5, 1.75, 2, 2.25, 2.75, 6.25, ...).
//          Height is always 1U.
//   stab   true if this key needs a stabilizer cutout (2U+ keys, spacebar).
//          The stabilizer size is derived from `w` automatically.
//   label  legend string, shown only in the "layout" review render.
//
// Rotary encoders go in the `encoders` list, using the SAME x, y, w grid units:
//
//     [ x, y, w, "label" ]
//
// An encoder cuts a round EC11 shaft hole (enc_hole_d) centered in its cell
// instead of a square switch cutout — no stab field.
//
// Board is a fixed rectangle: board_w x board_h (in U). Keys can sit anywhere on
// it in 0.25U steps — including intentional gaps for an "exploded" look.
//
// Preview:
//   openscad -o kbd.png --render --viewall --autocenter --imgsize=1600,780 \
//     --colorscheme=Tomorrow --camera=0,0,600,0,0,0,0 --projection=ortho \
//     -D 'part="layout"' keyboard_plate.scad

$fn = 48;

/* ============================ WHAT TO BUILD ============================ */
part = "plate";       // "plate" | "case" | "both" | "sample" | "layout" (review)

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

/* ---- case (part = "case" / "both") ---- */
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

/* ============================ LAYOUT ============================ */
// [ x, y, w, stab, "label" ]   -- see HOW TO USE above. Sample keys below
// exercise every field; replace them with your full layout.
keys = [
    // function row (top)
    [  0.00, 0.00, 1.00, false, "Esc" ],
    [  2.00, 0.00, 1.00, false, "F1"  ],
    [  3.00, 0.00, 1.00, false, "F2"  ],
    [  4.00, 0.00, 1.00, false, "F3"  ],
    [  5.00, 0.00, 1.00, false, "F4"  ],
    
    [  6.50, 0.00, 1.00, false, "F5"  ],
    [  7.50, 0.00, 1.00, false, "F6"  ],
    [  8.50, 0.00, 1.00, false, "F7"  ],
    [  9.50, 0.00, 1.00, false, "F8"  ],
    
    [ 11.00, 0.00, 1.00, false, "F9"  ],
    [ 12.00, 0.00, 1.00, false, "F10"  ],
    [ 13.00, 0.00, 1.00, false, "F11"  ],
    [ 14.00, 0.00, 1.00, false, "F12"  ],

    // number row — note the 0.25U vertical gap below the function row
    [  0.00, 1.25, 1.00, false, "`"    ],
    [  1.00, 1.25, 1.00, false, "1"    ],
    [  2.00, 1.25, 1.00, false, "2"    ],
    [  3.00, 1.25, 1.00, false, "3"    ],
    [  4.00, 1.25, 1.00, false, "4"    ],
    [  5.00, 1.25, 1.00, false, "5"    ],
    [  6.00, 1.25, 1.00, false, "6"    ],
    [  7.00, 1.25, 1.00, false, "7"    ],
    [  8.00, 1.25, 1.00, false, "8"    ],
    [  9.00, 1.25, 1.00, false, "9"    ],
    [ 10.00, 1.25, 1.00, false, "0"    ],
    [ 11.00, 1.25, 1.00, false, "-"    ],
    [ 12.00, 1.25, 1.00, false, "="    ],
    [ 13.00, 1.25, 2.00, true,  "Bksp" ],   // 2U key -> stabilizer

    // tab row
    [  0.00, 2.25, 1.50, false, "tab"  ],
    [  1.50, 2.25, 1.00, false, "q"    ],
    [  2.50, 2.25, 1.00, false, "w"    ],
    [  3.50, 2.25, 1.00, false, "e"    ],
    [  4.50, 2.25, 1.00, false, "r"    ],
    [  5.50, 2.25, 1.00, false, "t"    ],
    [  6.50, 2.25, 1.00, false, "y"    ],
    [  7.50, 2.25, 1.00, false, "u"    ],
    [  8.50, 2.25, 1.00, false, "i"    ],
    [  9.50, 2.25, 1.00, false, "o"    ],
    [ 10.50, 2.25, 1.00, false, "p"    ],
    [ 11.50, 2.25, 1.00, false, "["    ],
    [ 12.50, 2.25, 1.00, false, "]"    ],
    [ 13.50, 2.25, 1.50, false,  "\\"  ], 
    
    // caps lock row
    [  0.00, 3.25, 1.75, false, "caps" ],
    [  1.75, 3.25, 1.00, false, "a"    ],
    [  2.75, 3.25, 1.00, false, "s"    ],
    [  3.75, 3.25, 1.00, false, "d"    ],
    [  4.75, 3.25, 1.00, false, "f"    ],
    [  5.75, 3.25, 1.00, false, "g"    ],
    [  6.75, 3.25, 1.00, false, "h"    ],
    [  7.75, 3.25, 1.00, false, "j"    ],
    [  8.75, 3.25, 1.00, false, "k"    ],
    [  9.75, 3.25, 1.00, false, "l"    ],
    [ 10.75, 3.25, 1.00, false, ";"    ],
    [ 11.75, 3.25, 1.00, false, "'"    ],
    [ 12.75, 3.25, 2.25, true , "enter"],
    
    // shift row
    [  0.00, 4.25, 2.25, true, "shift" ],
    [  2.25, 4.25, 1.00, false, "z"    ],
    [  3.25, 4.25, 1.00, false, "x"    ],
    [  4.25, 4.25, 1.00, false, "c"    ],
    [  5.25, 4.25, 1.00, false, "v"    ],
    [  6.25, 4.25, 1.00, false, "b"    ],
    [  7.25, 4.25, 1.00, false, "n"    ],
    [  8.25, 4.25, 1.00, false, "m"    ],
    [  9.25, 4.25, 1.00, false, ","    ],
    [ 10.25, 4.25, 1.00, false, "."    ],
    [ 11.25, 4.25, 1.00, false, "/"    ],
    [ 12.25, 4.25, 1.75, false, "shift"],
    
    // ctrl row
    [  0.00, 5.25, 1.25, false, "ctrl" ],
    [  1.25, 5.25, 1.25, false, "win"  ],
    [  2.50, 5.25, 1.25, false, "alt"  ],
    [  3.75, 5.25, 6.25, true,  "Space"],
    [ 10.00, 5.25, 1.50, false, "atl"  ],
    [ 11.50, 5.25, 1.50, false, "crtl" ],
    
    // arrows
    [  13.50, 5.75, 1.00, false, "<"   ],
    [  14.50, 4.75, 1.00, false, "^"   ],
    [  15.50, 5.75, 1.00, false, ">"   ],
    [  14.50, 5.75, 1.00, false, "v"   ],


    // nav-cluster
    [ 15.50, 1.25, 1.00, false, "home" ],
    [ 15.50, 2.25, 1.00, false, "end" ],
    [ 15.50, 3.25, 1.00, false, "del" ],
];

// ROTARY ENCODERS — same x, y, w grid units as keys. [ x, y, w, "label" ]
encoders = [
    [ 15.50, 0.00, 1.00, "Vol" ],
];

// SUPPORT POSTS — hold the plate up from the case floor. [ x, y ] = post CENTER
// in the same U field coords. Placed in the row-boundary / gap lanes (y) across
// the main block (x) so they miss the switch bodies below. 3 rows x 6 columns.
supports = [
    [ 1.00, 1.12 ], [ 3.40, 1.12 ], [ 5.80, 1.12 ], [ 8.20, 1.12 ], [ 10.60, 1.12 ], [ 13.00, 1.12 ],
    [ 1.00, 3.25 ], [ 3.40, 3.25 ], [ 5.80, 3.25 ], [ 8.20, 3.25 ], [ 10.60, 3.25 ], [ 13.00, 3.25 ],
    [ 1.00, 5.25 ], [ 3.40, 5.25 ], [ 5.80, 5.25 ], [ 8.20, 5.25 ], [ 10.60, 5.25 ], [ 13.00, 5.25 ],
    // right side: the clear lane between the main block and the nav column,
    // plus one in the ctrl/arrow gap
    [ 15.10, 1.12 ], [ 15.10, 3.25 ], [ 15.10, 5.75 ]
];

/* ---- bill of materials / dimensions (printed on render) ---- */
echo(str("Switches needed (MX): ", len(keys)));
echo(str("Rotary encoders (EC11): ", len(encoders)));
echo(str("Support posts: ", len(supports)));
echo(str("Case height (mm): ", floor_t + inner_h + plate_t,
         "  | walls ", wall_t, "  floor ", floor_t, "  plate ", plate_t));

/* ============================ ENGINE ============================ */
// field accessors
function kx(k) = k[0];
function ky(k) = k[1];
function kw(k) = k[2];
function ks(k) = k[3];
function kl(k) = k[4];
function el(e) = e[3];   // encoder label ([x,y,w,"label"])

// key center in plate mm coords (origin at plate center; y up so row 0 is at top)
function key_cx(k) = (kx(k) + kw(k)/2 - board_w/2) * U;
function key_cy(k) = (board_h/2 - (ky(k) + 0.5)) * U;
// support-post center (given as [x,y] center in U field coords)
function sup_x(s) = (s[0] - board_w/2) * U;
function sup_y(s) = (board_h/2 - s[1]) * U;

// MX stabilizer stem spacing (mm, center-to-center) by width — approximate
function stab_span(w) = w >= 6 ? 100.0 : (w >= 2 ? 23.8 : 0);

// 2D top opening (retention lip footprint) — used by the flat "layout" review
module key_cut_2d(w, stab) {
    square([cutout, cutout], center = true);
    if (clip_notches)
        for (sx = [-1, 1])
            translate([sx * cutout/2, 0]) square([1.0, cutout - 6], center = true);
    span = stab_span(w);
    if (stab && span > 0)
        for (sx = [-1, 1])
            translate([sx * span/2, -0.75]) square([7.0, 15.0], center = true);
}

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

module cutouts_2d() {
    for (k = keys)
        translate([key_cx(k), key_cy(k)]) key_cut_2d(kw(k), ks(k));
    for (e = encoders)
        translate([key_cx(e), key_cy(e)]) circle(d = enc_hole_d);
}

// keycap outline + legend for the "layout" review render
module labels_2d() {
    for (k = keys)
        translate([key_cx(k), key_cy(k)]) {
            difference() {
                square([kw(k)*U - 1, U - 1], center = true);
                square([kw(k)*U - 3, U - 3], center = true);
            }
            text(kl(k), size = 3.2, halign = "center", valign = "center", $fn = 16);
        }
    for (e = encoders)
        translate([key_cx(e), key_cy(e)]) {
            difference() { circle(d = U - 1, $fn = 40); circle(d = U - 3, $fn = 40); }
            circle(d = enc_hole_d, $fn = 32);            // shaft hole marker
            text(el(e), size = 2.6, halign = "center", valign = "center", $fn = 16);
        }
}

/* ============================ PARTS ============================ */
// printable 5 mm plate with stepped switch cutouts (origin at plate center, z=0 bottom)
module plate() {
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
module case() {
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

// single-switch test coupon: one stepped cutout in a small handleable square,
// same plate_t / clip_lip / body_clear as the real plate — print to check fit
module sample() {
    s = U + 12;   // coupon side (~31 mm)
    color("SteelBlue")
    difference() {
        linear_extrude(plate_t)
            offset(r = corner_r) square([s - 2*corner_r, s - 2*corner_r], center = true);
        key_hole_3d(1.0, false);
    }
}

module layout_view() {
    color("SteelBlue") linear_extrude(1) difference() { plate_blank_2d(); cutouts_2d(); }
    color("black")     translate([0,0,1]) linear_extrude(0.6) labels_2d();
}

/* ============================ ASSEMBLY ============================ */
if      (part == "plate")  plate();
else if (part == "case")   case();
else if (part == "both")   { case(); translate([0,0,floor_t + inner_h]) plate(); }
else if (part == "sample") sample();
else                       layout_view();
