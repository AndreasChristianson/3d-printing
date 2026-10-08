# USB isolator case — design context

Hand-off notes for a fresh session. Goal: an OpenSCAD enclosure for a bare
ADuM3160 USB isolator board that sits inline on the BoxTurtle's USB cable.

## Why this exists

The BoxTurtle (AFC-Lite board, Klipper MCU `Turtle_1`) on the Kobra Max dropped off
USB mid-print (kernel: `usb usb3-port1: disabled by hub (EMI?)`). The MCU did not
reset, so it was a USB signal-integrity problem, not a brown-out. Fix installed
2026-10-07: an ADuM3160 isolator plus a clip-on ferrite. The isolator is currently a
bare PCB hanging in the cable run; it needs a case so nothing can short against it
or bridge its isolation barrier.

## The device

- **Board:** Teyleten Robot "ADUM3160 USB to USB Isolator", blue PCB. Parts: ADuM3160
  isolator IC, B0505S 1 W isolated DC-DC module (the black block; it runs warm),
  red power LED near the USB-A end, blue LED near the middle, red 1-position DIP
  switch (labelled "ON" / "1") next to the USB-C end.
- **Photo:** `~/Downloads/P_20261007_224554.jpg` (board in hand, both cables plugged
  in, USB-A end up).
- **Connectors**, one on each short end:
  - **USB-A female (device side):** the BoxTurtle's white kit A→C cable plugs in
    here. A clip-on ferrite sits on that cable a few cm from the plug.
  - **USB-C female (host side):** a black "Conable" C→A cable plugs in here and
    runs to the USB-A extension → Raspberry Pi.
- **DIP switch:** it selects full vs. low speed. It is already in the right
  position: the Pi enumerates the AFC-Lite at 12M (full speed) through it.
  **It must not be moved.** The case doesn't need to give access to it; covering it
  is a plus.

## Dimensions — not measured yet

Before modelling, get these from the user (calipers):
- PCB length × width × thickness
- Tallest component height on the top side (probably the B0505S block), and anything
  on the bottom side (solder joints, through-hole pins)
- Each connector: width, height, how far it sticks out past the board edge, and its
  height above the PCB
- **Overmold size of both mating plugs.** The white USB-A plug and the black USB-C
  plug housings are wider than the receptacles; the end openings must clear them.
- Mounting holes, if any: positions and diameters (the photo may show one near
  the USB-A end)
- Positions of the two LEDs and the DIP switch

## Requirements

- Fully enclose the PCB; leave only the two connector openings, sized for the
  plug overmolds.
- Plastic all round. No metal fasteners near the middle of the board, where the
  isolation gap is. No conductive filament.
- Some venting near the B0505S, since it gets warm.
- Hold the board so it can't slide when a plug is pulled out. A ledge or pins for
  the PCB edges, or a printed post through a mounting hole, both work.
- Nice to have: a thin window or light pipe so the LEDs are visible.
- Mounting: it lives just outside the BoxTurtle enclosure. Ask the user what to
  attach it to: a zip-tie slot, screw tabs, or attachment to the BoxTurtle frame
  or extrusion.
- Print-friendly: two parts (base + lid) that snap or screw together, no supports,
  PLA or PETG.

## How to work (repo conventions)

- **Model the board first.** Build a parametric reference model (`adum3160_board.scad`)
  from the measured dimensions, render it, and get the user to confirm it before
  designing the case around it. The case should `use`/`include` the board model
  for the cavity and fit checks. See the eero mount in `scad/eero-cradle/` for
  this pattern.
- Files go in `scad/usb-isolator-case/`. Render with `openscad -o out.stl file.scad`,
  then slice in OrcaSlicer (GUI).
- OpenSCAD 2021.01 is installed from the brew cask. If it gets SIGKILL'd (exit 137),
  run `xattr -dr com.apple.quarantine /Applications/OpenSCAD-2021.01.app`.
- Repo-wide agent rules are in `ai/ai-instructions.md`.
