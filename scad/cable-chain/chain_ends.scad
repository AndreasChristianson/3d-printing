// chain_ends.scad
// Mounting ends for the chain_link.scad chains on the Kobra Max.
//
// Each end is half a link (the same plate profiles, so it bends and stops
// like a link) with a mount where the other half would be:
//   "pin"  end: a link's front half, pin at x = pitch; the chain's first
//               link hangs its rear hole on it. The mount is on the -x side.
//   "hole" end: a link's rear half, hole at x = 0; the chain's last link
//               pins into it. The mount is on the +x side.
// The chain runs pin end -> hole end, so each chain has one of each.
//
// end = "x_bottom"   X chain, fixed end: plate on the gantry's left end
//                    plate, under where the cables come out. 4x M3 on
//                    38.6 x 20, same as the old part. Pin end.
//     | "x_toolhead" X chain, moving end: sits on the toolhead's top
//                    bracket, 2x M3 in line along the chain, 12 mm apart
//                    (the old 100% "Fixed end 2 holes", printed at 150%).
//                    Hole end.
// part = "end" (as printed) | "in_place" (link frame) | "end_check" (overlap
//      with the neighbor link at bend check_a: renders empty when clear)
//      | "end_asm" (the end and its neighbor at check_a). Not "check" or
//      "assembly": chain_link.scad would render its own as well.
//
// Frame: chain_link.scad's link frame (x along the chain, y across, z the
// bend direction, the chain bends toward z = 0).

// `end` comes before the include: chain_link.scad's `chain` is evaluated
// where it's first defined, and this file's override of it reads `end`.
end   = "x_bottom";
include <chain_link.scad>
part  = "end";
chain = end == "x_bottom" || end == "x_toolhead" ? "x" : "z";

m3_d     = 3.4;    // M3 clearance
m3_head  = 6.0;    // counterbore for an M3 socket head
m3_head_h = 3.2;

// A link's plates between x0 and x1, edges chamfered like the link.
module link_plates(x0, x1) {
    difference() {
        intersection() {
            both_sides() side_plate();
            translate([x0, -1, -1]) cube([x1 - x0, width + 2, height + 2]);
        }
        both_sides() for (z = [0, height])
            translate([pitch / 2, 0, z]) rotate([45, 0, 0])
                cube([pitch + 60, edge_c * sqrt(2), edge_c * sqrt(2)], center = true);
    }
}

// The fixed side of the link: z = height when the chain opens on the inside
// (X), z = 0 when it opens on the outside (Z).
fixed_z0 = open_bottom ? height - bar_t : 0;

// ---------- X chain, fixed end (pin end) ----------

xb_face  = 16.4;   // pivot to the mounting face, as on the old part
xb_t     = 5;      // plate thickness
xb_h     = 48.6;   // plate height (z), as on the old part
xb_holes = [20, 38.6];   // hole spacing [y, z], centred on the chain

module x_bottom() {
    xf = pitch - xb_face;          // mounting face
    xp = xf + xb_t;                // chain side of the plate
    difference() {
        union() {
            link_plates(xp - 0.01, pitch + nose_r + 1);
            // floor on the fixed side, between the plates, out to the pin
            intersection() {
                slab(t, width - t) inner_profile();
                translate([xp - 0.01, 0, fixed_z0]) cube([pitch - xp, width, bar_t]);
            }
            // plate, its outside edges chamfered
            hull() {
                translate([xf, edge_c, h - xb_h / 2]) cube([xb_t, width - 2 * edge_c, xb_h]);
                translate([xf, 0, h - xb_h / 2 + edge_c]) cube([xb_t, width, xb_h - 2 * edge_c]);
            }
        }
        for (sy = [-1, 1], sz = [-1, 1])
            translate([xf - 1, width / 2 + sy * xb_holes[0] / 2, h + sz * xb_holes[1] / 2])
                rotate([0, 90, 0]) cylinder(d = m3_d, h = xb_t + 2, $fn = 32);
    }
}
// Its tag: inlaid in the mounting face (on the bed), between the holes.
module x_bottom_tag() {
    translate([pitch - xb_face, width / 2, h]) rotate([0, -90, 0]) rotate([0, 0, 90])
        provenance(w = width - 4, h = xb_holes[1] - m3_head - 4, mode = "inlay");
}
// As printed: mounting face on the bed.
module x_bottom_print() {
    rotate([0, -90, 0]) translate([-(pitch - xb_face), 0, 0])
        with_provenance() { x_bottom(); x_bottom_tag(); }
}

// ---------- X chain, toolhead end (hole end) ----------

xt_holes = [14.8, 26.8];  // pivot to the holes along the chain (the old
                          //   end's 9.87 / 17.87 at 150%)
xt_floor = 6;      // floor thickness, on the inside of the bend (z = 0)
xt_x0    = 11;     // floor starts here: the previous link's front corner
                   //   sweeps in to x ~10 at the floor's height
xt_x1    = xt_holes[1] + 5;

module x_toolhead() {
    difference() {
        union() {
            // the plates, short of the inner layer's front nose
            link_plates(-nose_r - 1, pitch - nose_r - 1);
            // floor, full width
            hull() {
                translate([xt_x0, edge_c, 0]) cube([xt_x1 - xt_x0, width - 2 * edge_c, xt_floor]);
                translate([xt_x0, 0, edge_c]) cube([xt_x1 - xt_x0, width, xt_floor - edge_c]);
            }
        }
        for (x = xt_holes) translate([x, width / 2, 0]) {
            translate([0, 0, -1]) cylinder(d = m3_d, h = xt_floor + 2, $fn = 32);
            translate([0, 0, xt_floor - m3_head_h]) cylinder(d = m3_head, h = 10, $fn = 48);
        }
    }
}
// As printed: floor on the bed.
module x_toolhead_print() { x_toolhead(); }

// ---------- dispatch ----------

module end_in_place() {
    if (end == "x_bottom") x_bottom();
    else if (end == "x_toolhead") x_toolhead();
}
end_is_pin = end == "x_bottom";

// The neighbor link (with its bar) at bend a, in the end's frame.
module neighbor(a) {
    if (end_is_pin)
        translate([pitch, 0, h]) rotate([0, a, 0]) translate([0, 0, -h]) { link(); bar(); }
    else
        translate([0, 0, h]) rotate([0, -a, 0]) translate([-pitch, 0, -h]) { link(); bar(); }
}

if (part == "end") {
    if (end == "x_bottom") x_bottom_print();
    else if (end == "x_toolhead") x_toolhead_print();
}
else if (part == "in_place") end_in_place();
else if (part == "end_check") intersection() { end_in_place(); neighbor(check_a); }
else if (part == "end_asm") { color("SlateGray") end_in_place(); color("SteelBlue") neighbor(check_a); }
