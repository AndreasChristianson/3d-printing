// Halloween antler, split into three color regions for a BoxTurtle multi-color test.
//
// Source: "various horns with texture" by Karra_cos (Printables, CC BY-NC-SA 4.0),
// horns_base1.stl copied to models/. Single three-spike antler, flat base on z-min.
//
// Each spike gets two color changes, measured as straight-line distance from its tip:
//   base color  : everything farther than band_r from every tip
//   band color  : between tip_r and band_r from a tip
//   tip color   : within tip_r of a tip
//
// Render one part at a time (part = "base" | "band" | "tip"), or "all" to preview:
//   openscad -D 'part="tip"' -o horns_tip.stl horns_tricolor.scad

part = "all";

// The source STL is ~15.6 mm tall; 10x gives a ~156 mm costume antler.
scale_factor = 10;

// Color-zone radii, in final mm, scale with the model (1.2 / 3.0 source units). Checked
// against the mesh: up to 3.5 source units each sphere stays on its own spike.
tip_r  = 1.2 * scale_factor;
band_r = 3.0 * scale_factor;

// Spike tips, in source-STL coordinates (found via geodesic distance from the base).
tips = [
    [-9.42,  -9.67, 9.56],   // center (tallest)
    [-9.33,  -2.74, 4.90],   // +Y side
    [-9.36, -14.29, 4.60],   // -Y side
];

// Source base sits at z = -6.05; shift so the scaled part rests on z = 0.
base_z = -6.0522;

$fn = 96;

module place() translate([0, 0, -base_z * scale_factor]) scale(scale_factor) children();

module horn() place() import("../../models/horns_base1.stl", convexity = 6);

module zones(r) place() for (t = tips) translate(t) sphere(r = r / scale_factor);

module tip_part()  intersection() { horn(); zones(tip_r); }
module band_part() intersection() { horn(); difference() { zones(band_r); zones(tip_r); } }
module base_part() difference()   { horn(); zones(band_r); }

if (part == "tip"  || part == "all") color("orange")    tip_part();
if (part == "band" || part == "all") color("darkred")   band_part();
if (part == "base" || part == "all") color("dimgray")   base_part();
