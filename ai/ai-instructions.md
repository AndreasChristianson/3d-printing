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

Functional parts that have room for it carry an embossed provenance tag: the repo, the
`.scad`'s path in the repo, and the git SHA + commit date it was rendered from. That
way a part found years later can be traced back to its pattern.

- `include <../lib/provenance.scad>` and place `provenance()` on a flat face that isn't
  cosmetic (inside or back), as a raised tag on a surface that prints facing up.
- Don't engrave the text straight into a face; small engraved text came out
  unreadable (glowbox rails, 2026-11). Where the face must stay flush (it slides or
  mates), cut a shallow pocket and raise the text from its floor, keeping the text top
  ~0.2 mm below the face (see `rail()` in `scad/glowbox-drive-bay/drive_bay.scad`).
- Render with `scad/render.sh path/to/part.scad [out.stl]`, which fills in the path,
  SHA and date. **Commit before rendering** for print: uncommitted changes get a
  `-dirty` SHA, and a plain `openscad -o` render shows the placeholder `nosha`.
- Skip it on small parts and on decorative or cosmetic ones.
