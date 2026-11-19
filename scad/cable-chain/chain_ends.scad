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
// end = "x_bottom"   X chain, fixed end: a flange screwed up under the
//                    gantry's left end, where the cables come round the
//                    gantry's edge from the Z chain's top mount. Same 3
//                    screw positions and pivot as the old "chain tower
//                    mount v8", M4 down through the gantry into heat-sets.
//                    The chain's face on the gantry-edge side stays 5 in
//                    from the flange's edge, as on the old one; the extra
//                    width goes toward the wing. Pin end.
//     | "x_toolhead" X chain, moving end: the old toolhead arm (2x M3
//                    down into the toolhead, sticking out the back), its
//                    pin block swapped for hangers holding a hole end
//                    under it. The link swings freely through 180 deg.
//                    Hole end.
//     | "z_base"     Z chain, fixed end: a plate on top
//                    of the bottom 4040, centred, 4x M3 into T-nuts (20 mm
//                    across the rail = its two slots, 38.6 along it). Pin end.
//     | "z_top"      Z chain, moving end: the old "z cable chain top mount"
//                    (on the X gantry), same face and foot; 2x M3 up from
//                    under the gantry into heat-sets. Hole end.
//                    Holds its link either way up: the link's way up picks
//                    which way the chain curls from the foot.
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
check_flip = false;  // end_check / end_asm: the neighbor fitted upside down

m3_d     = 3.4;    // M3 clearance
m3_head  = 6.0;    // counterbore for an M3 socket head
m3_head_h = 3.2;

// Rigid ends: the fixed ends hold their first link straight (at flat_stop,
// the chain's own straight), no bending at the mount. A link's plates are
// cut for the neighbor's whole swing (sweep from the straight stop to
// max_bend); a rigid end's are cut only for the neighbor at straight, plus
// rigid_fit. Toward straight the usual stop holds it; the other way its
// shoulder meets the end's plate after rigid_fit / h (~0.8 deg on X).
rigid_fit = 0.15;
module outer_profile_rigid() {     // pin end: the next link is held
    difference() {
        translate([0, h]) { nose(); rear_body(pitch + stop_ext); }
        translate([pitch, h]) {
            offset(delta = gap) nose();
            rotate(-flat_stop) offset(delta = rigid_fit) rear_body(pitch + 10);
        }
        translate([0, h]) circle(d = hole_d);
    }
}
// Hole end: the previous link is held, either way up. Cut for it at
// straight both ways (+-flat_stop): the link's own straight stop then holds
// it on whichever pose it's in, and the end's plate the other way.
module inner_profile_rigid() {
    difference() {
        translate([pitch, h]) { nose(); front_body(pitch + stop_ext); }
        translate([0, h]) {
            offset(delta = gap) nose();
            for (a = [flat_stop, -flat_stop])
                rotate(a) offset(delta = rigid_fit) front_body(pitch + 10);
        }
    }
}
// side_plate() (chain_link.scad) with the rigid profiles
module side_plate_rigid() {
    difference() {
        slab(0, t) outer_profile_rigid();
        translate([-hole_d / 2, t, h]) rotate([0, 0, atan2(ramp_k, -1)])
            translate([0, -50, -50]) cube(100);
    }
    slab(t, 2 * t) inner_profile_rigid();
    translate([pitch, 0, h]) difference() {
        rotate([-90, 0, 0]) cylinder(d = pin_d, h = t + 1);
        rotate([0, 0, -atan(ramp_k)]) translate([0, -50, -50]) cube(100);
    }
}

// A link's plates between x0 and x1, edges chamfered like the link.
module link_plates(x0, x1, rigid = false) {
    difference() {
        intersection() {
            both_sides() if (rigid) side_plate_rigid(); else side_plate();
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

// ---------- Z chain, fixed end on the 4040 (pin end) ----------

// A plate across the chain's end. Pivot to the mounting face: the Z link's
// next neighbor sweeps in to pitch - 11.9 at full bend, so it sits back 19.
// (It began as the X bottom end, from the wrong old part, hence the names.)
xb_face  = chain == "x" ? 16.4 : 19;
xb_t     = 5;      // plate thickness
xb_h     = 48.6;   // plate height (z)
xb_holes = [20, 38.6];   // hole spacing [y, z], centred on the chain

module plate_end() {
    xf = pitch - xb_face;          // mounting face
    xp = xf + xb_t;                // chain side of the plate
    difference() {
        union() {
            link_plates(xp - 0.01, pitch + nose_r + 1, rigid = true);
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
module plate_end_tag() {
    translate([pitch - xb_face, width / 2, h]) rotate([0, -90, 0]) rotate([0, 0, 90])
        provenance(w = width - 4, h = xb_holes[1] - m3_head - 4, mode = "inlay");
}
// As printed: mounting face on the bed.
module plate_end_print() {
    rotate([0, -90, 0]) translate([-(pitch - xb_face), 0, 0])
        with_provenance() { plate_end(); plate_end_tag(); }
}

// ---------- X chain, fixed end under the gantry (pin end) ----------

// The old "chain tower mount v8" (a 150% chain's hole end on a flange):
// the flange's face is flush with the chain's inside-of-bend face and
// screws up under the gantry; M4s come down through the gantry into it.
// Its 3 holes, from its pivot, back along the chain (away from the
// toolhead) and across from the old chain's wing-side edge (+ = away from
// the wing):
//   (27.37, -20.5) out on the wing
//   (22.87,   3.5) in the old chain's wing-side wall
//   (27.37,  23.5) in the old chain's far wall
// The old chain was 25.5 wide outside; its far face sat 5 in from the
// flange's far edge (the gantry's edge side). That gap is kept: the new
// chain's far face stays put and its extra width goes toward the wing.
// In this frame (z = 0 against the gantry, y = 0 the old chain's wing-side
// edge, pivot at x = pitch) the holes are at x = pitch - those; the chain
// itself spans y = xg_yc .. xg_yc + width.
xg_holes = [[pitch - 27.37, -20.5], [pitch - 22.87, 3.5], [pitch - 27.37, 23.5]];
xg_old_w = 25.5;           // the old chain's outside width
xg_gap   = 5;              // its far face to the flange's far edge
xg_yc    = xg_old_w - width;   // the chain's wing-side face (y)
xg_edge  = xg_old_w + xg_gap;  // the flange's far edge (y)
xg_x0    = pitch - 38.9;   // the flange's back end, as on the old part
xg_wing  = -27.5;          // the wing's edge (y)
xg_floor = 4;              // flange thickness (= bar_t: flush with the links' bars)
xg_x1    = pitch - nose_r - 1;   // floor ends short of the neighbor's nose
xg_wall1 = 14;             // the side walls are plain boxes up to here,
                           //   then the link's plates
// M4 heat-set inserts, pressed in from the gantry face (on the bed)
ins_d    = 5.2;    // bore for an M4 heat-set, 6 OD x 6 long (0.8 under
                   //   the OD, like m3_ins_d for the 5 OD M3s)
ins_l    = 6;      // insert length; the bore is 1 deeper
m4_d     = 4.5;    // screw clearance past the insert
ins_pad  = 11;     // pad / boss diameter around each insert
ins_cap  = 1;      // pad left above the channel hole's bore

// The channel's clear span (y), between the side walls.
xg_ch = [xg_yc + 2 * t, xg_yc + width - 2 * t];
function xg_in_channel(p) = p[1] > xg_ch[0] && p[1] < xg_ch[1];

module x_bottom() {
    pad_h = ins_l + 1 + ins_cap;   // channel pad thickness
    difference() {
        union() {
            translate([0, xg_yc, 0]) {
                link_plates(xg_wall1 - 0.01, pitch + nose_r + 1, rigid = true);
                // side walls back to the flange's end, full height, outside
                // long edges chamfered like the link's
                both_sides() hull() {
                    translate([xg_x0, 0, 0]) cube([xg_wall1 - xg_x0, 2 * t, height - edge_c]);
                    translate([xg_x0, edge_c, 0]) cube([xg_wall1 - xg_x0, 2 * t - edge_c, height]);
                }
            }
            // flange: the floor across the chain out to the pin's nose, and
            // on past the chain's far face to the flange's far edge
            translate([xg_x0, xg_yc, 0]) cube([xg_x1 - xg_x0, xg_edge - xg_yc, xg_floor]);
            // the wing past the chain's wing-side face, corner chamfered
            linear_extrude(xg_floor) polygon([
                [xg_x0, xg_yc + 0.01], [xg_x0, xg_wing + 3], [xg_x0 + 3, xg_wing],
                [xg_holes[0][0] + ins_pad / 2 + 2, xg_wing],
                [xg_wall1, xg_yc + 0.01]]);
            for (p = xg_holes) translate([p[0], p[1], 0])
                if (xg_in_channel(p))
                    // a low pad in the channel
                    cylinder(d = ins_pad, h = pad_h, $fn = 48);
                else
                    // at a wall: a full-height boss, kept out of the channel
                    difference() {
                        union() {
                            cylinder(d = ins_pad, h = height - edge_c, $fn = 48);
                            translate([0, 0, height - edge_c])
                                cylinder(d1 = ins_pad, d2 = ins_pad - 2 * edge_c, h = edge_c, $fn = 48);
                        }
                        translate([-ins_pad, xg_ch[0] - p[1], -1])
                            cube([2 * ins_pad, xg_ch[1] - xg_ch[0], height + 2]);
                    }
        }
        // M4 heat-set from the gantry face, screw clearance on through the
        // top (into the channel for the middle one): any screw length fits
        for (p = xg_holes) translate([p[0], p[1], 0]) {
            translate([0, 0, -1]) cylinder(d = ins_d, h = ins_l + 1 + 1, $fn = 40);
            translate([0, 0, ins_l]) cylinder(d = m4_d, h = height + 1, $fn = 32);
        }
    }
}
// As printed: the gantry face on the bed. No tag: no face is long enough
// for the SHA (the side wall is 29 mm, the floor between the inserts 11).
module x_bottom_print() { x_bottom(); }

// ---------- X chain, toolhead end (hole end) ----------

// The old toolhead arm ("old toolhead mount.stl", exported from Fusion),
// kept: a 20.5 x 10 x 5 foot with 2x M3 side by side, 7.5 apart,
// counterbored from the top, screwed down onto the toolhead; a 10.5 x 5 arm
// from it straight out the back (now 13 wide, for the tag). Its pin block
// hung under the arm's end, the old chain's last link hooked over the pin's
// stubs.
//
// Now: the end's two hole plates are bare round noses (no shoulders, so no
// bend stops), each held from outside the chain by a hanger plate hanging
// from the arm. Nothing of the neighbor link is outside its side plates, so
// the hangers can be any shape; the neighbor sweeps everything within its
// half-height (11) of the pivot, so the arm has to stay out of that on
// the whole swing. The swing is 180 deg about xt_c, so the arm sits up and
// to the -X side of the pivot. Needed on the printer: from a little -X of
// straight down (at max X) to straight out +X (at min X); 180 about 40 deg
// gives 40 deg spare either way, to change the chain's length.
//
// Frame F, as installed: X = printer X, Y along the arm toward the back
// (0 = the screw row), Z up (0 = the arm's top face).
xt_foot   = [20.5, 10];  // foot (X, Y), centred on the screw row
xt_screws = 7.5;         // M3 spacing, across the arm (X)
xt_cb     = [6.0, 2];    // counterbore (d, depth), from the top face
xt_arm    = [13, 5];     // arm (width X, thickness Z): 10.5 on the old
                         //   one, widened so the tag's SHA fits (needs 10)
xt_fillet = 5;           // foot-to-arm fillets
xt_y0     = 41.75;       // the old chain's near edge: the near hanger's
                         //   outside face (the extra width goes to +Y,
                         //   away from the toolhead)
xt_hang   = 4;           // hanger thickness (Y), outside each side plate
xt_drop   = 12;          // arm's underside to the pivot (old 10.5: a link
                         //   straight out sideways, half-height 11, hit it)
xt_off    = 11.5;        // pivot's +X offset from the arm's centreline
xt_c      = 40;          // centre of the swing, deg from down toward +X
xt_swing  = 90;          // free each way about xt_c
xt_recess = 0.6;         // hole carried this deep into the hangers: the pin's
                         //   tip is flush with the plate's outside face

xt_y1 = xt_y0 + 2 * xt_hang + width;                   // the arm's far end
xt_P  = [xt_off, xt_y0 + xt_hang, -xt_arm[1] - xt_drop];  // pivot, at the
                                                       //   near side plate's outside face
// Link frame (E) in F: E's +x (the end's body) points away from the swing's
// centre, so the neighbor at a = 0 hangs at xt_c; E's z = x cross y.
xt_u = [-sin(xt_c), 0, cos(xt_c)];
xt_w = [-cos(xt_c), 0, -sin(xt_c)];
xt_EF = [[xt_u.x, 0, xt_w.x, xt_P.x - h * xt_w.x],
         [0,      1, 0,      xt_P.y],
         [xt_u.z, 0, xt_w.z, xt_P.z - h * xt_w.z],
         [0, 0, 0, 1]];
xt_FE = [[xt_u.x, 0, xt_u.z, -(xt_u * xt_P)],
         [0,      1, 0,      -xt_P.y],
         [xt_w.x, 0, xt_w.z, h - xt_w * xt_P],
         [0, 0, 0, 1]];

// E frame: the hole plates, round noses with the link's hole and lead-in
// ramp (side_plate()'s outer layer, minus the body and its shoulders).
module xt_plates_E() {
    both_sides() difference() {
        slab(0, t) translate([0, h]) difference() { nose(); circle(d = hole_d); }
        translate([-hole_d / 2, t, h]) rotate([0, 0, atan2(ramp_k, -1)])
            translate([0, -50, -50]) cube(100);
    }
}
module xt_recess_E() {
    both_sides() translate([0, 0.01, h]) rotate([90, 0, 0])
        cylinder(d = hole_d, h = xt_recess + 0.01);
}

module x_toolhead_F() {
    difference() {
        union() {
            // foot, arm and fillets
            translate([0, 0, -xt_arm[1]]) linear_extrude(xt_arm[1]) {
                translate([-xt_foot.x / 2, -xt_foot.y / 2]) square(xt_foot);
                translate([-xt_arm.x / 2, 0]) square([xt_arm.x, xt_y1]);
                difference() {
                    translate([-xt_foot.x / 2, xt_foot.y / 2 - 0.01])
                        square([xt_foot.x, xt_fillet]);
                    for (s = [-1, 1])
                        translate([s * (xt_arm.x / 2 + xt_fillet), xt_foot.y / 2 + xt_fillet])
                            circle(r = xt_fillet);
                }
            }
            // hangers: the nose round the pivot, hulled up to the arm
            for (y = [xt_y0, xt_y1 - xt_hang])
                translate([0, y + xt_hang, 0]) rotate([90, 0, 0]) linear_extrude(xt_hang)
                    hull() {
                        translate([xt_P.x, xt_P.z]) circle(r = nose_r);
                        translate([-xt_arm.x / 2, -xt_arm[1]]) square(xt_arm);
                    }
            multmatrix(xt_EF) xt_plates_E();
        }
        multmatrix(xt_EF) xt_recess_E();
        for (s = [-1, 1]) translate([s * xt_screws / 2, 0, 0]) {
            translate([0, 0, -xt_arm[1] - 1]) cylinder(d = m3_d, h = xt_arm[1] + 2, $fn = 32);
            translate([0, 0, -xt_cb[1]]) cylinder(d = xt_cb[0], h = xt_cb[1] + 1, $fn = 48);
        }
    }
}
// Its tag: inlaid in the arm's top face (on the bed), from the foot's
// fillets to the arm's end (the top face runs flat over the hangers).
module x_toolhead_tag_F() {
    y0 = xt_foot.y / 2 + xt_fillet + 1;
    y1 = xt_y1 - 1;
    translate([0, (y0 + y1) / 2, 0]) rotate([0, 0, 90])
        provenance(w = y1 - y0, h = xt_arm.x - 2, mode = "inlay");
}
module x_toolhead() { multmatrix(xt_FE) x_toolhead_F(); }
// As printed: the arm's top face on the bed, the hangers up.
module x_toolhead_print() {
    rotate([0, 180, 0]) with_provenance() { x_toolhead_F(); x_toolhead_tag_F(); }
}

// ---------- Z chain, gantry end (hole end) ----------

// The old part, in this frame (pivot at x = 0, z = h; it's the same size
// link): a block from zt_x0 to the mounting face at zt_face, the link's full
// height plus a foot below it to z = -20, with a cable window through it
// along the chain. 2x M3 in the foot, parallel to the chain, at z = -15:
// the screws come up from under the gantry, through clearance in the foot,
// into heat-sets pressed in from its far (chain-side) face, so the foot is
// pinched between the gantry and the inserts' flanges.
zt_x0    = 14.3;
zt_face  = 23.8;
zt_foot  = -20;
zt_holes = [[10.1, -15], [-12.0, -15]];   // [y from the chain's centre, z]
zt_win_h = 18.2;   // window height (z), centred on the pivot
m3_ins_d = 4.2;    // bore for an M3 heat-set, 5 OD x 4 long (as picam-mount)
m3_ins_l = 4;      // bore depth: the insert sits flush

module z_top() {
    link_plates(-nose_r - 1, zt_face, rigid = true);
    difference() {
        hull() {
            translate([zt_x0, edge_c, zt_foot]) cube([zt_face - zt_x0, width - 2 * edge_c, height - zt_foot]);
            translate([zt_x0, 0, zt_foot + edge_c]) cube([zt_face - zt_x0, width, height - zt_foot - 2 * edge_c]);
        }
        translate([zt_x0 - 1, 2 * t, h - zt_win_h / 2]) cube([zt_face - zt_x0 + 2, inner_w, zt_win_h]);
        for (p = zt_holes) translate([0, width / 2 + p[0], p[1]]) rotate([0, 90, 0]) {
            translate([0, 0, zt_x0 - 1]) cylinder(d = m3_d, h = zt_face - zt_x0 + 2, $fn = 32);
            translate([0, 0, zt_x0 - 1]) cylinder(d = m3_ins_d, h = 1 + m3_ins_l, $fn = 40);
        }
    }
}
// Its tag: inlaid in the mounting face (on the bed), between the screw
// holes' row and the cable window, the full width (41 mm is what a 7-char
// SHA needs at the minimum stroke).
module z_top_tag() {
    z0 = zt_holes[0][1] + m3_ins_d / 2 + 0.5;   // above the insert bores
    z1 = h - zt_win_h / 2 - 0.5;            // below the window
    translate([zt_face, width / 2, (z0 + z1) / 2]) rotate([0, 90, 0]) rotate([0, 0, 90])
        provenance(w = width - 4, h = z1 - z0, mode = "inlay");
}
// As printed: mounting face on the bed.
module z_top_print() {
    rotate([0, 90, 0]) translate([-zt_face, 0, 0]) with_provenance() { z_top(); z_top_tag(); }
}

// ---------- dispatch ----------

module end_in_place() {
    if (end == "x_bottom") x_bottom();
    else if (end == "z_base") plate_end();
    else if (end == "x_toolhead") x_toolhead();
    else if (end == "z_top") z_top();
}
end_is_pin = end == "x_bottom" || end == "z_base";

// The neighbor link (with its bar) at bend a, in the end's frame.
module neighbor(a) {
    if (end_is_pin)
        translate([pitch, 0, h]) rotate([0, a, 0]) translate([0, 0, -h]) { link(); bar(); }
    else flip_z(check_flip)
        translate([0, 0, h]) rotate([0, -a, 0]) translate([-pitch, 0, -h]) { link(); bar(); }
}

if (part == "end") {
    if (end == "x_bottom") x_bottom_print();
    else if (end == "z_base") plate_end_print();
    else if (end == "x_toolhead") x_toolhead_print();
    else if (end == "z_top") z_top_print();
}
else if (part == "in_place") end_in_place();
else if (part == "end_check") intersection() { end_in_place(); neighbor(check_a); }
else if (part == "end_asm") { color("SlateGray") end_in_place(); color("SteelBlue") neighbor(check_a); }
