// wire_label.scad
// Two-color flag label for small wire groups (2-6 x 22-28 AWG, silicone/PTFE,
// optionally sleeved). The label runs ALONG the wire, text facing out, held at
// both ends so it can't spin or slide.
//
// Text modes:
//   inlay  - prints FACE DOWN; text is flush in the face, mirrored on the bed.
//            One filament change per text layer (txt_t / layer height), shared
//            by every label on the plate. Smooth bed-textured face.
//   raised - prints face up; text stands on top. One change total. stail only:
//            face-up, the clip would stand on two sub-mm strips of ring wall.
//
// Styles:
//   stail - flat tab with a serpentine tail at each end. The wire runs behind
//           the tab, then weaves out through the first slot, over the first
//           bar, back through the second slot. Slots open alternately top and
//           bottom, so it goes on a wire that's already terminated.
//   wave  - tail leaves the MIDDLE of each tab end (on the wire line) and
//           wiggles with shrinking amplitude to nearly straight. The wire
//           weaves across it at every zero crossing; the first lobe just fits
//           the bundle and the later ones pinch it, so it can't wander.
//   zip   - flat tab with a pair of zip-tie slots at each end, one either side
//           of the wire line. One tie per end: down one slot, around the
//           bundle behind the tab, up the other. Only a short strap crosses
//           the face; turn the loop so the head sits behind the wire.
//   clip  - C-channel the length of the tab. The mouth (clip_mouth) is narrower
//           than the bundle but wider than one wire, so feed the wires in one
//           at a time; the bundle can't fall out.
//
// X = along the wire, Y = across the label, Z = up (print direction).
//
// Renders:
//   openscad --enable=textmetrics -o base.stl -D 'part="base"' -D 'txt="HEATER"' wire_label.scad
//   openscad --enable=textmetrics -o text.stl -D 'part="text"' -D 'txt="HEATER"' wire_label.scad
//   build_3mf.py renders a whole plate of these.

part      = "all";       // "base" | "text" | "all"
style     = "stail";     // "stail" | "wave" | "zip" | "clip"
text_mode = "inlay";     // "inlay" | "raised" (not clip)
txt       = "HEATER";
bundle_d  = 3.5;         // wire group diameter (flattened bundles: use the thick side)

/* ---------- Text ---------- */
font     = "Helvetica Neue:style=Condensed Bold";
txt_size = 5.2;          // OpenSCAD text size; caps come out ~3.8 mm
txt_t    = 0.6;          // 3 layers at 0.2; use 0.8 for light text on a dark base
pad_x    = 2.0;          // text -> tab end
min_len  = 14;           // short words still get a usable tab

/* ---------- Tab ---------- */
tab_h    = 8;            // across the wire
base_t   = 1.6;          // tab / clip face plate thickness, text included
corner_r = 1.5;

/* ---------- S-tail ---------- */
bar_w    = 1.8;          // serpentine strip width
n_bars   = 2;            // bars per end; the tab itself is the first "bar"
slot_g   = bundle_d;     // slot width; the wire passes through it on a slant

/* ---------- Wave ---------- */
wave_half  = 1.5 * bundle_d;              // X length of one lobe (crossing to crossing)
wave_n     = 3;                           // lobes per end
wave_a0    = bundle_d / 2 + bar_w / 2;    // first lobe: wire just fits under the strip
wave_a1    = 0.25 * wave_a0;              // last lobe: nearly straight

/* ---------- Zip ---------- */
zip_w   = 3.0;           // slot along the wire (tie width); fits 2.5 mm ties
zip_t   = 1.6;           // slot across the wire (tie thickness + clearance)
zip_rim = 1.5;           // material around the slots

/* ---------- Clip ---------- */
clip_w    = 1.3;                         // ring wall
clip_mouth = max(2.2, 0.55 * bundle_d);   // opening, on top as printed

$fn = 64;

inlay = style == "clip" || text_mode == "inlay";

tm    = textmetrics(text = txt, size = txt_size, font = font, halign = "center", valign = "center");
tab_l = max(min_len, tm.size.x + 2 * pad_x);

module rrect(size, r) {
    offset(r) offset(-r) square(size, center = true);
}

// Inlay text is mirrored: it's read from the bed side.
module text_2d() {
    mirror([inlay ? 1 : 0, 0])
        text(txt, size = txt_size, font = font, halign = "center", valign = "center");
}

module label_text() {
    translate([0, 0, inlay ? 0 : base_t]) linear_extrude(txt_t) text_2d();
}

/* ---------- S-tail ---------- */

// Straight bar half-length. Tails get taller than the tab when the bundle is
// big: the wire at y = 0 needs a bundle's width of slot between it and the
// open end, or it pops out.
ys = max(tab_h / 2 - slot_g / 2 - bar_w, bundle_d / 2);

module uturn(up) {
    ro = slot_g / 2 + bar_w;
    intersection() {
        difference() { circle(r = ro); circle(r = slot_g / 2); }
        translate([-ro, up ? 0 : -ro]) square([2 * ro, ro]);
    }
}

// One tail, starting at the tab's +X edge (local x = 0) and running +X.
module stail_tail_2d() {
    for (k = [1 : n_bars]) {
        xb = k * slot_g + (k - 1) * bar_w;     // left edge of bar k
        up = k % 2 == 1;
        translate([xb, -ys]) square([bar_w, 2 * ys]);
        translate([xb - slot_g / 2, up ? ys : -ys]) uturn(up);
    }
    xl = n_bars * slot_g + (n_bars - 1) * bar_w;
    translate([xl + bar_w / 2, n_bars % 2 == 1 ? -ys : ys]) circle(d = bar_w);
}

module stail_base() {
    linear_extrude(base_t) {
        rrect([tab_l, tab_h], corner_r);
        // Point-symmetric tails: the -X slot opens on the opposite edge, so a
        // tug on the wire can't walk the label off in either direction.
        for (s = [0, 180]) rotate(s) translate([tab_l / 2, 0]) stail_tail_2d();
    }
}

/* ---------- Wave ---------- */

function wave_y(x) =
    let (t = x / (wave_n * wave_half))
    (wave_a0 + (wave_a1 - wave_a0) * t) * sin(180 * x / wave_half);

// One tail from the middle of the tab's +X edge (local x = 0), running +X.
module wave_tail_2d() {
    len = wave_n * wave_half;
    steps = ceil(len / 0.3);
    for (i = [0 : steps - 1]) hull() {
        x0 = len * i / steps;
        x1 = len * (i + 1) / steps;
        translate([x0, wave_y(x0)]) circle(d = bar_w, $fn = 24);
        translate([x1, wave_y(x1)]) circle(d = bar_w, $fn = 24);
    }
}

module wave_base() {
    linear_extrude(base_t) {
        rrect([tab_l, tab_h], corner_r);
        for (s = [0, 180]) rotate(s) translate([tab_l / 2 - 0.5, 0]) wave_tail_2d();
    }
}

/* ---------- Zip ---------- */

zip_ext   = zip_w + 2 * zip_rim;                         // end pad, along the wire
zip_sy    = bundle_d / 2 + zip_t / 2;                    // slot centers: strap hugs the bundle
zip_pad_h = max(tab_h, 2 * (zip_sy + zip_t / 2 + zip_rim));

module zip_base() {
    linear_extrude(base_t) difference() {
        // Pads centered on their slots, so the shoulder by the text sits as far
        // from the slots as the outer end. The tab runs to the slot centers to
        // fill the joint.
        union() {
            rrect([tab_l + zip_ext, tab_h], corner_r);
            for (s = [-1, 1]) translate([s * (tab_l / 2 + zip_ext / 2), 0])
                rrect([zip_ext, zip_pad_h], corner_r);
        }
        for (s = [-1, 1], t = [-1, 1]) translate([s * (tab_l / 2 + zip_ext / 2), t * zip_sy])
            rrect([zip_w, zip_t], 0.4);
    }
}

/* ---------- Clip ---------- */

clip_ri = bundle_d / 2;
clip_ro = clip_ri + clip_w;
clip_zc = base_t + clip_ri;          // bore sits right on the face plate
clip_h  = max(tab_h, 2 * clip_ro);

// Bore with a 45-degree peak, so the arms curling in toward the mouth print
// without droop.
module teardrop(r) {
    hull() {
        circle(r = r);
        polygon([[-r / sqrt(2), r / sqrt(2)], [0, r * sqrt(2)], [r / sqrt(2), r / sqrt(2)]]);
    }
}

// YZ profile: 2D x = world Y, 2D y = world Z. Face plate on the bed.
module clip_profile() {
    difference() {
        hull() {
            translate([0, clip_zc]) circle(r = clip_ro);
            translate([0, base_t / 2]) rrect([clip_h, base_t], 0.6);
        }
        translate([0, clip_zc]) teardrop(clip_ri);
        translate([-clip_mouth / 2, clip_zc]) square([clip_mouth, clip_ro + 1]);
    }
}

module clip_base() {
    rotate([90, 0, 90]) linear_extrude(tab_l, center = true) clip_profile();
}

/* ---------- Assembly ---------- */

assert(inlay || style != "clip", "clip prints face down: inlay text only");

if (part != "text")
    color("firebrick") difference() {
        if (style == "clip") clip_base();
        else if (style == "wave") wave_base();
        else if (style == "zip") zip_base();
        else stail_base();
        if (inlay) translate([0, 0, -1]) linear_extrude(txt_t + 1) text_2d();
    }
if (part != "base")
    color("white") label_text();
