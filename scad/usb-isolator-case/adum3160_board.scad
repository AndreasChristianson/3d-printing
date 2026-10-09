// adum3160_board.scad
// Reference model of the Teyleten ADuM3160 USB isolator board (blue PCB).
// This is the GROUND TRUTH the case will be designed around.
//
// Axes (viewed from the component side, female USB-A end "up" as in the photos):
//   X = across the board, 0 = left edge (DIP switch side), + = right (B0505S side)
//   Y = along the board, 0 = male-A end edge, + toward the female-A end edge
//   Z = up, 0 = PCB bottom face
//
// Values marked (std) are standard USB-A sizes, not measured on this board.
// Values marked (est) are estimated from photos.
//
// Preview:  openscad -o adum3160_board.png --render --viewall --autocenter \
//             --imgsize=950,850 --colorscheme=Tomorrow adum3160_board.scad

$fn = 48;

/* ---------- Measured dimensions ---------- */
pcb_w = 22.9;   // X
pcb_l = 39.9;   // Y
pcb_t = 1.5;    // Z

bottom_clear = 2.0;   // max solder/pin protrusion below the PCB

// B0505S isolated DC-DC module: tallest part, on the right edge
dcdc_w       = 6.0;    // X
dcdc_l       = 11.5;   // Y
dcdc_from_fa = 14.5;   // gap from the female-A PCB edge to the module
dcdc_top     = 10.0;   // top height above the PCB top face
dcdc_standoff = 1.0;   // (est) gap under the body

// Female USB-A receptacle (device side, white BoxTurtle cable plugs in)
fa_w        = 13.5;   // 22.9 - 3.4 left gap - 6.0 right gap
fa_h        = 5.7;    // (std)
fa_len      = 14.0;   // (std) body length along Y
fa_z        = 2.0;    // shell bottom above PCB top face
fa_overhang = 2.0;    // mouth past the PCB edge
fa_x        = 3.4 + fa_w/2;   // 3.4 mm gap on the left, 6.0 on the right

// Male USB-A plug (host side, black cable's female socket slides on)
ma_w        = 12.0;   // (std)
ma_z        = -0.75;  // shell bottom vs PCB top face: sits ~half way down into the PCB (v1 test fit)
ma_h        = 5.25;   // keeps the shell top at 4.5 mm above the PCB, as fitted in v1
ma_protrude = 15.5;   // metal past the PCB edge
ma_inboard  = 5.0;    // (est) body on the PCB
ma_x        = pcb_w/2;   // (est) centred

// Small parts (est, from the top photo)
dip_x = 0.5;  dip_y = 1.4;  dip_w = 3.5;  dip_l = 9.5;  dip_h = 5.5;
led_red  = [19.0, pcb_l - 2.5];   // power LED, female-A end (v1 test fit: +1 X, -1 Y)
led_blue = [ 7.5, 11.9];          // status LED, middle    (v1 test fit: -1 Y)
led_sz = [1.6, 0.8, 0.6];

/* ---------- Derived (used by the case) ---------- */
pcb_top    = pcb_t;
fa_y0      = pcb_l - fa_len + fa_overhang;
fa_mouth_y = pcb_l + fa_overhang;
ma_tip_y   = -ma_protrude;
fa_axis_z  = pcb_top + fa_z + fa_h/2;
ma_axis_z  = pcb_top + ma_z + ma_h/2;
ma_top_z   = pcb_top + ma_z + ma_h;
fa_top_z   = pcb_top + fa_z + fa_h;
dcdc_y0    = pcb_l - dcdc_from_fa - dcdc_l;
board_top  = pcb_top + dcdc_top;   // highest point

/* ---------- Model ---------- */
module pcb()        color("RoyalBlue") cube([pcb_w, pcb_l, pcb_t]);
module solder_zone() color("Silver", 0.35) translate([0, 0, -bottom_clear]) cube([pcb_w, pcb_l, bottom_clear]);

module female_a()
    color("LightGray")
    translate([fa_x - fa_w/2, fa_y0, pcb_top + fa_z]) cube([fa_w, fa_len, fa_h]);

module male_a()
    color("LightGray")
    translate([ma_x - ma_w/2, -ma_protrude, pcb_top + ma_z]) cube([ma_w, ma_protrude + ma_inboard, ma_h]);

module dcdc()
    color("DimGray")
    translate([pcb_w - dcdc_w, dcdc_y0, pcb_top + dcdc_standoff])
        cube([dcdc_w, dcdc_l, dcdc_top - dcdc_standoff]);

module dip()
    color("Red") translate([dip_x, dip_y, pcb_top]) cube([dip_w, dip_l, dip_h]);

module led(p, c)
    color(c) translate([p[0] - led_sz[0]/2, p[1] - led_sz[1]/2, pcb_top]) cube(led_sz);

module adum3160_board(show_keepout = true) {
    pcb();
    if (show_keepout) solder_zone();
    female_a();
    male_a();
    dcdc();
    dip();
    led(led_red, "OrangeRed");
    led(led_blue, "DeepSkyBlue");
}

board_standalone = true;   // a file that includes this one sets it false
if (board_standalone) adum3160_board();
