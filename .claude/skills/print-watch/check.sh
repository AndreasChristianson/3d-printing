#!/usr/bin/env bash
# One print-watch tick: grab a webcam snapshot + printer status from Moonraker.
# Prints one status line (also appended to <dir>/log.txt) and the snapshot path.
#
# Usage: check.sh <watch-dir> [printer-host]
set -uo pipefail

D="${1:?usage: check.sh <watch-dir> [printer-host]}"
HOST="${2:-klipper2}"
mkdir -p "$D"

ts=$(date +%H%M%S)_$RANDOM
curl -s --max-time 10 -o "$D/snap_$ts.jpg" "http://$HOST/webcam/snapshot"
curl -s --max-time 5 "http://$HOST/printer/objects/query?print_stats=state,print_duration,filename&display_status=progress&toolhead=position&extruder=temperature,target&heater_bed=temperature,target&gcode_move=homing_origin" \
  | python3 -c '
import sys, json, time
s = json.load(sys.stdin)["result"]["status"]
ps, th = s["print_stats"], s["toolhead"]["position"]
print(time.strftime("%H:%M:%S"), ps["state"],
      "%.0f%%" % (s["display_status"]["progress"] * 100),
      "pos X%.1f Y%.1f Z%.2f" % tuple(th[:3]),
      "hotend %.0f/%.0f" % (s["extruder"]["temperature"], s["extruder"]["target"]),
      "bed %.0f/%.0f" % (s["heater_bed"]["temperature"], s["heater_bed"]["target"]),
      "zoff %.3f" % s["gcode_move"]["homing_origin"][2])
' | tee -a "$D/log.txt"
echo "$D/snap_$ts.jpg"
