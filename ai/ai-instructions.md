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
| Ender 3 v3 SE | OctoPrint | `octopi3` | `http://octopi3/` | `~/.octoprint` | `printer/ender-3-v3-se/` |
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
