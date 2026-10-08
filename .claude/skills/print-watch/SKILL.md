---
name: print-watch
description: Watch a running Klipper print unattended. Every ~5 minutes, take a webcam snapshot plus Moonraker status, and pause the print on clear failure (part detached, blob on the nozzle, spaghetti, stalled Z, temperatures off). Use when the user wants to leave a print running ("watch the print", "pause it if something goes wrong", "I'm going to bed").
---

# Print watch

Monitor a print on the Kobra Max (`klipper2`, Moonraker at `http://klipper2/`) while the user is away. Pause on clear failure. Never cancel or resume.

## Setup (do all of this while the user is still present)

1. **Make sure the ticks can run unattended.** Every tool call a tick makes must run without a permission prompt. Otherwise the first tick stalls and nothing watches the print (this happened on 2026-10-08, and the print failed overnight). Ask the user to switch to auto mode, or have them allowlist these:
   - `Bash(.claude/skills/print-watch/check.sh:*)`
   - `Bash(curl -s -X POST http://klipper2/printer/print/pause)`
   - `Read` on the watch dir
   - `CronList` / `CronDelete`
   - `Bash(pkill -x caffeinate)`
2. **Pick a watch dir** in the session scratchpad, e.g. `<scratchpad>/printwatch`. Clear old snapshots and append `--- new watch <date>` to `log.txt`.
3. **Run one tick now**: `.claude/skills/print-watch/check.sh <dir>`, then Read the snapshot. This proves the tick works without prompts and gives a baseline (state, Z, temperatures, gcode Z offset, what the camera shows).
4. **Keep the Mac awake**: `caffeinate -i -t <seconds>` with `run_in_background`. Size it to the remaining print time plus margin (estimate from progress and elapsed time). `-i` lets the display sleep, which is fine. Closing the lid or a manual sleep still stops everything.
5. **Schedule the ticks** with `CronCreate` `*/5 * * * *`. Use the tick prompt below, with the watch dir and any print-specific notes filled in, such as the gcode Z offset/babystep in effect.
6. Tell the user what will happen: pause only, no cancel or resume, `PAUSE` parks the toolhead and the hotend turns off after a 10 min idle timeout, and the watch stops itself when the print ends. State the limits too: the session and Mac must stay up, there can be up to 5 min of lag, and the edge-on camera may miss early corner lift.

## Tick prompt (pass to CronCreate)

```
Print watch (user is away; act autonomously, keep output short).

1. Run .claude/skills/print-watch/check.sh <DIR> — it prints one status line and a
   snapshot path. Read the snapshot. Compare with recent lines in <DIR>/log.txt.

2. If state is not "printing" (complete, cancelled, error, paused): touch nothing.
   Append the final state to log.txt, stop the watch (CronList → CronDelete this job,
   pkill -x caffeinate), report the outcome in 1–2 lines. <PRINT-SPECIFIC END NOTES>

3. If printing, judge per the print-watch skill's "Judging a frame". PAUSE only on clear
   evidence of failure. If unclear (blur, occlusion), run check.sh 2 more times right
   away and decide from all three frames.

4. To pause: curl -s -X POST http://klipper2/printer/print/pause, verify via check.sh
   that state is "paused", append "PAUSED: <reason> <snapshot>" to log.txt, stop the
   watch as in 2. Do NOT cancel, resume, or send any other G-code. Explain what you
   saw in one short paragraph.

5. If fine, reply with the status line and "ok". Delete snapshots older than 2 hours,
   keeping any referenced by a PAUSED line.
```

## Judging a frame

The camera rides with the gantry and looks edge-on at the nozzle area, so the view moves with the toolhead.

**Normal (don't pause):**
- Translucent Stealthburner with a green status LED, a white nozzle light, and a **red LED reflection** on the bed. That red sometimes lights the top of a post or wall red; it is not plastic.
- The part out of frame or hidden behind the toolhead, especially when Y is near the part's front edge.
- **Motion blur** when the bed is moving fast. Take two more frames before deciding anything.
- **Z jitter** between ticks: a reading can catch a Z-hop (e.g. 1.14 → 0.94 → 1.17). Judge Z by the trend across several lines, together with rising progress %.
- Slow Z rise during the solid bottom layers; it speeds up after them.

**Pause on:**
- Plastic wrapping or blobbing around the nozzle or heater block (the start of a blob of death).
- The part detached, shifted, tilted, lifted, or being carried or dragged by the nozzle.
- Spaghetti or loose strands piling up.
- Z flat across several ticks while progress keeps rising, or temperatures far off target.

## After the print

- Remind the user of any active babystep (`zoff` in the status line). If the first layer looked good, save it with `Z_OFFSET_APPLY_PROBE` then `SAVE_CONFIG`, **only after the print**, because `SAVE_CONFIG` restarts Klipper.
- The `caffeinate` task reports "failed, exit 143" when `pkill` stops it. That's expected.
