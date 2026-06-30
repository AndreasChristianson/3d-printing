// test_cube.scad — minimal sanity check for the OpenSCAD -> STL pipeline.
// Render to STL with:  openscad -o test_cube.stl test_cube.scad

$fn = 64; // smoothness of curved surfaces

// A rounded box: a cube with a cylinder hole through it, just to exercise
// a couple of CSG operations so the STL isn't trivially a primitive.
difference() {
    cube([30, 30, 10], center = true);
    cylinder(h = 20, r = 8, center = true);
}
