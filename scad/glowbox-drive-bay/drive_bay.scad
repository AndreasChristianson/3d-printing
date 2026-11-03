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
//                bays (front stays front): it has inserts for both bays' holes.
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
     on the bay. (Superseded: see the test-fit note below.)
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
// The test fit was in the RIGHT bay (seen from the front).
// From the carrier's +X edge as test-fitted: the hole of each end pad
// nearer that edge, and the pads' other holes. The middle pad (~66 and
// ~77) is unused. The other bay's pads are the mirror image, at the same
// depth (P_20261102_002022).
mount_x_edge  = [20.1, 106.2];
mount_x_other = [31.2, 118.3];
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
boss_web  = 3;      // the 45 deg ramp under a boss is this thin until it
                    // flares out at 45 deg (in plan) to the boss's width
// v0 had 1.5 here and 1.0 groove clearance; the test print had ~1 mm of play
// both ways, so this prints about 0.5 tight vertically and true sideways.
v_clear   = 0.8;    // drive+rails vertical play in the grooves
height_trim = 1;    // v0 was 1-2 mm too tall for the bay

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

// Mesh (cost reduction): holes through the side walls, and a mesh
// floor_t deep into the outer face of each plate: under a groove it goes
// through the groove floor, under a rib it is a blind pocket, so the groove
// walls (the detent bumps ride along them) stay whole. The carrier prints
// front face down, so +Y is up on the printer: every hole has a pointed
// roof along Y (no flat ceiling). Solid: the tab pockets at both ends and
// the top plate under each boss.
// "hex": honeycomb, whole cells only (60 deg roofs).
// "tri": triangle truss, see tri_panel (45 deg roofs).
mesh        = true;
mesh_style  = "tri";
mesh_f      = 8;     // hex across flats
mesh_tri_a  = 20;    // triangle cell: 2a along Y, a across
mesh_web    = 3;     // between holes
mesh_margin = 3;     // solid border around each panel

// Provenance tags (scad/lib/provenance.scad), each its own part for a second
// filament. The carrier's is inlaid flush in the skirt's front face, which
// prints on the bed. The rail prints drive face down (so the counterbores open
// upward instead of bridging), and its tag is raised from the floor of a
// pocket in the outer face, between the screw holes, with its top below the
// face so it can't catch in the groove. (Earlier tags: one-bead-wide text,
// black on black, unreadable.)
car_tag_w  = 100;        // across the skirt
rail_tag_w = 16;         // pocket, across the rail
rail_tag_pocket = 1.0;   // pocket depth
rail_tag_relief = 0.2;   // text top stays this far below the face

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
// the top face. The skirt is at the front, the print-bed end.
zt      = 2 * plate_t + inner_h;        // bottom of the top zone
top_h   = car_h - zt;
// Grooves run all the way through, with a tab pocket at each end (from when
// the carrier was meant to turn around). The drive front sits pocket_d in
// from the front.
car_d   = pocket_d + hdd_l + 0.5;
mount_y = [mount_y_front, car_d - mount_y_back];
// Inserts for both bays, so one carrier fits either. Mirrored, the other
// bay's holes land at car_w - (20.1, 31.2, 106.2, 118.3) from this edge;
// its 22.6 and 108.7 are too close to this bay's 20.1 and 106.2 for two
// inserts, so it uses its pads' other holes (10.5 and 97.6) instead.
// Right bay: inserts at 20.1 and 106.2; left bay: 10.5 and 97.6. Each
// pair of inserts (~9 apart) shares one widened boss.
mount_x = [for (d = concat(mount_x_edge, [for (o = mount_x_other) car_w - o]))
           car_w / 2 - d];
rail_tag_l = hdd_side_hole_y[1] - hdd_side_hole_y[0] - cbore_d - 2;
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
module rail() with_provenance() {
    rail_body();
    // raised from the pocket floor; it runs along the rail and reads from
    // outside (-Z)
    translate([0, (hdd_side_hole_y[0] + hdd_side_hole_y[1]) / 2, rail_tag_pocket])
        rotate([0, 180, 90])
            provenance(w = rail_tag_l - 2, h = rail_tag_w - 2, depth = rail_tag_pocket - rail_tag_relief);
}

module rail_body() {
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
        // pocket for the provenance tag, between the counterbores
        translate([-rail_tag_w / 2, hdd_side_hole_y[0] + cbore_d / 2 + 1, -1])
            cube([rail_tag_w, rail_tag_l, 1 + rail_tag_pocket]);
    }
    // detent bumps on the beams' outer edges
    for (s = [-1, 1], y = [det_y, det_y_rear])
        translate([s * (rail_w / 2 + det_bump - det_r), y, 0])
            cylinder(r = det_r, h = rail_t);
}

/* ---------- Carrier ---------- */
// YZ profile extruded across X, centred on x0.
module along_x(w, x0 = 0) translate([x0 - w / 2, 0, 0]) rotate([90, 0, 90]) linear_extrude(w) children();

// Centres of the whole hexes (corners along v) that fit in the panel
// [u0, v0, u1, v1], keeping a web's width clear of each keep-out rectangle.
mesh_px = mesh_f + mesh_web;
mesh_py = mesh_px * sqrt(3) / 2;
mesh_hr = mesh_f / sqrt(3);     // centre to corner
function hex_cells(r, keep = []) = let(
    uc = (r[0] + r[2]) / 2, vc = (r[1] + r[3]) / 2,
    n  = ceil(max(r[2] - r[0], r[3] - r[1]) / mesh_py) + 1)
    [for (j = [-n : n], i = [-n : n])
        let(u = uc + (i + (abs(j) % 2) / 2) * mesh_px, v = vc + j * mesh_py,
            a = mesh_f / 2, b = mesh_hr)
        if (u - a >= r[0] && u + a <= r[2] && v - b >= r[1] && v + b <= r[3]
            && len([for (k = keep)
                    if (u + a + mesh_web > k[0] && u - a - mesh_web < k[2] &&
                        v + b + mesh_web > k[1] && v - b - mesh_web < k[3]) 1]) == 0)
            [u, v]];

// Hex prisms h tall (from Z=0) on a panel in the XY plane, corners along Y.
module hex_holes(r, h, keep = [])
    for (c = hex_cells(r, keep)) translate([c[0], c[1], 0])
        rotate(30) cylinder(r = mesh_hr, h = h, $fn = 6);

// Triangle lattice: struts along v plus diagonals at +-45 deg, which split
// the panel into right triangles with an edge along v and their right-angle
// corner pointing across, so every roof is 45 deg. It is a truss (the
// struts stretch instead of bending), so it stays stiff with big cells.
// Cells may be cut by the panel's sides (a wall along v) and bottom (a
// floor), but not its top: a cell whose tip would reach past the top edge
// is dropped, since the cut would be a flat roof. In a cell a keep-out
// cuts, the solid spreads down from the keep-out at 45 deg to the cell's
// own struts (a tent), so it grows from something below it and the hole
// left on each side has a 45 deg roof.
module tri_panel(r, keep = []) {
    a  = mesh_tri_a;
    d  = mesh_web / 2;
    tip = d / tan(22.5);    // insetting a 45 deg corner pulls its tip this far in
    uc = (r[0] + r[2]) / 2;
    // a row of cell tips lands exactly on the top edge, so none is lost there
    vc = r[3] + tip - a;
    nu = ceil((r[2] - r[0]) / (2 * a)) + 1;
    nv = ceil((r[3] - r[1]) / a) + 1;
    // remove slivers under 1 mm; delta offsets keep the corners sharp
    // keep-outs grown by a web
    kw = [for (k = keep) [k[0] - mesh_web, k[1] - mesh_web, k[2] + mesh_web, k[3] + mesh_web]];
    offset(delta = 0.5) offset(delta = -0.5)
        // each diamond (centre where j + l is odd) splits into two
        // triangles along its vertical diagonal
        for (j = [-nu : nu], l = [-nv : 1], s = [-1, 1])
            let(cu = uc + j * a, cv = vc + l * a,
                u0 = min(cu, cu + s * a), u1 = max(cu, cu + s * a),
                hits = [for (k = kw) if (k[0] < u1 && k[2] > u0 && k[1] < cv + a && k[3] > cv - a) k])
            if ((j + l) % 2 != 0 && cv + a - tip <= r[3])
                difference() {
                    intersection() {
                        translate([r[0], r[1]]) square([r[2] - r[0], r[3] - r[1]]);
                        offset(delta = -d)
                            polygon([[cu + s * a, cv], [cu, cv + a], [cu, cv - a]]);
                    }
                    // the tent reaches 2a down, past the bottom of any cell
                    for (k = hits) {
                        translate([k[0], k[1]]) square([k[2] - k[0], k[3] - k[1]]);
                        hull() {
                            translate([k[0], k[1]]) square([k[2] - k[0], 0.01]);
                            translate([k[0] - 2 * a, k[1] - 2 * a]) square([k[2] - k[0] + 4 * a, 0.01]);
                        }
                    }
                }
}

// Holes h tall (from Z=0) on a panel [u0, v0, u1, v1] in the XY plane,
// clear of the keep-out rectangles; corners point along +Y.
module mesh_holes(r, h, keep = [])
    if (mesh_style == "tri") linear_extrude(h) tri_panel(r, keep);
    else hex_holes(r, h, keep);

// Each of this bay's inserts (mount_x[0], [1]) sits ~9 from the other bay's
// nearest one, so each pair shares one boss: [centre x, half width].
boss_cols = [for (i = [0 : 1])
    let(e = mount_x[i], o = [mount_x[2], mount_x[3]],
        p = abs(o[0] - e) < abs(o[1] - e) ? o[0] : o[1])
    [(e + p) / 2, abs(e - p) / 2 + boss_r]];
// Where a boss's flare starts: it reaches full width where the boss does.
function boss_flare_y(yh, hw) = yh - boss_r - (hw - boss_web / 2);

// Plan-view footprints of the bosses: the ramp fin, and the flare + boss.
boss_keep = [for (yh = mount_y, c = boss_cols, k = [
                 [c[0] - boss_web / 2, yh - boss_r - top_h, c[0] + boss_web / 2, boss_flare_y(yh, c[1])],
                 [c[0] - c[1], boss_flare_y(yh, c[1]), c[0] + c[1], yh + boss_r]]) k];

module carrier_mesh() {
    // the detent notches are cut in the groove walls, above this layer, so
    // they need no keep-out
    r = [-car_w / 2 + wall_t + mesh_margin, pocket_d + mesh_margin,
         car_w / 2 - wall_t - mesh_margin, car_d - pocket_d - mesh_margin];
    translate([0, 0, -1]) mesh_holes(r, 1 + floor_t);
    translate([0, 0, zt - floor_t]) mesh_holes(r, floor_t + 1, boss_keep);
    // side walls, over the drive space: panel u = Z, v = Y
    for (s = [-1, 1])
        translate([s * (car_w / 2 - wall_t / 2) - (wall_t + 2) / 2, 0, 0])
            multmatrix([[0, 0, 1, 0], [0, 1, 0, 0], [1, 0, 0, 0]])
                mesh_holes([plate_t + mesh_margin, mesh_margin,
                           plate_t + inner_h - mesh_margin, car_d - mesh_margin], wall_t + 2);
}

// Top zone. Everything here prints front-face-down without support: the
// skirt is flush with the front face, so it starts on the bed, and each boss ramps up from the groove plate at
// 45 deg on its front side before reaching full height at the insert. The
// ramp is only a boss_web thick fin; just in front of the boss it flares
// out at 45 deg to the boss's width, so the boss's front face never hangs
// flat.
module top_zone() {
    // 2D (u, v) = (Y, Z)
    along_x(car_w) {
        // skirt: a wall flush with the front face, full width
        translate([0, zt - 0.01]) square([skirt_w, top_h + 0.01]);
    }
    for (yh = mount_y, c = boss_cols) intersection() {
        hw = c[1];
        along_x(2 * hw, c[0])
            polygon([[yh - boss_r - top_h, zt - 0.01], [yh - boss_r, car_h],
                     [yh + boss_r, car_h], [yh + boss_r, zt - 0.01]]);
        // plan view: the fin, then the flare
        y0 = boss_flare_y(yh, hw);
        translate([c[0], 0, zt - 1]) linear_extrude(top_h + 2)
            polygon([[-boss_web / 2, yh - boss_r - top_h - 1], [boss_web / 2, yh - boss_r - top_h - 1],
                      [boss_web / 2, y0], [hw, y0 + hw - boss_web / 2],
                      [hw, yh + boss_r + 1], [-hw, yh + boss_r + 1],
                      [-hw, y0 + hw - boss_web / 2], [-boss_web / 2, y0]]);
    }
}

module carrier() with_provenance() {
    carrier_body();
    // flush in the skirt's front face, read from the front; it prints on the bed
    translate([0, 0, zt + top_h / 2])
        rotate([90, 0, 0]) provenance(w = car_tag_w, h = top_h - 4, mode = "inlay");
}

module carrier_body() {
    difference() {
        union() {
            translate([-car_w / 2, 0, 0]) cube([car_w, car_d, zt]);
            top_zone();
        }
        if (mesh) carrier_mesh();
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
            // detent notches: both groove walls, both ends, one for each of
            // the rail's four bumps
            for (sx = [-1, 1], y = [pocket_d + det_y, pocket_d + det_y_rear])
                translate([x + sx * (rail_w / 2 + det_bump - det_r), y, z0 - 0.5])
                    cylinder(r = det_r + 0.3, h = groove_d + 1);
        }
        // M3 heat-sets in the top face, under the case's pad holes
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
