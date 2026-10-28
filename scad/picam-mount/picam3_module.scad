// picam3_module.scad
// Reference model of the Raspberry Pi Camera Module 3 (standard lens, IMX708).
// This is the GROUND TRUTH the top-frame mount will be designed around.
//
// Source: Raspberry Pi "Camera Module 3 standard mechanical drawing"
//   https://datasheets.raspberrypi.com/camera/camera-module-3-standard-mechanical-drawing.pdf
// Values marked (est) were scaled off the drawing, not dimensioned on it.
// Not checked against a physical board yet; clone/Arducam boards may differ.
//
// Axes (viewed from the lens side, as in the drawing's front view):
//   X = across the board, 0 = left edge
//   Y = up the board, 0 = bottom edge (the end with the 8.9 mm notch);
//       the FPC connector and ribbon are at the TOP edge (+Y)
//   Z = toward the scene, 0 = PCB front face (lens side); the PCB is z -1.12..0
//
// Preview:  openscad -o picam3_module.png --render --viewall --autocenter \
//             --imgsize=950,850 --colorscheme=Tomorrow picam3_module.scad

$fn = 48;

/* ---------- Drawing dimensions ---------- */
pcb_w = 25;       // X
pcb_h = 23.862;   // Y
pcb_t = 1.12;
pcb_r = 2.0;      // (est) radius of the two top corners

// M2 mounting holes: 21 x 12.5 pattern
hole_d   = 2.2;
pad_d    = 4.75;   // copper keep-out ring around each hole
hole_in  = 2.0;    // hole centres from the left/right edges
hole_y0  = 2.0;    // lower pair, from the bottom edge
hole_y1  = 14.5;   // upper pair, from the bottom edge

// Lens: on the board's vertical centreline
lens_x     = pcb_w / 2;   // 12.5
lens_y     = 14.4;
housing_sq = 10.8;        // square sensor/lens housing
housing_h  = 3.875;       // housing front above the PCB front face
barrel_d   = 7.0;         // (est) outer diameter of the round lens barrel
aperture_d = 5.75;
lens_h     = 6.98;        // lens tip above the PCB front face

// Lens-side notch / flex area below the housing
notch_w = 8.9;
notch_h = 4.0;            // (est) from the 3.3 / 4 / 7.3 stack

// 15-pin FPC connector on the back, at the top edge
fpc_w = 19.61;
fpc_h = 5.71;             // along Y, down from the top edge
fpc_d = 11.3 - lens_h - pcb_t;   // depth behind the PCB back face (~3.2)

// Ribbon: 15-pin, 1 mm pitch, exits the top edge
ribbon_w = 16.0;
ribbon_t = 0.3;

// Field of view (standard lens). Wide lens is 102 x 67 deg.
// The sensor's long axis is X: to put the wide view along the bed's travel (Y),
// the mount turns the board 90 deg.
fov_h = 66;   // across X
fov_v = 41;   // along Y

/* ---------- Derived (used by the mount) ---------- */
holes = [[hole_in, hole_y0], [pcb_w - hole_in, hole_y0],
         [hole_in, hole_y1], [pcb_w - hole_in, hole_y1]];
housing_y0 = lens_y - housing_sq/2;
back_z     = -pcb_t;
fpc_back_z = -pcb_t - fpc_d;

/* ---------- Model ---------- */
module pcb_outline()
    hull() {
        square([pcb_w, 0.01]);
        translate([pcb_r, pcb_h - pcb_r]) circle(r = pcb_r);
        translate([pcb_w - pcb_r, pcb_h - pcb_r]) circle(r = pcb_r);
    }

module pcb()
    color("ForestGreen")
    translate([0, 0, -pcb_t])
    linear_extrude(pcb_t)
    difference() {
        pcb_outline();
        for (h = holes) translate(h) circle(d = hole_d);
    }

module housing() {
    color("DimGray")
    translate([lens_x - housing_sq/2, housing_y0, 0]) cube([housing_sq, housing_sq, housing_h]);
    color("Black")
    translate([lens_x, lens_y, housing_h]) difference() {
        cylinder(d = barrel_d, h = lens_h - housing_h);
        translate([0, 0, lens_h - housing_h - 0.4]) cylinder(d = aperture_d, h = 1);
    }
    color("SteelBlue")
    translate([lens_x, lens_y, lens_h - 0.5]) cylinder(d = aperture_d - 1, h = 0.1);
}

module fpc_connector()
    color("Beige")
    translate([(pcb_w - fpc_w)/2, pcb_h - fpc_h, fpc_back_z]) cube([fpc_w, fpc_h, fpc_d]);

module ribbon(len = 20)
    color("Orange", 0.7)
    translate([(pcb_w - ribbon_w)/2, pcb_h - fpc_h/2, fpc_back_z + fpc_d/2])
    cube([ribbon_w, fpc_h/2 + len, ribbon_t]);

// Light cone of the lens, for checking that the mount stays out of the view
module fov_cone(dist = 60)
    color("Yellow", 0.15)
    translate([lens_x, lens_y, lens_h])
    hull() {
        cube(0.01, center = true);
        translate([0, 0, dist])
            cube([2 * dist * tan(fov_h/2), 2 * dist * tan(fov_v/2), 0.01], center = true);
    }

module picam3(show_ribbon = true) {
    pcb();
    housing();
    fpc_connector();
    if (show_ribbon) ribbon();
}

picam3();
%fov_cone(25);
