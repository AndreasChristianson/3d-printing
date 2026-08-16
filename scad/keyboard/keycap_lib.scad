// keycap_lib.scad
// Printable MX keycaps: dished top + recessed (engraved) legends. One module
// drives every size — a cap is a width in U (all caps are 1U tall). Shared
// engine only; entry files are keycap_sample.scad (one blank fit-test cap) and
// keycaps.scad (the full labeled set from keyboard_layout.scad).
//
// PRINT ORIENTATION: top-face DOWN on the bed, skirt + stem pointing up. The
// cross socket prints as a clean vertical hole with no supports. The dish is
// shallow so its first-layer bridge is short; for the crispest top face a resin
// printer or a light support in the dish helps.
//
// ------------------------------------------------------------------ HOW TO USE
//     include <keycap_lib.scad>
//     keycap(1.00);                              // 1U blank
//     keycap(2.25, stab = true, label = "enter");// stabilized + engraved legend

$fn = 48;

/* ============================ CAP BODY ============================ */
U         = 19.05;     // 1U pitch (matches the plate)
kc_gap    = 1.05;      // gap between adjacent 1U caps -> footprint = w*U - kc_gap
cap_h     = 9.0;       // cap height (skirt bottom to top surface)
top_t     = 2.5;       // roof thickness under the top surface (before the dish)
wall      = 1.6;       // skirt wall thickness
top_inset = 1.0;       // per-side taper: top face is this much smaller than base
kc_corner = 1.5;       // footprint corner radius
edge_round = 1.6;      // radius that blunts the top + side edges (0 = sharp)

/* ---- top dish (concave scoop) ---- */
// The dish is sized so its curve spans the WHOLE top and rises to meet the top
// edges (chord = top width), rather than a small pit in a flat shelf. Math is
// the standard keycap-dish derivation used by KeyV2.
dish_type    = "cylindrical";  // "cylindrical" (left-right trough, Cherry/OEM feel)
                               // or "spherical" (bowl, DSA/SA feel)
dish_depth   = 1.3;            // scoop depth at center
dish_overdraw = 1.5;           // extend dish past the top edge to soften the rim

/* ============================ LEGENDS ============================ */
legend_depth = 0.6;    // how deep the engraved legend is cut (uniform, follows the dish)
legend_max   = 3.2;    // max legend size (mm) for multi-char / shifted keys
legend_single = 5.0;   // larger legend size for single-letter caps (no shift)
legend_margin = 1.6;   // inset of the legends from the top-face edges
shift_scale  = 0.85;   // shift legend size relative to the primary
legend_font  = "Liberation Sans:style=Bold";

/* ---- homing marks (RAISED tactile bar on F & J) ---- */
homing_w     = 4.0;    // width of the homing bar
homing_h     = 0.9;    // thickness (front-back) of the homing bar
homing_y     = 2.4;    // distance of the bar in front of center (toward the user)
homing_rise  = 0.5;    // how far the bar stands proud of the top surface

/* ============================ MX STEM ============================ */
stem_d      = 5.5;     // cylindrical boss the cross socket is cut into
cross_len   = 4.1;     // length of each arm of the + socket
cross_w     = 1.35;    // width of each arm (TUNE FOR FIT: bigger = looser)
cross_depth = 4.2;     // how deep the switch stem sinks into the cap

/* ============================ HELPERS ============================ */
function cap_x(w) = w * U - kc_gap;   // footprint width  for a w-U cap
function cap_y()  = U - kc_gap;       // footprint depth  (always 1U)

// MX plate-mount stabilizer stem spacing by width (mm, center-to-center)
function kc_stab_span(w) = w >= 6 ? 100.0 : (w >= 2 ? 23.8 : 0);

// legend size that keeps the text inside the cap width. Single-letter caps with
// no shift legend get the larger `legend_single` size.
function legend_size(w, label, big = false) =
    min(big ? legend_single : legend_max,
        (cap_x(w) - 3) / (0.62 * max(len(label), 1)));

// Title Case: capitalize the first letter of each word, lowercase the rest.
// (single-letter labels become uppercase: "q" -> "Q", "tab" -> "Tab")
function _up(c)  = let(o = ord(c)) (o >= 97 && o <= 122) ? chr(o - 32) : c;
function _lo(c)  = let(o = ord(c)) (o >= 65 && o <=  90) ? chr(o + 32) : c;
function _is_sp(c) = c == " ";
function _tc(s, i, start) = i >= len(s) ? "" :
    str(start ? _up(s[i]) : _lo(s[i]), _tc(s, i + 1, _is_sp(s[i])));
function title_case(s) = _tc(s, 0, true);

module rrect(x, y, r) { offset(r = r) square([x - 2*r, y - 2*r], center = true); }

// the + socket that presses onto the switch stem, opening upward from z = 0
module mx_cross_socket() {
    translate([0, 0, -0.01]) linear_extrude(cross_depth + 0.01) {
        square([cross_len, cross_w], center = true);
        square([cross_w, cross_len], center = true);
    }
}

// a stem boss with its cross socket, centered at the origin
module stem() {
    difference() {
        cylinder(d = stem_d, h = cap_h - top_t + 0.6);   // pokes into the roof to fuse
        mx_cross_socket();
    }
}

// concave top dish that spans the WHOLE top and meets the top edges, so there
// is no flat shelf or pit rim. Sized from the top face so the curve's chord
// equals the top width (cylindrical) or diagonal (spherical); it digs
// `dish_depth` at center and rises back to the edges.
module dish_cut(w) {
    // the dish sphere/cylinder is large (tens of mm); the global $fn=48 would
    // facet it coarsely into a tiny polygon pit, so switch to $fa/$fs here.
    $fn = 0; $fa = 2; $fs = 0.4;

    // top face size after the taper, plus a little overdraw to soften the rim
    tw = cap_x(w) - 2*top_inset + dish_overdraw;   // top width
    td = cap_y()  - 2*top_inset + dish_overdraw;   // top depth
    d  = dish_depth;

    if (dish_type == "spherical") {
        chord = sqrt(tw*tw + td*td);               // reach the corners
        rad   = (chord*chord + 4*d*d) / (8*d);
        clen  = (chord*chord - 4*d*d) / (8*d);
        translate([0, 0, cap_h + clen]) sphere(r = rad);
    } else { // cylindrical: a trough curving across the width (left-right)
        rad  = (tw*tw + 4*d*d) / (8*d);
        clen = (tw*tw - 4*d*d) / (8*d);
        translate([0, 0, cap_h + clen])
            rotate([90, 0, 0]) cylinder(h = td + 20, r = rad, center = true);
    }
}

// 2D legend marks. With a shift legend: shift upper-left, primary lower-left.
// Without: a single (larger, for single letters) primary in the upper-left.
module marks_2d(w, label, shift) {
    ax    = -(cap_x(w)/2 - top_inset - legend_margin);   // left edge
    ay_top =  cap_y()/2 - top_inset - legend_margin;      // upper row
    ay_bot = -(cap_y()/2 - top_inset - legend_margin);    // lower row
    ptxt = title_case(label);
    if (shift != "") {
        psize = legend_size(w, ptxt);
        translate([ax, ay_top]) text(title_case(shift), size = psize * shift_scale,
                     font = legend_font, halign = "left", valign = "top", $fn = 24);
        translate([ax, ay_bot]) text(ptxt, size = psize,
                     font = legend_font, halign = "left", valign = "bottom", $fn = 24);
    } else if (label != "") {
        big = len(ptxt) == 1;                            // single letter -> larger
        translate([ax, ay_top]) text(ptxt, size = legend_size(w, ptxt, big),
                     font = legend_font, halign = "left", valign = "top", $fn = 24);
    }
}

// a thin shell of uniform thickness `t` just below the top surface, so engraving
// into it reads at a constant depth even where the top is curved
module top_shell(w, t, flat) {
    if (flat) {
        translate([0, 0, cap_h - t])
            linear_extrude(t + 2) rrect(cap_x(w) + 2, cap_y() + 2, 0.1);
    } else {
        difference() {
            translate([0, 0, -t]) dish_cut(w);   // lowered dish surface
            dish_cut(w);                          // actual dish surface
        }
    }
}

// a thin shell of thickness `t` just ABOVE the top surface, following it — used
// to grow the raised homing bar to a uniform height over the curved top
module above_shell(w, t, flat) {
    if (flat) {
        translate([0, 0, cap_h]) linear_extrude(t) rrect(cap_x(w) + 2, cap_y() + 2, 0.1);
    } else {
        difference() {
            dish_cut(w);                          // actual dish surface
            translate([0, 0, t]) dish_cut(w);     // raised dish surface
        }
    }
}

// engrave the legends to a uniform depth that follows the dished top
module engrave(w, label, shift, flat) {
    if (label != "" || shift != "") {
        intersection() {
            translate([0, 0, cap_h - 3]) linear_extrude(6) marks_2d(w, label, shift);
            top_shell(w, legend_depth, flat);
        }
    }
}

// RAISED homing bar, standing homing_rise proud of the top, following its curve
module homing_bump(w, flat) {
    intersection() {
        translate([0, -homing_y, 0]) linear_extrude(cap_h + homing_rise + 2)
            offset(r = homing_h/2) square([max(homing_w - homing_h, 0.1), 0.001], center = true);
        above_shell(w, homing_rise, flat);
    }
}

// tapered outer body, with the top + side edges blunted by edge_round.
// A convex hull minkowski'd with a small sphere, trimmed flat at the base.
module rounded_body(w) {
    r = edge_round;
    x = cap_x(w); y = cap_y();
    module body(sx, sy, sh) {   // hull between base and (smaller) top face
        hull() {
            linear_extrude(0.01) rrect(x - 2*sx, y - 2*sy, kc_corner);
            translate([0, 0, cap_h - sh - 0.01])
                linear_extrude(0.01) rrect(x - 2*top_inset - 2*sx, y - 2*top_inset - 2*sy, kc_corner);
        }
    }
    if (r <= 0) {
        body(0, 0, 0);
    } else {
        intersection() {
            minkowski() { body(r, r, r); sphere(r, $fn = 16); }
            translate([0, 0, (cap_h + 10)/2])
                cube([x + 4*r + 10, y + 4*r + 10, cap_h + 10], center = true);   // flat base
        }
    }
}

// hollow interior, open at the bottom
module cavity(w) {
    translate([0, 0, -0.01])
        linear_extrude(cap_h - top_t + 0.01)
            rrect(cap_x(w) - 2*wall, cap_y() - 2*wall, kc_corner);
}

/* ============================ KEYCAP ============================ */
// w      key width in U
// stab   true adds stabilizer stem sockets for 2U+ caps
// label  primary legend, engraved top-left (Title Cased automatically)
// shift  secondary (shifted) legend, engraved under the primary
// flat   true leaves the top flat (no dish) — used for the spacebar
// homing true adds a RAISED tactile homing bar (F & J)
module keycap(w, stab = false, label = "", shift = "", flat = false, homing = false) {
    color("Khaki") union() {
        difference() {
            rounded_body(w);
            if (!flat) dish_cut(w);
            cavity(w);
            engrave(w, label, shift, flat);
        }
        // raised home-row bar
        if (homing) homing_bump(w, flat);
        // central switch stem
        stem();
        // stabilizer stem sockets (wide keys ride a plate-mount stabilizer)
        span = kc_stab_span(w);
        if (stab && span > 0)
            for (sx = [-1, 1]) translate([sx * span/2, 0, 0]) stem();
    }
}
