// drive_bay.scad
// Tool-less carrier for one side bay of glowbox's NORCO RPC-470 4U case.
// Three 3.5" drives stand on their sides. Each drive gets a screwed-on rail
// along its top and bottom edges (using the drive's side screw holes); the
// rails slide in grooves in the carrier's top and bottom plates. Swap one
// drive: unplug it at the back, push it forward out of the front (the case
// has a hinged front door, so nothing may stick out past the carrier front).
// See CONTEXT.md for requirements and the measurement list.
//
// PROTOTYPE: the case is in service. The 5.25" opening is NOT measured, and
// the mount holes were measured to an edge (~1 mm). Print the fit slice first.
//
// Axes (carrier, as installed):
//   X = across the bay, centred. Y = depth; Y=0 is the carrier front face,
//   +Y runs toward the motherboard. Z = up; Z=0 is the carrier bottom.
//
// Parts (set with -D part=\"...\"):
//   assembly     carrier + 3 drives + rails, one drive half pushed out
//   carrier      full carrier, print orientation. The same part fits both
//                bays: turn it 180 degrees (front <-> back) for the other side.
//   slice        first slice_d mm of the carrier (incl. the front mount row)
//   rail         two per drive (top and bottom are the same part), print
//                orientation (drive face down)
//   filler       blanking plug for the 3 middle 5.25" bays
//
// Render:   scad/render.sh scad/glowbox-drive-bay/drive_bay.scad carrier.stl -D 'part="carrier"'
//           (from the repo root; fills in the provenance tags)
// Preview:  openscad -o assembly.png --render --imgsize=1200,900 \
//             --colorscheme=Tomorrow --camera=0,75,75,55,0,325,560 drive_bay.scad

hdd_lib_only = true;
include <hdd35.scad>
include <../lib/provenance.scad>

part = "assembly";
$fn = 40;

/* ---------- Measured (caliper photos, 2026-10-27) ---------- */
bay_w = 130.3;      // side bay front opening, width
bay_h = 149.7;      // side bay front opening, height
// bay depth: ~262 from the bezel face to the fan wall (see Mounting).

/* ---------- Mounting ----------
   The old cages hang from the case's top plate. Above each bay: 2 rows x 3
   embossed pads; each pad has TWO round holes 8.0 apart left-to-right (the
   old cage uses one of each pair). Measured: rows 76.3 apart front-to-back,
   pads 28.9 apart. The carrier gets M3 heat-sets in its top face under the
   holes the old cage uses; M3 x 10 screws go down through them.
   Hole positions were measured to a hole EDGE with calipers, good to ~1 mm.
   - Front-back (P_20261028_005920): 51.3 from the bezel's front face to
     the near edge of a front-row hole, so the centre is ~53. The bezel is
     ~16 thick. The carrier slides to line up, and the rows sit centred in
     its depth (so it works either way round); its front lands ~17 behind
     the bezel face, about at the bezel's inside face.
   - Left-right (P_20261028_005954): 31.7 from the bay's wall on the middle
     side (next to the 5.25" bays) to the near edge of the EMPTY hole in the
     nearest pad. The old cage's screw is the other hole, 8 closer to that
     wall, so its centre is ~25.4 from the wall. The pattern is NOT centred
     on the bay. The case is mirror-symmetric, so turning the carrier 180
     degrees puts the holes right for the other bay. Install it pushed
     against the middle-side wall.
   - Depth: 154.2 from the bezel face to the top plate's rear edge (rod),
     then 107 (slightly diagonal, the fan wall stops short of the top) to the
     fan wall. The carrier's rear is at ~165 from the bezel face; that leaves
     plenty of room for connectors and cable bends. */
/* Test fit of v0 (2026-11-01): the v0 holes (from the numbers above) were
   well off. The case holes were marked through onto the printed carrier
   with a file and measured with calipers (photos P_20261101_2352* to
   _2354*). Each pad's two holes are ~12 apart (not 8) and the end pads
   ~86 apart (pitch ~43, not 28.9). Both rows were ~14.5 further back than
   v0's. All numbers below are mark centres on the v0 carrier, which was
   128.8 wide x 153 deep, as installed in the test bay. */
mount_y_front = 52.4;  // carrier front face -> front row
mount_y_back  = 23.3;  // carrier back face -> rear row
// From the middle-side (+X) edge, the hole of each end pad nearer the
// middle-side wall (the one the old cage used). The pads' other holes are
// at 31.2 and 118.3; the middle pad (~66 and ~77) is unused.
mount_x_edge  = [20.1, 106.2];
insert_d    = 4.0;    // hole for an M3 heat-set, 4 mm OD x 5 mm long
m3_clear_d  = 3.4;
case_sheet  = 1.0;    // top plate thickness, guessed; sets the screw reach
mount_hole_depth = 10 - case_sheet + 2;  // insert + room for the screw tip

/* ---------- Design choices ---------- */
n_drives  = 3;
pitch     = 42;     // drive centre spacing -> ~16 mm air gaps between drives
fit_clear = 0.75;   // per side, carrier vs bay opening
wall_t    = 3;      // carrier side walls
floor_t   = 4;      // plate under/over each groove: drives sit as low as possible
skirt_w   = 3;      // top-zone skirt thickness (flat with the front face)
boss_r    = 5;      // around each M3 heat-set in the top zone
// v0 had 1.5 here and 1.0 groove clearance; the test print had ~1 mm of play
// both ways, so this prints about 0.5 tight vertically and true sideways.
v_clear   = 0.8;    // drive+rails vertical play in the grooves
height_trim = 2;    // v0 was 1-2 mm too tall for the bay

rail_w    = 31;     // wider than the drive (26.1) so it rides in the groove
rail_t    = 5;
rail_tab  = 5;      // short tab in front of the drive: carries the stop
groove_w  = rail_w + 0.4;
groove_d  = rail_t; // drive edge sits flush with the plate face
tab_shoulder = 3;   // the rail tab is this much wider each side than the
                    // rail; it sits in a pocket at the carrier front, and the
                    // pocket's back wall is the stop. Nothing sticks out.
pocket_d  = rail_tab + 0.5;   // tab ends 0.5 inside the carrier front
tip_ch    = 2;      // lead-in chamfer at the rail's leading (rear) end
tip_ch_z  = 1.5;    // ...and on its outer face

// 6-32 screws through the rail into the drive's side holes. Use 6-32 x 3/16"
// (4.8 mm): with 2 mm of rail under the head that gives 2.8 mm into the
// drive, inside the SFF-8300 limit of 3.02 mm. A longer screw can bottom out.
screw_clear_d = 3.8;
cbore_d       = 8.6;  // pan head; some drive screws' heads are 7.8
under_head    = 2.0;

// Detent: four bumps per rail, each on a flexing beam at a rail edge (both
// edges, front and rear), clicking into the four notches in the groove
// walls, so the drive can't creep and the rail centres itself.
det_y    = 16;      // from the drive front (a notch at each end)
det_len  = 30;      // beam length
det_beam = 2.0;     // beam width
det_slot = 1.2;
det_r    = 1.5;
det_bump = 1.0;     // how far the bump stands proud of the rail edge

slice_d = 60;       // reaches past the measured front mount row (52.4)

// Provenance tags: raised on the carrier's top face, along the depth between
// the boss columns; engraved (inset) in each rail's outer face between the
// screw holes, so it can't catch in the groove.
car_tag_size  = 3.5;
rail_tag_size = 2.8;

// 5.25" filler plug. GUESSED from the 3-bay standard; MEASURE the opening.
plug_w = 146.0;
plug_h = 127.0;
plug_d = 10;
plug_wall = 2;
flange = 5;
flange_t = 2.5;

/* ---------- Derived ---------- */
car_w   = bay_w - 2 * fit_clear;
car_h   = bay_h - 2 * fit_clear - height_trim;
inner_h = hdd_w + v_clear;              // plate face to plate face
plate_t = groove_d + floor_t;           // bottom and top groove plates
// Above the top groove plate, up to the case's top plate, is the 'top
// zone': mostly empty. Only the 4 insert bosses (outer pads; the middle
// pads are unused) and one skirt (to stop air bypassing the drives) reach
// the top face. The skirt is at the print-bed end; turned around for the
// other bay it sits at the back, which blocks the air just as well.
zt      = 2 * plate_t + inner_h;        // bottom of the top zone
top_h   = car_h - zt;
// Grooves run all the way through, so the carrier works either way round;
// a tab pocket at each end. The drive front sits pocket_d in from the front.
car_d   = pocket_d + hdd_l + 0.5;
// Boss rows: the measured rows, plus the same rows seen from the back, for
// the carrier turned around in the other bay. The front-most is cut off at
// the front face and merges into the skirt.
mount_y = [mount_y_back, mount_y_front, car_d - mount_y_front, car_d - mount_y_back];
mount_x = [for (d = mount_x_edge) car_w / 2 - d];
// rear detent: the bump that lands in the carrier's rear notch
det_y_rear = car_d - 2 * pocket_d - det_y;
drive_x = [for (i = [0 : n_drives - 1]) (i - (n_drives - 1) / 2) * pitch];
// Side holes sit 6.35 above the drive base; the base faces +X.
hole_x  = hdd_h / 2 - hdd_side_hole_z;

echo(car_w = car_w, car_h = car_h, car_d = car_d, plate_t = plate_t, top_h = top_h,
     gap_between = pitch - hdd_h,
     gap_at_wall = car_w / 2 - wall_t - drive_x[n_drives - 1] - hdd_h / 2);
assert(drive_x[n_drives - 1] + groove_w / 2 < car_w / 2 - wall_t,
       "grooves run into the side walls");
assert(mount_hole_depth < top_h, "mount holes run out of the bosses");
assert(abs(car_w - 128.8) < 0.01 && abs(car_d - 153) < 0.01,
       "mount positions were measured on a 128.8 x 153 carrier");
assert(hole_x + cbore_d / 2 < rail_w / 2 - det_beam - det_slot - 1,
       "counterbores run into the detent slots");

/* ---------- Rail ----------
   Rail-local: X across (centred on the drive), Y along the drive (Y=0 is the
   drive front, the tab is at negative Y, the leading end is at hdd_l), Z=0 the outer (groove) face,
   Z=rail_t the face against the drive. It is symmetric across X (screw
   holes and detents on both edges), so the top and bottom rails are the
   same part, and either way round fits the drive's holes. */
module rail() {
    difference() {
        union() {
            // body, chamfered at the leading end so it finds the groove
            hull() {
                translate([-rail_w / 2, 0, 0]) cube([rail_w, hdd_l - tip_ch, rail_t]);
                translate([-rail_w / 2 + tip_ch, hdd_l - 0.01, tip_ch_z])
                    cube([rail_w - 2 * tip_ch, 0.01, rail_t - tip_ch_z]);
            }
            // wider tab: its shoulders stop against the pocket's back wall
            translate([-rail_w / 2 - tab_shoulder, -rail_tab, 0])
                cube([rail_w + 2 * tab_shoulder, rail_tab, rail_t]);
        }
        // screw holes + counterbores from the outer face
        for (s = [-1, 1], y = hdd_side_hole_y) translate([s * hole_x, y, 0]) {
            translate([0, 0, -1]) cylinder(d = screw_clear_d, h = rail_t + 2);
            translate([0, 0, -1]) cylinder(d = cbore_d, h = 1 + rail_t - under_head);
        }
        // slots that free the detent beams
        for (s = [-1, 1], y = [det_y, det_y_rear])
            translate([s * (rail_w / 2 - det_beam - det_slot / 2), y, rail_t / 2])
                cube([det_slot, det_len, rail_t + 2], center = true);
        // provenance tag, inset in the outer face between the screw holes;
        // it runs along the rail and reads from outside
        translate([0, (hdd_side_hole_y[0] + hdd_side_hole_y[1]) / 2, -0.01])
            mirror([1, 0, 0]) rotate([0, 0, 90])
                provenance(size = rail_tag_size, depth = prov_depth + 0.01);
    }
    // detent bumps on the beams' outer edges
    for (s = [-1, 1], y = [det_y, det_y_rear])
        translate([s * (rail_w / 2 + det_bump - det_r), y, 0])
            cylinder(r = det_r, h = rail_t);
}

/* ---------- Carrier ---------- */
// YZ profile extruded across X, centred on x0.
module along_x(w, x0 = 0) translate([x0 - w / 2, 0, 0]) rotate([90, 0, 90]) linear_extrude(w) children();

// Top zone. Everything here prints front-face-down without support: the
// skirt is flush with the front face, so it starts on the bed, and each boss ramps up from the groove plate at
// 45 deg on its front side before reaching full height at the insert.
module top_zone() {
    // 2D (u, v) = (Y, Z)
    along_x(car_w) {
        // skirt: a wall flush with the front face, full width
        translate([0, zt - 0.01]) square([skirt_w, top_h + 0.01]);
    }
    for (yh = mount_y, x = mount_x) {
        along_x(2 * boss_r, x)
            polygon([[yh - boss_r - top_h, zt - 0.01], [yh - boss_r, car_h],
                     [yh + boss_r, car_h], [yh + boss_r, zt - 0.01]]);
    }
}

module carrier() {
    difference() {
        union() {
            translate([-car_w / 2, 0, 0]) cube([car_w, car_d, zt]);
            // trimmed at the front face, where the front-most bosses' ramps
            // would start
            intersection() {
                top_zone();
                translate([-car_w, 0, 0]) cube([2 * car_w, car_d, car_h + 1]);
            }
            // provenance tag on top of the groove plate, along the depth
            // between the boss columns
            translate([(mount_x[0] + mount_x[1]) / 2, car_d / 2, zt - 0.01])
                rotate([0, 0, 90]) provenance(size = car_tag_size);
        }
        // the drive space between the plates, open front and back
        translate([-car_w / 2 + wall_t, -1, plate_t]) cube([car_w - 2 * wall_t, car_d + 2, inner_h]);
        for (x = drive_x) for (bottom = [true, false]) {
            z0 = bottom ? plate_t - groove_d : plate_t + inner_h - 0.01;
            // groove
            translate([x - groove_w / 2, -1, z0]) cube([groove_w, car_d + 2, groove_d + 0.01]);
            // tab pockets, both ends
            pw = rail_w + 2 * tab_shoulder + 1;
            for (y = [-1, car_d - pocket_d])
                translate([x - pw / 2, y, z0]) cube([pw, pocket_d + 1, groove_d + 0.01]);
            // detent notches: both groove walls, both ends, so the turned-
            // around carrier still has one where the bump lands
            for (sx = [-1, 1], y = [pocket_d + det_y, pocket_d + det_y_rear])
                translate([x + sx * (rail_w / 2 + det_bump - det_r), y, z0 - 0.5])
                    cylinder(r = det_r + 0.3, h = groove_d + 1);
        }
        // M3 heat-sets in the top face, under the holes the old cage used
        for (y = mount_y, x = mount_x)
            translate([x, y, car_h]) {
                translate([0, 0, -5.5]) cylinder(d = insert_d, h = 6);
                translate([0, 0, -mount_hole_depth]) cylinder(d = m3_clear_d - 0.2, h = mount_hole_depth);
            }
    }
}

// Rail positions as installed, for the assembly view.
module rails_installed(x, y_out = 0) {
    translate([x, pocket_d + y_out, plate_t - groove_d]) rail();
    // the top rail is screwed to the drive, so it rides with it (gap above)
    translate([x, pocket_d + y_out, plate_t + hdd_w + rail_t]) rotate([0, 180, 0]) rail();
}

module drive_installed(x, y_out = 0) {
    // drive X (width) -> world Z, drive Z (thickness) -> world -X, base at +X
    translate([x, pocket_d + y_out, plate_t])
        multmatrix([[0, 0, -1, hdd_h / 2], [0, 1, 0, 0], [1, 0, 0, 0], [0, 0, 0, 1]])
            hdd35();
}

/* ---------- 5.25" filler ---------- */
module filler() {
    translate([-plug_w / 2 - flange, -plug_h / 2 - flange, 0])
        cube([plug_w + 2 * flange, plug_h + 2 * flange, flange_t]);
    difference() {
        translate([-plug_w / 2, -plug_h / 2, 0]) cube([plug_w, plug_h, flange_t + plug_d]);
        translate([-plug_w / 2 + plug_wall, -plug_h / 2 + plug_wall, flange_t])
            cube([plug_w - 2 * plug_wall, plug_h - 2 * plug_wall, plug_d + 1]);
    }
}

/* ---------- Output ---------- */
if (part == "assembly") {
    color("SteelBlue", 0.55) carrier();
    for (i = [0 : n_drives - 1]) {
        y_out = i == 1 ? -70 : 0;   // middle drive half pushed out
        color("DarkOrange") rails_installed(drive_x[i], y_out);
        color("Silver") drive_installed(drive_x[i], y_out);
    }
    // the bay opening, as a thin outline at the carrier front
    color("Red", 0.4) translate([0, -1, car_h / 2]) difference() {
        cube([bay_w + 4, 0.5, bay_h + 4], center = true);
        cube([bay_w, 2, bay_h], center = true);
    }
} else if (part == "carrier") {
    rotate([90, 0, 0]) carrier();       // front face down
} else if (part == "slice") {
    rotate([90, 0, 0])
        intersection() {
            carrier();
            translate([-car_w, 0, -1]) cube([2 * car_w, slice_d, car_h + 2]);
        }
} else if (part == "rail") {
    translate([0, 0, rail_t]) rotate([0, 180, 0]) rail();
} else if (part == "filler") {
    filler();
}
