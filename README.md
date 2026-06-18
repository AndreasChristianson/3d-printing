# 3d-printing

Git-tracked OrcaSlicer configs and a CLI slicing pipeline for a modded Anycubic Kobra Max running Klipper (reachable at `http://klipper2/`).

## Layout

```
configs/
  machine/    # printer definitions (bed size, kinematics, start/end gcode for Klipper)
  filament/   # per-material profiles (temps, flow, retraction)
  process/    # per-print profiles (layer height, infill, supports, speed)
models/       # STL / 3MF inputs (commit small ones; consider git-lfs for large)
output/       # generated gcode — gitignored
slice.sh      # wrapper: slice with OrcaSlicer CLI, optionally upload to Moonraker
```

## Quick start

```bash
./slice.sh models/foo.stl              # slice only
./slice.sh models/foo.stl --upload     # slice and POST gcode to Moonraker
```

Override default profiles per-invocation:

```bash
MACHINE=kobra-max-klipper.json \
FILAMENT=petg-overture.json \
PROCESS=0.3mm-draft.json \
  ./slice.sh models/foo.stl
```

## Installing OrcaSlicer (macOS)

OrcaSlicer ships as a regular `.app`; the same bundle contains the CLI binary `slice.sh` calls.

**Option A — Homebrew (recommended):**

```bash
brew install --cask orcaslicer
```

**Option B — direct download:**

1. Grab the latest macOS DMG from <https://github.com/SoftFever/OrcaSlicer/releases>.
2. Open the DMG and drag `OrcaSlicer.app` to `/Applications`.
3. First launch: right-click → Open (Gatekeeper will block a plain double-click on unsigned builds).

**Verify the CLI works:**

```bash
/Applications/OrcaSlicer.app/Contents/MacOS/OrcaSlicer --help | head
```

If your install lives elsewhere, set `ORCA_BIN` in your shell or before running `slice.sh`:

```bash
export ORCA_BIN=/path/to/OrcaSlicer
```

## Porting from Cura

If you're migrating from Cura, see [`docs/cura-extracted.md`](docs/cura-extracted.md) — it has all the relevant Kobra Max settings pulled from your Cura 5.12 install, structured for hand-porting into OrcaSlicer's GUI.

## Syncing profiles from the GUI

OrcaSlicer auto-saves user profiles to disk as you edit in the GUI — no manual export step needed. They live at:

```
~/Library/Application Support/OrcaSlicer/user/default/{machine,filament,process}/*.json
```

`sync-from-orca.sh` copies them into `configs/` for git tracking:

```bash
./sync-from-orca.sh             # copy + show changed-files stat
./sync-from-orca.sh --quiet     # copy only
```

Workflow: tweak in the GUI → `./sync-from-orca.sh` → `git diff configs/` to review → commit.

## Klipper notes

- Start/end gcode should call Klipper macros (`PRINT_START EXTRUDER=[nozzle_temperature_initial_layer] BED=[bed_temperature_initial_layer]` style), not raw Marlin `M104`/`G28` sequences.
- The Kobra Max bed is large (~400×400mm) — confirm exact usable area against your modded setup before locking the machine profile.
- Moonraker upload endpoint used by `--upload`: `POST http://klipper2/server/files/upload` with multipart `file=@...`.

## Why no Docker?

Considered and skipped — single user, single machine, macOS host where Docker Desktop adds VM overhead and pathing friction. The git-tracked configs are the real artifact; pinning the slicer version isn't worth the maintenance cost yet. Easy to add later if we ever want CI-driven config-diff reviews.
