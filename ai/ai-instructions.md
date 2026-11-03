# AI agent instructions — 3d-printing repo

Guidance for any AI coding agent or assistant working in this repo, independent of
model or harness. Git-tracked configs for a small 3D-printer fleet: OrcaSlicer slicer
profiles plus on-machine host/firmware configs. See `README.md` for the human-facing
overview.

## Printers & how to connect

SSH uses **key-based auth**. The login user is provided out-of-band — via your SSH
config or the `PRINTER_SSH_USER` env var — and is intentionally **not** stored in this
repo. Prefer non-interactive SSH: `ssh -o BatchMode=yes <host> '<cmd>'`.

| Printer | Host software | Host | Web UI | Remote config dir | Repo dir |
|---------|---------------|------|--------|-------------------|----------|
| Kobra Max (modded) | Klipper | `klipper2` | `http://klipper2/` (Mainsail) | `~/printer_data/config` | `printer/kobra-max/` |
| Ender 3 v3 SE (given away 2026-10; configs kept for reference) | OctoPrint | — | — | — | `printer/ender-3-v3-se/` |
| Voron 2.4 (300) | Klipper (planned) | — not built yet — | — | — | — |

The Kobra Max runs a Stealthburner toolhead with a Galileo 2 extruder (see
`printer/kobra-max/printer.cfg`).

## Repo layout

- `slicer/` — OrcaSlicer host-side profiles (`machine/`, `filament/`, `process/`).
  Synced from the GUI via `sync-from-orca.sh`.
- `printer/<machine>/` — on-machine host/firmware configs, one dir per printer.
  Pulled from the pi over SSH.
- Keep these two separate; do not reintroduce a shared `configs/` dir.

## Secrets — important

Printer configs can contain credentials. When importing:

- **Redact** secret *values* in tracked files, replacing with `REDACTED` (the real
  values stay only on the pi). Known secrets: OctoPrint `config.yaml` → `api.key` and
  `server.secretKey`.
- **Never commit** credential-only files: `users.yaml` (API key + password hash) and
  `config.backup`. These are git-ignored (`printer/**/users.yaml`, `printer/**/config.backup`).
- **Never pull** runtime/data dirs (uploads, logs, gcodes, timelapse, `.git`, dated
  `printer-*.cfg` auto-save backups).
- After importing, scan the `printer/` tree for unredacted secrets before committing.

## SCAD parts: provenance tags

Functional parts that have room for it carry a provenance tag: the `.scad` file name and
the git SHA it was rendered from, plus the repo path and the repo when there's room. That
way a part found years later can be traced back to its pattern.

- `include <../lib/provenance.scad>` and wrap the part:
  `with_provenance() { part(); translate(...) provenance(w = ..., h = ...); }`.
  `provenance()` fits the text to the w × h area and **stops the render** if file + SHA
  can't reach `prov_min_stroke` (0.9 mm, about 2 extrusion lines). Text with thinner
  strokes prints as one wiggly bead (glowbox v0/v1 tags, 2026-11).
- Prefer `inlay`: flush in a flat face that prints down on the bed. The first layers
  give the crispest text, and a flush tag can go on a face that slides or mates (see
  `rail()` in `scad/glowbox-drive-bay/drive_bay.scad`). `emboss` (the lib default) is
  raised on a face that prints facing up. Where that face must stay flush, raise the
  text from a shallow pocket floor, keeping its top ~0.2 mm below the face.
- The tag is a separate part for a second filament. Load both STLs in Orca as one
  multi-part object, and give them the same filament to skip the swaps.
- Font: `prov_font`, monospace, default JetBrains Mono ExtraBold. A new font needs a row
  in `prov_fonts`; measure it with `scad/lib/font_metrics.sh`. The SHA is always caps;
  the rest goes caps when the stroke is under `prov_upper_below` (`prov_upper`).
- Render with `scad/render.sh path/to/part.scad [out.stl]`. It fills in the path and SHA
  and writes `out.stl` plus `out.tag.stl`. **Commit before rendering** for print:
  uncommitted changes get a `+` on the SHA, and a plain `openscad -o` render shows the
  placeholder `NOSHA`.
