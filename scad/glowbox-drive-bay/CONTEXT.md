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
| Side bay depth | **more than 154 mm** (caliper maxed out at 154.2) | `P_20261027_004819` |
| Top-plate cage slots | 2 rows × 3 columns per bay | `P_20261027_004459` |
| Slot rows, front-to-back spacing | 76.3 mm | `P_20261027_004904` |
| Slot column pitch | 28.9 mm | `P_20261027_004948` |
| Slot length | 8.0 mm | `P_20261027_004920` |

`P_20261027_004837` reads 107.8 mm, but it's unclear what that measured. Ask.

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

## Photos

`photos/` holds downsized copies from the phone:
- `P_20261025_*`: the old cage out of the case
- `P_20261027_*`: the case and the caliper measurements
