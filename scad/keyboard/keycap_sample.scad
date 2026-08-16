// keycap_sample.scad — one 1U keycap to eyeball the dish/legends and fit-test the stem.
//   Open in OpenSCAD and press F5 (preview) or F6 (render). Orbit to see the top.
//   Print top-face DOWN. If it won't press on, widen cross_w in keycap_lib.scad;
//   if it's loose/wobbly, narrow it (0.05 mm steps).
include <keycap_lib.scad>

// --- quick toggles for viewing (override the library defaults) ---
dish_type = "spherical";     // "cylindrical" or "spherical" — re-render to compare
label     = "J";              // primary legend (top-left); e.g. "7" or "Esc"; "" = blank
shift     = "";              // shifted legend (under the primary); e.g. "&"; "" = none
homing    = true;           // true adds the home-row tactile bar (like F/J)

keycap(1.00, false, label, shift, homing = homing);
