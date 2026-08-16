// keyboard_layout.scad
// THE layout — data only. This is the file you edit to change your board.
// Consumed with `include <keyboard_layout.scad>` by the per-part entry files
// (plate.scad, case.scad, preview.scad, assembly.scad).
//
// ------------------------------------------------------------------ HOW TO USE
// keys — one row per key:   [ x, y, w, stab, "label", "shift" ]
//   x, y   top-left corner of the key, in U, from the plate's TOP-LEFT corner.
//          y increases DOWNWARD (like keyboard-layout-editor). Use 0.25U steps.
//   w      key width in U (1, 1.25, 1.5, 1.75, 2, 2.25, 2.75, 6.25, ...). 1U tall.
//   stab   true if this key needs a stabilizer cutout (2U+ keys, spacebar).
//   label  primary legend, engraved top-left on the keycap.
//   shift  OPTIONAL 6th field: the shifted symbol, engraved under the primary
//          (e.g. 7 -> "&", ' -> "\""). Use "" if you only need the 7th field.
//   opts   OPTIONAL 7th field: a list of behavior flags for the keycap —
//            "homing"  add a tactile home-row bar (F & J)
//            "flat"    no top dish (leave the top flat, e.g. the spacebar)
//            "nolabel" don't engrave any legend on the cap
//          e.g. [ 3.75, 5.25, 6.25, true, "Space", "", ["flat","nolabel"] ]
//
// encoders — rotary encoders, same x, y, w grid:   [ x, y, w, "label" ]
//   Cuts a round EC11 shaft hole centered in the cell (no stab field).
//
// supports — case posts holding the plate up:   [ x, y ] = post CENTER in U.
//   Place in the row-boundary / gap lanes so they miss the switch bodies below.
//
// The board is a fixed rectangle board_w x board_h (in keyboard_lib.scad); keys
// can sit anywhere on it in 0.25U steps — including gaps for an "exploded" look.

keys = [
    // function row (top)
    [  0.00, 0.00, 1.00, false, "Esc" ],
    [  2.00, 0.00, 1.00, false, "F1"  ],
    [  3.00, 0.00, 1.00, false, "F2"  ],
    [  4.00, 0.00, 1.00, false, "F3"  ],
    [  5.00, 0.00, 1.00, false, "F4"  ],

    [  6.50, 0.00, 1.00, false, "F5"  ],
    [  7.50, 0.00, 1.00, false, "F6"  ],
    [  8.50, 0.00, 1.00, false, "F7"  ],
    [  9.50, 0.00, 1.00, false, "F8"  ],

    [ 11.00, 0.00, 1.00, false, "F9"  ],
    [ 12.00, 0.00, 1.00, false, "F10"  ],
    [ 13.00, 0.00, 1.00, false, "F11"  ],
    [ 14.00, 0.00, 1.00, false, "F12"  ],

    // number row — note the 0.25U vertical gap below the function row
    [  0.00, 1.25, 1.00, false, "`", "~" ],
    [  1.00, 1.25, 1.00, false, "1", "!" ],
    [  2.00, 1.25, 1.00, false, "2", "@" ],
    [  3.00, 1.25, 1.00, false, "3", "#" ],
    [  4.00, 1.25, 1.00, false, "4", "$" ],
    [  5.00, 1.25, 1.00, false, "5", "%" ],
    [  6.00, 1.25, 1.00, false, "6", "^" ],
    [  7.00, 1.25, 1.00, false, "7", "&" ],
    [  8.00, 1.25, 1.00, false, "8", "*" ],
    [  9.00, 1.25, 1.00, false, "9", "(" ],
    [ 10.00, 1.25, 1.00, false, "0", ")" ],
    [ 11.00, 1.25, 1.00, false, "-", "_" ],
    [ 12.00, 1.25, 1.00, false, "=", "+" ],
    [ 13.00, 1.25, 2.00, true,  "Bksp" ],   // 2U key -> stabilizer

    // tab row
    [  0.00, 2.25, 1.50, false, "tab"  ],
    [  1.50, 2.25, 1.00, false, "q"    ],
    [  2.50, 2.25, 1.00, false, "w"    ],
    [  3.50, 2.25, 1.00, false, "e"    ],
    [  4.50, 2.25, 1.00, false, "r"    ],
    [  5.50, 2.25, 1.00, false, "t"    ],
    [  6.50, 2.25, 1.00, false, "y"    ],
    [  7.50, 2.25, 1.00, false, "u"    ],
    [  8.50, 2.25, 1.00, false, "i"    ],
    [  9.50, 2.25, 1.00, false, "o"    ],
    [ 10.50, 2.25, 1.00, false, "p"    ],
    [ 11.50, 2.25, 1.00, false, "[", "{" ],
    [ 12.50, 2.25, 1.00, false, "]", "}" ],
    [ 13.50, 2.25, 1.50, false,  "\\", "|" ],

    // caps lock row
    [  0.00, 3.25, 1.75, false, "caps" ],
    [  1.75, 3.25, 1.00, false, "a"    ],
    [  2.75, 3.25, 1.00, false, "s"    ],
    [  3.75, 3.25, 1.00, false, "d"    ],
    [  4.75, 3.25, 1.00, false, "f", "", ["homing"] ],
    [  5.75, 3.25, 1.00, false, "g"    ],
    [  6.75, 3.25, 1.00, false, "h"    ],
    [  7.75, 3.25, 1.00, false, "j", "", ["homing"] ],
    [  8.75, 3.25, 1.00, false, "k"    ],
    [  9.75, 3.25, 1.00, false, "l"    ],
    [ 10.75, 3.25, 1.00, false, ";", ":" ],
    [ 11.75, 3.25, 1.00, false, "'", "\"" ],
    [ 12.75, 3.25, 2.25, true , "enter"],

    // shift row
    [  0.00, 4.25, 2.25, true, "shift" ],
    [  2.25, 4.25, 1.00, false, "z"    ],
    [  3.25, 4.25, 1.00, false, "x"    ],
    [  4.25, 4.25, 1.00, false, "c"    ],
    [  5.25, 4.25, 1.00, false, "v"    ],
    [  6.25, 4.25, 1.00, false, "b"    ],
    [  7.25, 4.25, 1.00, false, "n"    ],
    [  8.25, 4.25, 1.00, false, "m"    ],
    [  9.25, 4.25, 1.00, false, ",", "<" ],
    [ 10.25, 4.25, 1.00, false, ".", ">" ],
    [ 11.25, 4.25, 1.00, false, "/", "?" ],
    [ 12.25, 4.25, 1.75, false, "shift"],

    // ctrl row
    [  0.00, 5.25, 1.25, false, "ctrl" ],
    [  1.25, 5.25, 1.25, false, "super"  ],
    [  2.50, 5.25, 1.25, false, "alt"  ],
    [  3.75, 5.25, 6.25, true,  "Space", "", ["flat","nolabel"] ],
    [ 10.00, 5.25, 1.50, false, "atl"  ],
    [ 11.50, 5.25, 1.50, false, "crtl" ],

    // arrows
    [  13.50, 5.75, 1.00, false, "<"   ],
    [  14.50, 4.75, 1.00, false, "^"   ],
    [  15.50, 5.75, 1.00, false, ">"   ],
    [  14.50, 5.75, 1.00, false, "v"   ],

    // nav-cluster
    [ 15.50, 1.25, 1.00, false, "home" ],
    [ 15.50, 2.25, 1.00, false, "end" ],
    [ 15.50, 3.25, 1.00, false, "del" ],
];

// ROTARY ENCODERS — same x, y, w grid units as keys. [ x, y, w, "label" ]
encoders = [
    [ 15.50, 0.00, 1.00, "Vol" ],
];

// SUPPORT POSTS — [ x, y ] = post CENTER in U field coords. 3 rows x 6 columns
// across the main block, plus the right-side lane.
supports = [
    [ 1.00, 1.12 ], [ 3.40, 1.12 ], [ 5.80, 1.12 ], [ 8.20, 1.12 ], [ 10.60, 1.12 ], [ 13.00, 1.12 ],
    [ 1.00, 3.25 ], [ 3.40, 3.25 ], [ 5.80, 3.25 ], [ 8.20, 3.25 ], [ 10.60, 3.25 ], [ 13.00, 3.25 ],
    [ 1.00, 5.25 ], [ 3.40, 5.25 ], [ 5.80, 5.25 ], [ 8.20, 5.25 ], [ 10.60, 5.25 ], [ 13.00, 5.25 ],
    // right side: the clear lane between the main block and the nav column,
    // plus one in the ctrl/arrow gap
    [ 15.10, 1.12 ], [ 15.10, 3.25 ], [ 15.10, 5.75 ]
];

/* ---- bill of materials (printed on render) ---- */
echo(str("Switches needed (MX): ", len(keys)));
echo(str("Rotary encoders (EC11): ", len(encoders)));
echo(str("Support posts: ", len(supports)));
