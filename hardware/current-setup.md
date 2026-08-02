# Current Setup

Details of the existing printer(s) and toolchain. Seeded from the repo + prior notes;
**everything marked _(TBC)_ needs confirmation or fill-in from you.**

## Printer: Anycubic Kobra Max (modded)

| Area | Detail | Notes |
|------|--------|-------|
| Frame / base | Anycubic Kobra Max | Cartesian bedslinger, stock frame, modded |
| Control board | BigTreeTech SKR Mini E3 **v3.0** | MCU STM32G0B1 (`stm32g0b1xx`), 8KiB bootloader, USB, 64 MHz |
| Stepper drivers | TMC2209 ×4 (X/Y/Z/E), UART, stealthChop | run_current: X 0.80 / Y 0.90 / Z 1.00 / E 0.80 |
| Firmware | Klipper `v0.13.0-170-g4e4a5c633`; MCU `v0.13.0-154-g9346ad191` | (Status pane once showed host `-dirty`; git tree reports clean) |
| Stack | Klipper + Moonraker `v0.9.3-95` + **Mainsail v2.14.0** (nginx) | Web UI at `http://klipper2/` (`192.168.0.210`) |
| Host | **Raspberry Pi 5 Model B Rev 1.0, 4 GB RAM** | Debian 12 bookworm, kernel 6.12 (rpi-2712). Uptime healthy |
| Touchscreen | **KlipperScreen** on a 5" USB touchscreen (MPI5001, USB `0484:5750`) | Local physical control panel |
| Camera | Raspberry Pi camera via **spyglass** (Picamera2 MJPG streamer) | Print monitoring; `/dev/video0` (CSI) |
| Build volume | 402 × 425 mm bed, Z −5 → 395 mm | `position_max` X 402 / Y 425 / Z 395; kinematics: cartesian |
| Extruder | Direct drive, `rotation_distance` 24.6 (calibrated) | pressure_advance 0.100 |
| Hotend | Thermistor "Generic 3950", `max_temp` 300 °C | _(TBC — all-metal? make/model?)_ |
| Nozzle | 0.4 mm hardened steel | |
| Bed | Aftermarket PEI surface on stock heated bed | EPCOS 100K B57560G104F thermistor, `max_temp` 130 °C. ⚠️ Magnetic base sticker peeling — needs re-adhesive/replacement |
| Bed leveling | Klipper bed mesh, 6×6 probe grid, zero-ref @ 200,200 | mesh 15,30 → 365,415; fade 5→20 |
| Probe | BLTouch | x_offset −36, y_offset 6, z_offset 4.090; `safe_z_home` @ 200,200; virtual Z endstop |
| Endstops | Physical X (PC0) & Y (PC1); Z via probe | |
| Filament sensor | `filament_motion_sensor` (motion-type runout), detection_length 15 mm | |
| Fans | Part-cooling (PC6), heatbreak heater_fan (PB15), controller_fan (PC7) | Custom self-designed shroud (Fusion) |
| Status LEDs | Neopixel strip, 21 LEDs (PA8) w/ `led_effect` (printing/pause/heater states) | RGB status-lighting mod |
| Motion limits (printer.cfg) | max_velocity 300, max_accel 1000, max_z_velocity 5, max_z_accel 100 | ⚠️ Orca machine profile advertises higher accel (2000+) than firmware caps |
| PID | Extruder & bed PID-tuned (SAVE_CONFIG) | |

### Known mods
- SKR Mini E3 **v3.0** board swap (from stock Trigorilla) — TMC2209 drivers, stealthChop
- Klipper firmware conversion (Mainsail UI)
- BLTouch probe for auto bed-leveling (6×6 mesh)
- `filament_motion_sensor` runout detection
- Neopixel 21-LED status strip with `led_effect` animations (printing / pause / heater temp)
- KlipperScreen on a 5" USB touchscreen (MPI5001)
- Raspberry Pi camera + spyglass streamer for print monitoring
- Raspberry Pi 5 (4 GB) as the Klipper host
- Custom self-designed fan shroud (modeled in Autodesk Fusion)
- Aftermarket PEI bed surface (magnetic) — ⚠️ magnetic base sticker peeling, needs attention
- _(TBC — other mods: linear rails? extruder? hotend upgrade? PSU? etc.)_

## Printer: Creality Ender 3 V3 SE

| Area | Detail | Notes |
|------|--------|-------|
| Frame / base | Creality Ender 3 V3 SE | Mostly stock (no mods) |
| Ownership | Son's printer — he owns/uses it; you maintain it and supply filament | |
| Control board | Stock Creality board | MACHINE_TYPE `Ender-3 V3 SE`, UUID cede2a2f… |
| Firmware | **Marlin V1.0.6** (build Sep 19 2023) | Stock Creality Marlin. Caps: AUTOLEVEL, Z_PROBE, EEPROM, THERMAL_PROTECTION, ARCS, BABYSTEPPING; RUNOUT **not** present |
| Host | **Raspberry Pi 4 Model B Rev 1.5**, 4 GB RAM, 4 cores @ 1.8 GHz | Raspberry Pi OS (Linux 6.12 bookworm, aarch64). No undervoltage/throttling (0x0) |
| Print server | **OctoPrint 1.11.2** (Python 3.11.2, venv) | ⚠️ 6 releases behind (latest 1.11.8). ⚠️ Storage 89.8% full |
| Build volume | ~220 × 220 × 250 mm | Stock spec |
| Extruder | Direct drive ("Sprite"-style) | Stock on the V3 SE |
| Bed leveling | CR Touch auto-leveling (AUTOLEVEL/Z_PROBE caps) | Stock on the V3 SE |
| Nozzle | 0.4 mm | _(TBC — stock brass?)_ |

## Toolchain

| Tool | Detail |
|------|--------|
| Slicer | OrcaSlicer (GUI workflow) |
| Slicer configs | Git-tracked in this repo (`configs/machine`, `configs/filament`, `configs/process`) |
| CAD | OpenSCAD (`scad/` dir, rendered via `openscad -o`) |
| Firmware UI (Kobra Max) | Klipper / Moonraker at `http://klipper2/` |
| Firmware UI (Ender 3 V3 SE) | OctoPrint 1.11.2 on a Raspberry Pi 4B (4 GB) _(TBC hostname/URL)_ |

## Materials in use
- Generic PLA (profile in `configs/filament/`)
- _(TBC — other filaments: PETG? TPU? ABS?)_

## Open questions to fill in
- [x] SKR Mini E3 version — **v3.0** (STM32G0B1)
- [x] Klipper host hardware — **Raspberry Pi 5 (4 GB)**, Debian 12
- [~] Hotend make/model — thermistor Generic 3950, max 300 °C; confirm all-metal & make
- [x] Probe / bed-leveling sensor — BLTouch
- [~] Full list of existing mods — mostly captured; confirm PSU / rails / any extruder swap
- [ ] Other filaments regularly printed
- [x] Ender 3 host — Raspberry Pi 4B (4 GB), OctoPrint 1.11.2; confirm hostname/URL

## Maintenance / to-do (surfaced from config + diagnostics)
- [ ] **Kobra:** re-adhere or replace peeling PEI magnetic base sticker
- [ ] **Kobra:** reconcile Orca machine-profile accel (2000) with firmware `max_accel` (1000)
- [ ] **Kobra:** host Klipper build is `-dirty` — note/track local changes so they're not lost on update
- [ ] **Ender:** OctoPrint 6 releases behind (1.11.2 → 1.11.8) — update
- [ ] **Ender:** SD/storage 89.8% full — clean up uploads/timelapses
