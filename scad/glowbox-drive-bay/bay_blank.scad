// bay_blank.scad
// Solid blank for one 5.25" bay of glowbox's NORCO RPC-470, replacing the
// stock black grille. It blocks air so the front intake goes through the two
// side drive bays instead. Same outline and tab positions as the grille.
//
// Clips: the stock grille's tabs hook deep and need a lot of flex to remove,
// which PETG won't take. Here each tab sits on its own short arm (the end
// wall, slit free from the face and rims except at a root in the middle of
// the end), sticks out less, and has a 45 deg catch so a firm pull releases
// it.
//
// PROTOTYPE: outline and tab positions are measured (photos
// P_20261028_0152*, _0159*, _0200*); the depths are GUESSED. Print one and
// test the snap before printing three.
//
// Axes: X = across the bay (width), Y = up (height), Z = depth; Z=0 is the
// front face, +Z runs into the case. Prints face down as modelled; the arms
// are walls standing on the bed, so they flex in the print plane.
//
// Render:  scad/render.sh scad/glowbox-drive-bay/bay_blank.scad
// (fills in the provenance tag on the back of the face)

include <../lib/provenance.scad>

$fn = 32;

/* ---------- Measured (stock grille, 2026-10-28) ---------- */
blank_w  = 147.9;   // body width
blank_h  = 41.7;    // body height
stock_tab_w = 4.5;  // along the height
tab_gap  = 17.3;    // between the two tabs on one end
// Stock tabs stand 1.6 proud ((151.1 - 147.9) / 2).
// Whole 3-bay opening: 147.8 x 128.9, so the bays are on a ~43 mm pitch.

/* ---------- GUESSED: measure on the stock grille ---------- */
face_t   = 2.0;     // solid front face
rim_d    = 8;       // total depth, face to the back of the rim
tab_z0   = 3;       // tab starts this far behind the front face

/* ---------- Design choices ---------- */
tab_out  = 0.9;     // shallower than stock (1.6), for PETG
tab_w    = 3.5;     // Y; stock is 4.5, which was too tall for the case holes
tab_flat = 0.5;     // Z flat between the ramps (was 1)
rim_t    = 1.6;     // top/bottom rims
arm_t    = 1.2;     // end-wall arms, thin so they flex
root_l   = 6;       // where each end's arms join the body (middle of the end)
slit     = 0.8;
root_g   = 4;       // 45 deg gusset inside each root, end wall to face

/* ---------- Derived ---------- */
// tab centres, kept on the stock tabs' centres
tab_y = [-(tab_gap + stock_tab_w) / 2, (tab_gap + stock_tab_w) / 2];
tab_l = tab_out * 2 + tab_flat;   // along Z: 45 deg in, short flat, 45 deg out
arm_len = blank_h / 2 - rim_t - slit - root_l / 2;   // root to free tip
// Root strain at full deflection, for a cantilever loaded at the tab.
tab_arm = abs(tab_y[1]) - root_l / 2;
echo(arm_len = arm_len, tab_arm = tab_arm,
     strain_pct = 100 * 1.5 * arm_t * tab_out / (tab_arm * tab_arm));

// One tab on the +X end, pointing +X: 45 deg on both sides, so it cams
// in when pushed home and back out when pulled.
module tab() {
    // (u, v) = (X out from the end, Z)
    rotate([90, 0, 0]) linear_extrude(tab_w, center = true)
        polygon([[0, tab_z0], [tab_out, tab_z0 + tab_out],
                 [tab_out, tab_z0 + tab_out + tab_flat], [0, tab_z0 + tab_l]]);
}

// Gusset in the inside corner where the +X end wall's root meets the face.
// It stays within root_l, so the arms' free length (and flex) is unchanged.
module root_gusset() {
    // (u, v) = (X, Z)
    translate([blank_w / 2 - arm_t + 0.01, 0, face_t - 0.01])
        rotate([90, 0, 0]) linear_extrude(root_l, center = true)
            polygon([[0, 0], [-root_g, 0], [0, root_g]]);
}

module bay_blank() {
    difference() {
        union() {
            // face
            translate([-blank_w / 2, -blank_h / 2, 0]) cube([blank_w, blank_h, face_t]);
            // top/bottom rims
            for (sy = [-1, 1])
                translate([-blank_w / 2, sy > 0 ? blank_h / 2 - rim_t : -blank_h / 2, 0])
                    cube([blank_w, rim_t, rim_d]);
            // end walls (become the arms)
            for (sx = [-1, 1])
                translate([sx > 0 ? blank_w / 2 - arm_t : -blank_w / 2, -blank_h / 2, 0])
                    cube([arm_t, blank_h, rim_d]);
            // root gussets
            for (sx = [-1, 1]) mirror([sx < 0 ? 1 : 0, 0, 0]) root_gusset();
            // tabs
            for (sx = [-1, 1], y = tab_y)
                translate([sx * blank_w / 2, y, 0]) mirror([sx < 0 ? 1 : 0, 0, 0]) tab();
            // provenance tag on the back of the face, reads from behind
            translate([0, 0, face_t - 0.01]) provenance(size = 3.5);
        }
        for (sx = [-1, 1], sy = [-1, 1]) {
            // slit along the inside of each arm, through the face, from the
            // root out to the tip
            translate([sx * (blank_w / 2 - arm_t - slit / 2), sy * (root_l / 2 + (arm_len + slit) / 2), rim_d / 2])
                cube([slit, arm_len + slit + 0.02, rim_d + 2], center = true);
            // slit across the arm tip, freeing it from the rim corner
            translate([sx * (blank_w / 2 - (arm_t + slit) / 2), sy * (blank_h / 2 - rim_t - slit / 2), rim_d / 2])
                cube([arm_t + slit + 0.02, slit, rim_d + 2], center = true);
        }
    }
}

bay_blank();
