# 3d-printing

Git-tracked OrcaSlicer configs for a modded Anycubic Kobra Max running Klipper (reachable at `http://klipper2/`). Slicing happens in the OrcaSlicer GUI; this repo tracks the settings so changes are reviewable.

## Layout

```
configs/
  machine/    # printer definitions (bed size, kinematics, start/end gcode for Klipper)
  filament/   # per-material profiles (temps, flow, retraction)
  process/    # per-print profiles (layer height, infill, supports, speed)
models/       # STL / 3MF inputs (commit small ones; consider git-lfs for large)
docs/         # reference notes (e.g., Cura-extracted settings)
sync-from-orca.sh  # copy GUI-saved profiles into configs/ for git review
```

## Workflow

1. Tune profiles in OrcaSlicer's GUI as you iterate on prints.
2. Run `./sync-from-orca.sh` to copy the current profiles from OrcaSlicer's app-support dir into `configs/`.
3. `git diff configs/` to review, then commit.
4. Slice and send to the printer from inside OrcaSlicer (it knows about `klipper2` via the printer profile's `print_host`).

## Installing OrcaSlicer (macOS)

**Option A — Homebrew (recommended):**

```bash
brew install --cask orcaslicer
```

**Option B — direct download:**

1. Grab the latest macOS DMG from <https://github.com/SoftFever/OrcaSlicer/releases>.
2. Open the DMG and drag `OrcaSlicer.app` to `/Applications`.
3. First launch: right-click → Open (Gatekeeper will block a plain double-click on unsigned builds).

## Porting from Cura

If you're migrating from Cura, see [`docs/cura-extracted.md`](docs/cura-extracted.md) — it has the relevant Kobra Max settings pulled from a Cura 5.12 install, structured for hand-porting into OrcaSlicer's GUI.

## Klipper notes

- Start/end gcode should call Klipper macros (`PRINT_START EXTRUDER=[nozzle_temperature_initial_layer] BED=[bed_temperature_initial_layer]` style) where practical, not raw Marlin `M104`/`G28` sequences.
- The Kobra Max bed is large — the current machine profile uses 402×425mm. Confirm against your physical setup before locking.

## Why no CLI slicing?

The original plan was a `slice.sh` wrapper around OrcaSlicer's CLI for git-driven slicing. OrcaSlicer's `--load-settings` flag turned out to need fully-flattened "exported" preset JSONs, but the JSONs OrcaSlicer auto-saves in its user dir are sparse deltas (`from: "User"`, `inherits: "<system preset>"`, only changed fields). The CLI loader doesn't follow that inheritance chain the way the GUI does — so the deltas fail with `process not compatible with printer` even when the same combo works fine in the GUI. Workarounds (manually exporting flattened presets, or maintaining a 3MF project template) added more friction than they saved, so we slice in the GUI and use this repo to track the settings.
