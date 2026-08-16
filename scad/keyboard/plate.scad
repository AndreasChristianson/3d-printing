// plate.scad — the printable 5 mm switch plate.
//   openscad -o plate.stl plate.scad
// Print switch-side DOWN for a clean top face and no cutout overhang.
include <keyboard_layout.scad>
use     <keyboard_lib.scad>

plate(keys, encoders, supports);
