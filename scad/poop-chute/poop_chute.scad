// poop_chute.scad
// Rectangular poop chute for the Kobra Max. It sits on the left base 4040 below the
// bed's left edge, with a backboard to catch kicked poop. Everything drops through
// an open bottom into a crate on the table beside the rail.
//
// Coordinates come from kobra_poop_env.scad (bed left edge x=0, outboard -X,
// gantry front face y=0, table z=0).
//
// Profile (XZ, looking from the front; the bed is up and to the right):
//
//      backboard
//        ||        side-wall wing (only outboard of the toolhead's reach)
//        ||  \           ________ bed (6 mm)
//        ||   \_______  |________
//        ||          floor  /_|  <- lip tucks under the bed by lip_under
//        ||   (45 deg)  /   |
//        ||  exit     /     |
//        ||  gap     /______|  foot, with a dovetail groove underneath
//                    [plate ]  mount plate on top of the 4040 (M3 T-nuts)
//
// Parts:
//   - mount plate: screws to the 4040's top slots with buried M3 socket heads, and
//     carries one dovetail rail per half, running along X.
//   - two chute halves (split at mid-width): each slides onto its rail from the
//     outboard side (+X) until the groove's closed end stops on the rail end. The
//     dovetails taper slightly so they wedge tight at the end of travel. The plate
//     locates both halves, so they line up without bolts or pins.
//   Each half prints lying on its outer side wall with the split face up; the plate
//   prints flat. No supports.
//
// Renders:
//   fit check: openscad -o fit_iso.png --render ... poop_chute.scad
//   STLs:      openscad -D 'mode="front"' -o poop_chute_front.stl poop_chute.scad
//              openscad -D 'mode="back"'  -o poop_chute_back.stl  poop_chute.scad
//              openscad -D 'mode="plate"' -o poop_chute_plate.stl poop_chute.scad

include <kobra_poop_env.scad>
show_env = false;

mode = "fit";   // "fit" = chute + printer + crate, "front" / "back" / "plate" = printable parts

/* ---------- Design parameters ---------- */
wall        = 2.4;
floor_t     = 3.6;    // floor thickness, measured vertically (~2.5 mm normal at 45 deg)
lip_under   = 5;      // floor edge reaches this far under the bed (x)
lip_clear   = 2.5;    // gap between the lip and the bed's underside
edge_gap    = 2;      // above the bed's underside, stay this far outboard of its edge
side_top_z  = 125;    // side-wall top inside the toolhead's reach (nozzle is 128 at Z=0)
floor_slope = 45;     // deg; blobs need steep to slide
exit_gap    = 30;     // open bottom between the floor end and the backboard (x)
exit_z      = 68;     // lowest chute edge outboard of the rail; crate top is 63
backboard_h = 158;    // backboard top (z); 30 mm above the bed, just under the gantry bottom at Z=0
y_back      = -12;    // back side wall, in front of the gantry face
y_front     = -112;   // front side wall
th_reach    = 40;     // toolhead can't go further outboard than the cut pin (33) + margin

// mount plate + dovetails
plate_t     = 6;      // mount plate thickness (room to bury an M3 socket head)
foot_t      = 8;      // chute foot slab (holds the dovetail groove)
dt_h        = 4;      // dovetail height
dt_w        = 8;      // dovetail width at the plate surface (narrow side); 45 deg flanks
dt_taper    = 0.4;    // rail + groove are this much wider (total) at the inboard end, so the
                      // fit stays loose while sliding and only snugs up when seated
dt_clear    = 0.25;   // groove clearance per side
dt_stop     = 4;      // rail ends this far outboard of x=0; the groove's closed end stops on it
head       = "socket"; // "socket" = counterbored M3 SHCS, "flat" = countersunk M3
cbore_d     = 6.0;    // M3 socket head is 5.5 x 3
cbore_h     = 3.3;
csk_d       = 6.4;    // M3 countersunk head
screw_d     = 3.4;

round_r     = 1;      // convex edge rounding on the wall cross-section
fillet_r    = 2;      // concave fillets on the wall cross-section
outline_r   = 1.5;    // side-wall outline corners
chamfer     = 1;      // outer side-wall face edge chamfer (on the print bed)

/* ---------- Crate (printables 1280405, 180 x 120 x 63) ---------- */
crate = [120, 180, 63];   // x (outboard), y (along the rail), z

/* ---------- Derived ---------- */
base_z      = rail_top_z + plate_t;                   // chute sits here
foot_top    = base_z + foot_t;
lip_z       = bed_top_z - bed_t - lip_clear;          // floor top at the lip
x_floor_end = lip_under - (lip_z - exit_z) / tan(floor_slope);
x_bb        = x_floor_end - exit_gap;                 // inboard face of the backboard
x_bbo       = x_bb - wall;                            // outboard face of the backboard
y_mid       = (y_front + y_back) / 2;
rail_ys     = [(y_front + y_mid) / 2, (y_mid + y_back) / 2];   // one dovetail per half
slot_xs     = [rail_x0 + 10, rail_x0 + 30];           // 4040 top-face slot centres
screw_ys    = [y_front + 9, y_back - 9];

function floor_z(x) = lip_z - (lip_under - x) * tan(floor_slope);
// x where the floor's underside is `gap` above the foot
function x_under(gap) = lip_under - (lip_z - floor_t - foot_top - gap) / tan(floor_slope);

/* ---------- 2D helpers ---------- */
module round2d(r)  { offset(r = r) offset(delta = -r) children(); }    // convex corners
module fillet2d(r) { offset(r = -r) offset(delta = r) children(); }    // concave corners

// Everything the chute occupies, seen from the front (XZ).
module outline_raw() {
    polygon([
        [0,              base_z],
        [0,              floor_z(0) - floor_t],
        [lip_under,      lip_z - floor_t],
        [lip_under,      lip_z],
        [-edge_gap,      lip_z],
        [-edge_gap,      side_top_z],
        [-th_reach,      side_top_z],
        [x_bbo,          backboard_h],
        [x_bbo,          exit_z],
        [rail_x0,        exit_z],
        [rail_x0,        base_z],
    ]);
}
module outline2d() { fillet2d(outline_r) round2d(outline_r) outline_raw(); }

// Open channel above the floor.
module channel2d() {
    polygon([
        [lip_under + 1,  floor_z(lip_under + 1)],
        [x_floor_end,    exit_z],
        [x_floor_end,    exit_z - 1],
        [x_bb,           exit_z - 1],
        [x_bb,           backboard_h + 10],
        [lip_under + 1,  backboard_h + 10],
    ]);
}

// Hollow under the floor, above the foot.
module under2d() {
    polygon([
        [-wall,       foot_top],
        [-wall,       floor_z(-wall) - floor_t],
        [x_under(3),  foot_top + 3],
        [x_under(3),  foot_top],
    ]);
}

// Cross-section of the walls between the side walls: floor, backboard, inner
// wall, foot.
module section2d() {
    round2d(round_r) fillet2d(fillet_r) intersection() {
        outline2d();
        difference() { outline_raw(); channel2d(); under2d(); }
    }
}

/* ---------- 3D ---------- */
module extrude_y(y0, y1) {
    // XZ profile -> solid spanning y0..y1
    translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children();
}

// Side wall with its outer face at y_face, growing toward dir (+1 / -1).
// The outer face edge gets a stepped 45-degree chamfer.
module side_wall(y_face, dir) {
    steps = 5;
    s = chamfer / steps;
    for (i = [0 : steps - 1]) {
        y0 = y_face + dir * i * s;
        extrude_y(min(y0, y0 + dir * s), max(y0, y0 + dir * s))
            offset(delta = -(chamfer - i * s)) outline2d();
    }
    y1 = y_face + dir * chamfer;
    y2 = y_face + dir * wall;
    extrude_y(min(y1, y2), max(y1, y2)) outline2d();
}

// Dovetail along X, centred on y, base at z0, narrow side down, 45 deg flanks.
// `grow` widens it (clearance); the inboard end (x1) is dt_taper wider.
module dovetail(y, z0, x0, x1, grow = 0, h = dt_h) {
    module slice(x, w) {
        translate([x, y, z0]) rotate([90, 0, 90]) linear_extrude(0.01)
            polygon([[-w/2, 0], [w/2, 0], [w/2 + h, h], [-w/2 - h, h]]);
    }
    hull() {
        slice(x0, dt_w + 2 * grow);
        slice(x1, dt_w + 2 * grow + dt_taper);
    }
}

module chute() {
    difference() {
        union() {
            side_wall(y_front, +1);
            side_wall(y_back,  -1);
            extrude_y(y_front + wall - 0.01, y_back - wall + 0.01) section2d();
        }
        // dovetail grooves: open at the outboard end, closed at the inboard end
        for (y = rail_ys)
            // starts 1 mm below the foot for a clean cut; grow is reduced to match
            dovetail(y, base_z - 1, rail_x0 - 1, -dt_stop, grow = dt_clear - 1, h = dt_h + 1.3);
    }
}

module plate() {
    difference() {
        translate([rail_x0, y_front, rail_top_z]) cube([-rail_x0, y_back - y_front, plate_t]);
        for (x = slot_xs, y = screw_ys) translate([x, y, rail_top_z - 1]) {
            cylinder(d = screw_d, h = plate_t + 2);
            if (head == "socket")
                translate([0, 0, 1 + plate_t - cbore_h]) cylinder(d = cbore_d, h = cbore_h + 1);
            else   // 90-degree countersink, flush with the top
                translate([0, 0, 1 + plate_t - csk_d / 2]) cylinder(d1 = 0, d2 = csk_d + 0.01, h = csk_d / 2 + 0.01);
        }
    }
    for (y = rail_ys) dovetail(y, base_z - 0.01, rail_x0, -dt_stop);
}

module half(which) {
    intersection() {
        chute();
        if (which == "front") translate([-500, y_mid - 500, -500]) cube([1000, 500, 1000]);
        else                  translate([-500, y_mid,       -500]) cube([1000, 500, 1000]);
    }
}

module crate_ghost() {
    color("SteelBlue", 0.35) translate([rail_x0 - 2 - crate.x, y_mid - crate.y/2, 0]) cube(crate);
}

if (mode == "fit") {
    env();
    color("Orange") half("front");
    color("DarkOrange") half("back");
    color("MediumSeaGreen") plate();
    crate_ghost();
} else if (mode == "front") {
    // outer (front) side wall on the bed, split face up
    rotate([90, 0, 0]) translate([0, -y_front, 0]) half("front");
} else if (mode == "back") {
    rotate([-90, 0, 0]) translate([0, -y_back, 0]) half("back");
} else if (mode == "plate") {
    translate([0, 0, -rail_top_z]) plate();
}
