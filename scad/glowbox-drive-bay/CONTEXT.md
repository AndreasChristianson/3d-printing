# glowbox drive bays — design context

Hand-off notes for a fresh session. Goal: printed drive carriers for glowbox's
4U rack case, so one drive can be swapped without touching the others.
Nothing has been modelled yet.

## The problem

The case has a left and a right side bay. Each holds a steel 5-slot cage: the drives
lie flat, stacked 5 high, held by side screws. A 120 mm fan bolts to the front of
each cage. Swapping one drive today means:
- pulling the whole cage out,
- unplugging every drive in it,
- unscrewing the drive from the cage.

The fan also hides the drive ends, so you can't tell which drive is which.

Current drives: 3 per cage, a mix of Toshiba N300 6TB and WD Red Plus 6TB. The plan
(late Oct 2026) is to go down to **4 drives total**. The motherboard has 8 SATA ports.

## Requirements (agreed 2026-10-27)

- **Small touch footprint:** the carrier stays put. Open the case, find the drive
  from the front, unplug only that drive at the back, slide it out the front.
  Other drives are never unplugged or moved.
- **Visibility, not labels:** we want to read the drives' own serial stickers.
  No printed labels.
- **The fans stay** but get out of the way: mount them on a hinged front door
  (the cable stays plugged in) or a snap-on frame.
- **Material:** PETG minimum, ASA preferred. Not PLA, which creeps at the
  40–50 °C a drive bay sits at.
- **Hold the drives firmly:** pins into the drive's real screw holes, no
  rattle. If you want isolation, use thin, firm TPU 95A pads; soft mounts let the
  drive rock when it seeks (rotational vibration), which slows an array.

## Current direction: drives vertical on their sides, in the side bays

Standing the drives on their sides puts the side screw holes facing up and down.
The rails or pins then go **above and below** each drive, not between drives.

| Drives per bay | Width left (of 130.3) | Gap between drives |
|---|---|---|
| 2 (the 4-drive plan) | ~78 mm | ~25 mm |
| 3 | ~52 mm | ~13 mm |
| 4 | ~26 mm | too tight (~5 mm walls) |

- **Height:** 149.7 − 101.6 = ~48 mm for the top and bottom guide channels.
- **Labels:** face each drive's label into an open gap so it can be read with a
  flashlight, from the front with the fan door open.
- **Mounting:** the carrier can reuse the top-plate slots the old cage hangs from.
  Each side carrier is about 130 × 150 × 170 mm, which fits the Kobra Max in one piece.

### Alternatives considered

- **The 3 open 5.25" bays in the middle** (about 146 W × 128 H):
  - a bought 4-in-3 or 5-in-3 hot-swap cage with a backplane: front trays, no
    case opening, per-slot LEDs, $50–150
  - or a printed 4-in-3 tool-less cage
  - kept as the fallback
- **Side carriers with drives flat, 5 high:** gaps are only about 4 mm and
  printed rails could cost a slot. Rejected.

## Airflow

- **A wall of 4 fans sits behind the bays** (photos `P_20261027_004536`, `004543`) and
  pulls air through the drive area. The front fans help, but they aren't the only
  cooling.
- **Vertical drives** leave gaps that line up with the airflow, which improves
  cooling.

## Measurements (read off caliper photos; confirm before modelling)

| What | Value | Photo |
|---|---|---|
| Side bay front opening, width | 130.3 mm | `P_20261027_004626` |
| Side bay front opening, height | 149.7 mm | `P_20261027_004745` |
| Bezel face → top plate rear edge (rod) | 154.2 mm | `P_20261027_004819` |
| Rod → fan wall | 107.8 mm (slightly diagonal) | `P_20261027_004837` |
| Bezel front face → near edge of front-row hole | 51.3 mm | `P_20261028_005920` |
| Bay inner wall → near edge of nearest empty hole | 31.7 mm | `P_20261028_005954` |
| Top-plate cage pads | 2 rows × 3 pads per bay, 2 holes each | `P_20261027_004459` |
| Pad rows, front-to-back spacing | 76.3 mm | `P_20261027_004904` |
| Pad pitch | 28.9 mm | `P_20261027_004948` |
| Hole pair spacing within a pad | 8.0 mm | `P_20261027_004920` |


Standard 3.5" drive: 147 L × 101.6 W × 26.1 H, about 0.7 kg.

## Still needed

- **Side bay depth:** front panel to the first obstacle behind it (tape measure).
- **The old cage's mounting:** a photo of the top-plate slots from underneath, or of the
  old cage's top face, to confirm the carrier can reuse them.
- **What's below each bay:** can a bottom rail rest on the case floor, or must the
  carrier hang entirely from the top?
- **The fan:** size (looks 120×25), mounting holes, cable route and length.
- **SATA cables:** slack per cable, straight or right-angle connectors.
- **One drive's front end** (opposite the connectors): is any serial visible?

## Version 0 (2026-10-28)

The carrier, rails and slice below are **v0**: the design is agreed but not printed.
Next step: take the remaining measurements when the next drive is installed (case
open), adjust, then print and test fit.

## 5.25" bay blanks (started 2026-10-28)

Goal: block airflow through the 3 middle 5.25" bays, so all front intake air goes
through the two side bays.
- **Fitted today:** black plastic grille bezels, one per bay. They clip in with a
  small peg/hook at each end, near the top and bottom corners. Photos are
  `P_20261028_0152*`.
- **Grille size:** body 147.9 W × 41.7 H. Across the clip tabs it's 151.1, so each
  tab sticks out ~1.6.
- **Tab positions** (`P_20261028_015937`, `_020013`): tabs are 4.5 mm wide with a
  17.3 mm gap between the two on each end, so each sits ~7.7 mm in from the top/bottom.
- **Whole 3-bay opening:** 147.8 × 128.9.
- **Chosen: option 2, solid replacement blanks.** The design is in `bay_blank.scad`
  (`bay_blank.stl`), one per bay.
  - The stock tabs hook deep and need a lot of flex to remove, which PETG won't take.
  - So each tab sits on its own end-wall arm, slit free except at a root in the
    middle of the end.
  - The tabs stick out 0.9 mm instead of 1.6, with 45° on both sides so a firm pull
    releases them. Strain at full flex is ~2.6%.
  - The depths are GUESSED (face 2, rim 8, tab 3 behind the face); measure them.
- **The bottom stock grille is screwed in;** blank #3 may need a screw hole.
- **Each stock grille has small risers on the back;** their purpose is unclear.
- **The old `filler` part** in `drive_bay.scad` was a guess (one 146 × 127 plug for
  all three bays). It's superseded by per-bay solid blanks.

## Update 2026-10-28: the first prototype

- **Case:** NORCO RPC-470 (the user identified it). NORCO has closed down, and no
  manual or drawings turned up online. One Newegg listing gives the RPC-470
  "4 80mm fans", which would be the internal fan wall.
- **Decision:** 3 drives per side bay, standing on their sides.
- **Cooling plan:**
  - the front 120 mm fans move to the internal fan wall; no front fans
  - a printed filler blocks the 3 middle 5.25" bays, so all front intake air goes
    through the two side bays
  - if the wall's fan holes are 80 mm, the 120 mm fans need adapter plates
    (not designed yet)
- **Prototype first, adjust later:** the server is in service, so the cages can't
  come out for measuring.

### Files
- **`hdd35.scad`:** reference model of the drive.
  - Side holes at the SFF-8300 positions: 28.5 and 130.1 mm from the front end,
    6.35 mm above the base.
  - Only the outer pair is used. WD's white paper says the middle side hole is
    missing on some high-capacity drives.
  - **Check the hole positions with calipers on a spare drive.**
- **`drive_bay.scad`:** the carrier, rails and filler. Parts: `assembly`,
  `carrier`, `slice`, `rail_top`, `rail_bottom`, `filler`.
  - Carrier: 128.8 W × 148.2 H × 153 D, 0.75 mm clearance per side in the opening.
  - **Drives sit as low as possible:** the bottom and top groove plates are 9 mm each
    (5 mm groove + 4 mm floor).
  - **Top zone (27 mm, up to the case's top plate) is mostly empty:**
    - 4 insert bosses, 10 × 10 mm, on the outer pads only; the middle pads are unused.
    - One skirt, a 3 mm wall flush with the front face, so it gets a flat
      footprint on the bed. It stops air bypassing the drives. In the
      other bay the carrier is turned around and the skirt sits at the back, which
      blocks air just as well.
    - Each boss ramps up at 45° on its front side, so the whole carrier still prints
      front face down with no supports.
  - Solid volume went from 838 to about 340 cm³. Sliced in Orca (standard Kobra Max
    process, 18% sparse infill), two carriers went from 727 g to 510 g: −217 g, −30%,
    about 255 g per carrier.
  - Drive pitch 42 mm: 15.9 mm gaps between drives, 6.35 mm at the walls.
  - Rails: 30 × 5 mm, screwed to the drive with 6-32 × 3/16" screws (2.8 mm into the
    drive, inside SFF's 3.02 mm limit).
  - **No handles (2026-10-28):** the case has a hinged front door (photos
    `P_20261028_0117*`), so nothing may stick out past the carrier front. To swap a
    drive, unplug it at the back and push it forward out of the front.
  - Rail tab: 5 mm long, 3 mm wider each side than the rail. It sits in a pocket at
    the carrier front, 0.5 mm below flush, and the pocket's back wall is the stop.
  - Lead-in chamfer on each rail's leading (rear) end: 2 mm on both sides, 1.5 mm on
    the outer face.
  - Detent: a flexing beam on the rail with a bump that clicks into a notch in the
    groove wall, 16 mm in from the front.
  - **Reversible carrier:** the grooves run all the way through, so one carrier fits
    both bays, turned 180° (front ↔ back) for the other side. It has a tab pocket at
    each end. There are detent notches at
    both ends, so the bump gives one extra click as it passes the far notch on the
    way in.
- **STLs are in print orientation:** carrier and slice front face down, rails
  drive face down.

### Case fit
- **Mounting (measured 2026-10-28, `P_20261028_005920` and `_005954`):** each of the
  2 × 3 pads has **two round holes 8.0 mm apart**; the old cage uses one of each pair.
  Rows are 76.3 mm apart and pads 28.9 mm apart.
  - Front-back: 51.3 mm from the bezel front face to the near edge of a front-row
    hole, so the centre is ~53. The rows are centred in the carrier's depth (so it
    works either way round). That puts the carrier front ~15 mm behind the bezel
    face, and nothing in front of it, so the door closes.
  - Left-right: 31.7 mm from the bay's wall on the middle side (next to the 5.25"
    bays) to the
    near edge of the empty hole. The screwed hole is 8 mm closer to the wall, so its
    centre is ~25.4 mm from the wall.
  - The pattern is **not centred** on the bay. The case is mirror-symmetric (user),
    so the turned-around carrier matches the other bay. Install it pushed against
    the middle-side wall.
  - **Accuracy:** hole positions were measured to an edge, good to ~1 mm. Round
    holes leave little slack, so check alignment with the slice first (below).
    Fallback if a hole is off: drill a new insert hole by hand where it should be.
- **Bay depth:** 154.2 from the bezel face to the top plate's rear edge (the rod),
  then 107 to the fan wall (user confirmed; slightly diagonal because the fan wall
  stops short of the top). The carrier's rear sits at ~168 mm from the bezel face.
- **5.25" filler:** sized from the standard (146 × 127 plug), not measured.
  Measure the opening (it's open and reachable) before printing.

### Suggested test order
1. Print `rail_top` + `rail_bottom` and screw them to a spare or retired drive. This checks the hole positions.
2. Print `slice` (45 mm deep, includes the front mount row). Slide the railed drive
   through it to check the groove fit and the detent click. When a cage is out,
   offer the slice up under the top plate to check the front row of holes.
3. Print the full `carrier` (×2, same file) only after both pass.

## Photos

`photos/` holds downsized copies from the phone:
- `P_20261025_*`: the old cage out of the case
- `P_20261027_*`, `P_20261028_0059*`: the case and the caliper measurements
- `P_20261028_0117*`: the hinged front door
