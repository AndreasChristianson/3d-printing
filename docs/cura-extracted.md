# Cura settings extracted for OrcaSlicer porting

Snapshot of the Kobra Max settings currently in Cura 5.12 (`~/Library/Application Support/cura/5.12/`), structured so you can hand-port them into OrcaSlicer's GUI and then export the resulting JSONs into `configs/`.

Source files this came from:
- `machine_instances/Anycubic+Kobra+Max.global.cfg`
- `definition_changes/Anycubic+Kobra+Max_settings.inst.cfg`
- `definition_changes/anycubic_kobra_max_extruder_0+%232_settings.inst.cfg`
- `user/Anycubic+Kobra+Max_user.inst.cfg`
- `user/anycubic_kobra_max_extruder_0+%232_user.inst.cfg`
- `quality_changes/anycubic_kobra_max_kobra-base.inst.cfg` (+ extruder pair)
- `quality_changes/anycubic_kobra_max_kobra-asa.inst.cfg` (+ extruder pair)

---

## Machine profile → `configs/machine/kobra-max-klipper.json`

### Build volume

| Cura key | Value | OrcaSlicer field |
|---|---|---|
| `machine_width` | 402.0 mm | Printable area X |
| `machine_depth` | 425.0 mm | Printable area Y |
| `machine_height` | 395.0 mm | Max print height |
| `extruders_enabled_count` | 1 | Single extruder |

Head clearance polygon (rare to need in Orca): `[[-20, 10], [-20, 10], [10, -10], [-20, -10]]`

### Start gcode (Klipper, Mainsail/Fluidd frontend)

```gcode
;Nozzle diameter = {machine_nozzle_size}
;Filament type = {material_type}
;Filament name = {material_name}
;Filament weight = {filament_weight}

M220 S100 ;Reset Feedrate
M221 S100 ;Reset Flowrate

M140 S{material_bed_temperature_layer_0} ; Start heating the bed (without waiting)
M104 S{material_print_temperature_layer_0} ; Start heating the hotend (without waiting)

G28 ;Home
G92 E0 ;Reset Extruder
CLEAR_PAUSE;

;M420 S1 ; turn on bed mesh leveling
BED_MESH_PROFILE LOAD=default

G0 X5 Y5 Z0.28 F5000.0 ;Move to start position

M190 S{material_bed_temperature_layer_0} ; Wait for the bed to reach temperature
M109 S{material_print_temperature_layer_0} ; Wait for the hotend to reach temperature

G1 X5 Y300.0 Z0.28 F1500.0 E15 ;Draw the first line
G1 X5.4 Y300.0 Z0.28 ;Move to side a little
G1 X5.4 Y5 Z0.34 E30 ;Draw the second line
G1 E29 ;retract
G0 Z4.0 ;Move Z Axis up

G92 E0  ;Reset Extruder
G90 ; Use absolute positioning
```

**Port notes for OrcaSlicer:**
- Cura placeholders `{material_print_temperature_layer_0}` become Orca's `[nozzle_temperature_initial_layer]` style.
- Specifically:
  - `{material_bed_temperature_layer_0}` → `[bed_temperature_initial_layer_single]` (or `[hot_plate_temp_initial_layer]` depending on Orca version)
  - `{material_print_temperature_layer_0}` → `[nozzle_temperature_initial_layer]`
  - `{machine_nozzle_size}` → `[nozzle_diameter]`
  - `{material_type}` → `[filament_type]`
- **Consider refactoring** to call a Klipper `PRINT_START` macro instead of inlining heat/home/prime — cleaner separation and lets you tweak the start sequence in `printer.cfg` without re-slicing. Example:
  ```
  PRINT_START EXTRUDER=[nozzle_temperature_initial_layer] BED=[bed_temperature_initial_layer_single]
  ```

### End gcode

```gcode
G91 ;Relative positioning
G0 E-1 Z0.2 F2400 ;Retract and raise Z
G0 X5 Y5 F3000 ;Wipe out
G0 Z5 ;Raise Z more

G90 ;Absolute positioning
G0 X0 Y{machine_depth} ;pull back
_CLIENT_LINEAR_MOVE E=-10 F=180; retract
M106 S0 ;Turn-off fan
M104 S0 ;Turn-off hotend
M140 S0 ;Turn-off bed

M84
```

Note: `_CLIENT_LINEAR_MOVE` is a Mainsail/Fluidd client-macros macro, not stock Klipper — confirm it's still defined in your `printer.cfg`. `{machine_depth}` → `[printable_height]` is wrong; in Orca this would be a hardcoded `425` or `[bed_size_y]` depending on version.

---

## Filament profiles

You have two effective material profiles encoded as Cura "quality changes" — port them as OrcaSlicer **filament** profiles (not process):

### `configs/filament/pla-kobra-base.json` (from `kobra-base`)

| Setting | Value |
|---|---|
| Material type | PLA |
| Nozzle temp (print) | 210 °C |
| Nozzle temp (initial layer) | 210 °C |
| Nozzle temp (final) | 210 °C |
| Bed temp | 55 °C |
| Bed temp (initial layer) | 55 °C |
| Flow ratio | 1.00 (100%) |
| Flow ratio (initial layer) | 1.03 (103%) — note: extruder overrides set this to 102%, base profile says 103% |
| Skin flow (initial layer) | 1.05 (105%) |
| Retraction length | 0.5 mm |
| Retraction speed | 25 mm/s |
| Z hop | 0.4 mm |
| Z hop only when collides | False |

### `configs/filament/asa-kobra.json` (from `kobra-asa`)

| Setting | Value |
|---|---|
| Material type | ASA |
| Nozzle temp (print) | 255 °C |
| Nozzle temp (initial layer) | 255 °C |
| Nozzle temp (final) | 250 °C |
| Bed temp | 75 °C |
| Bed temp (initial layer) | 75 °C |
| Part cooling fan | **Disabled** |
| Fan full at height | 0.4 mm |
| Min fan speed | 15% |
| Flow ratio | 1.00 |
| Flow ratio (initial layer) | 1.05 |
| Retraction length | 0.8 mm |
| XY shrinkage compensation | 100.6% (compensates for ASA cooling shrinkage) |

---

## Process profiles

### `configs/process/0.2mm-kobra-base.json` (from `kobra-base`)

| Category | Setting | Value |
|---|---|---|
| **Speed** | Print speed | 80 mm/s |
| | Initial layer speed | 30 mm/s |
| | Outer wall | 40 mm/s (= print/2) |
| | Inner wall | 80 mm/s |
| | Top/bottom | 40 mm/s (= print/2) |
| | Travel | 120 mm/s |
| | Initial layer travel | 120 mm/s |
| | Ironing | 25 mm/s |
| | Skirt/brim | 35 mm/s |
| **Acceleration** | Print | 300 mm/s² |
| | Travel | 500 mm/s² |
| | Jerk control | Disabled (Cura jerk_enabled=False) |
| **Walls** | Wall thickness | 1.2 mm (3 perimeters at 0.4 nozzle) |
| **Top/bottom** | Thickness | 0.6 mm |
| | Roofing layers | 1 |
| | Monotonic skin | True |
| | Ironing | **Enabled** |
| **Infill** | Pattern | quarter_cubic |
| | Density | 20% |
| | Zig-zaggify | True |
| **Adhesion** | Type | Skirt |
| | Skirt lines | 2 |
| | Brim lines (when used) | 10 |
| **Cooling** | Fan full at height | 0.6 mm |
| | Fan full at layer | 4 |
| | Min fan speed | 35% |
| | Slow layers (min layer time max fan) | 10 s |
| **Supports** | Enabled | False (toggle per-print) |
| | Pattern | Normal, buildplate-only |
| | Angle threshold | 60° |
| | Tree angle | 70° |
| | Infill density | 10% |
| | Wall count | 2 |
| | Z distance | 0.28 mm |
| | Towers | Off |
| **Other** | XY offset (initial layer) | -0.05 mm (elephant's foot comp) |
| | Z seam | Sharpest corner |
| | Combing | Off |
| | Speed slowdown layers | 1 |

### `configs/process/asa-kobra.json` deltas (from `kobra-asa`, vs base above)

- Print speed: **50 mm/s** (slower)
- Initial layer: **20 mm/s**
- Outer wall: 25 mm/s (print/2)
- Inner wall: 50 mm/s (wall * 2)
- Infill pattern: **gyroid**
- Combing: **infill**
- Supports: **enabled** by default, buildplate-only
- Wall thickness: 0.8 mm (or wall_line_width_0 when spiralizing)
- Speed equalize flow width factor: 0 (off)

---

## Active user overrides (current Cura session state)

These are session-level toggles, not profile-level. Treat as defaults you typically apply, not part of any committed profile:

- `adhesion_type = skirt`
- `material_bed_temperature = 50` (likely the filament currently loaded; profile defaults override)
- `support_enable = False`
- Extruder `ironing_enabled = False` (overrides the base profile's `ironing_enabled = True` — you've turned off ironing for whatever's currently in the printer)
- Extruder `material_flow_layer_0 = 102` (102% first-layer flow override on top of profile's 103%)

---

## Things NOT in Cura that you'll need to set in OrcaSlicer

- **Max accel / velocity / jerk limits per axis** — Cura uses single values; OrcaSlicer wants per-axis. Pull these from your Klipper `printer.cfg` (`[printer] max_velocity`, `max_accel`, `max_z_velocity`, `max_z_accel`).
- **Pressure advance** — Klipper handles this firmware-side; leave Orca's pressure advance feature off, or set the value to match your `SET_PRESSURE_ADVANCE` calibration.
- **Input shaper** — same: handled in Klipper, disable in Orca.
- **Nozzle diameter** — not explicit in extracted files (Cura inherits from base definition). Confirm and set explicitly in Orca's machine profile (likely 0.4 mm based on speed/wall settings, but verify against the physical nozzle).
- **Filament diameter** — `generic_pla_175` is referenced, so 1.75 mm.
