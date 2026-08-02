# Upgrade & New-Build Plan — "Menu of Options"

Purpose: put together a **menu of options with prices** to bring to the family for approval.
The spend needs buy-in, so this doc frames the vision, the end state, and — importantly —
the **stable waypoints** along the way (points where money has been spent but every printer is
fully usable, so we can pause indefinitely without a half-finished machine on the bench).

Companion to the Google Sheet that collects links + prices. This doc holds the reasoning and
structure; the Sheet holds the live line-item pricing. _(Sheet URL: TBD — paste here.)_

## Motivation
**Fun.** The driver is the enjoyment of building and tweaking, not a production need.
Getting the Kobra Max running (rescued in pieces from a friend's basement) was a blast, and
building a **Voron** is a "for my own pleasure" project. Cost discipline still matters because
the family is approving the budget — hence the menu + waypoints framing.

## Two candidate routes (different end states!)

There are two strategies on the table, and they **end in different fleets**. The core question
is: **do we keep large-format printing, or trade it away to fund the Voron?**

| | **Route A** — build Voron fresh | **Route B** — Franken-Voron transplant |
|---|---|---|
| Approach | Keep + specialize the Kobra; build a Voron from scratch alongside | Progressively bolt Voron parts onto the Kobra as a testbed, then transplant them into a real Voron frame |
| Ender 3 | Retired / rehomed | **Kept** (maintenance only) — stays son's |
| Kobra | Kept as large-format single-material workhorse | Gutted for parts, then **sold off** |
| End fleet | Kobra (big, single-mat) + Voron (small, MM) | Voron (mine, MM) + Ender (son's) |
| Keeps large format? | **Yes** | **No** (lose ~400mm capability) |
| Cash flow | Two parallel spends | Spread out; every purchase runs on the Kobra first |
| Fun factor | New scratch build | Max tinkering (adapters, belt-path hacks) + a build |
| Big risk | Two machines to maintain; more total $ | Custom mounting/electronics work; Voron rail lengths ≠ Kobra's |

### Route A end state — a specialized two-printer fleet
| Printer | Role | Format | Nozzle | Materials |
|---------|------|--------|--------|-----------|
| **Kobra Max** (upgraded, +rails) | Big, fast-turnaround workhorse | Large format (~400×425) | **Large** (0.6 / 0.8 mm) | **Single material** |
| **Voron 2.4 R2 300** (new build) | Precision / everyday | 300×300×300 | **0.4 mm** | **Multi-material (BoxTurtle)** |
| ~~Ender 3 V3 SE~~ | **Retired / rehomed** | — | — | — |

### Route B end state
| Printer | Role | Format | Nozzle | Materials |
|---------|------|--------|--------|-----------|
| **Voron 2.4 R2 300** (mine) | Everyday / precision | 300×300×300 | 0.4 mm | Multi-material (BoxTurtle) |
| **Ender 3 V3 SE** (son's) | His printer | 220 | 0.4 mm | Single material |
| ~~Kobra Max~~ | **Sold** (after parts transplant) | — | — | — |

## Guiding principle — stable waypoints
Every phase should **end at a usable state**. We never want to be mid-teardown with nothing
printable. Each waypoint below is a place we can stop, live with the setup for months, and
still print, so the family sees value banked at each step rather than an all-or-nothing spend.

### Other routes / ideas on the menu
Beyond A and B, options worth pricing so the family has a real menu:

- **Route C — "Small Voron first" (toe in the water).** Build a cheap **Voron 0.2 / Micron** (~$300–500) as the first Voron: scratches the build itch, low approval risk, fast win. Keep the Kobra as-is for big prints; defer the big multi-material decision. Downside: V0 is tiny — a stepping stone, not the everyday MM workhorse. Could precede A or B.
- **Route D — Pragmatic MM + fun build (split the goals).** Buy a cheap reliable multi-material commercial printer (Bambu P1S+AMS class) to own the MM workhorse role *now*, and build the Voron purely for pleasure with no daily-driver pressure. De-risks a long build; gives the family a visibly practical option (makes the fun-Voron easier to approve as the premium). Downside: another box; not a build.
- **Route E — Modularize for approval (financing tactic, not hardware).** Present the spend as independently-approvable chunks tied to waypoints ("rails for the Kobra now, $X, better prints" → yes → "Voron frame+motion, $Y" → …). Small yeses beat one big ask. Pairs with any route.

- **Route F — Kobra prints the Voron, then Kobra goes to son (no Kobra upgrades).** ⭐ strong contender.
  - Use the **Kobra as-is** to print Voron parts in **PETG** (open-frame friendly — no enclosure needed).
  - Build a **250 or 300** Voron; slowly buy parts.
  - Once running, the **Voron reprints its own parts in ABS/ASA** (it's enclosed) — or skip that via **Print-It-Forward** (community prints you ABS parts for cost). Or just leave PETG parts if we only run cool-chamber materials. ⚠️ PETG parts can creep in a hot ABS chamber — fine for PLA/PETG use, reprint in ABS if we push chamber temps.
  - **End state:** Voron (mine, multi-material) + **Kobra handed to son** (mostly stock, large but slow, "works fine for him"); **Ender retired/rehomed**.
  - vs Route A: same fresh Voron build, but instead of spending to upgrade + keep the Kobra for myself, the **un-upgraded Kobra goes to son** (he gets a big upgrade over the Ender) and we spend **$0 on Kobra upgrades**. Large format stays in the household (son's), just not mine and still slow.
  - vs Route B: Kobra stays in the family instead of being sold/gutted; no custom transplant work.

  | Printer | Role | Notes |
  |---------|------|-------|
  | **Voron 2.4 (250/300)** (mine) | Everyday + multi-material | Parts printed in PETG on Kobra, later ABS |
  | **Kobra Max** (son's) | Large format, slow, mostly stock | Free hand-me-down; POM-wheel artifacts remain |
  | ~~Ender 3 V3 SE~~ | Retired / rehomed | |

## Is Voron the right DIY base? (platform comparison)

Sanity-check against tunnel vision. For a **fun, hackable, multi-material** DIY CoreXY, the field:

| Platform | DIY style | Sizes | Multi-material | Community / docs | Fit for us |
|----------|-----------|-------|----------------|------------------|------------|
| **Voron 2.4 / Trident** | Full DIY, self-source or kit, **you print the parts** | 250/300/350 | BoxTurtle, ERCF (native ecosystem) | Largest, best docs, most mods | **Best fit** for fun + mods + self-source decision already made |
| **RatRig V-Core 4** (or 3.1) | **Kit** — you assemble, they supply everything incl. parts | 300/400/**500** | ERCF/BoxTurtle-compatible + their ecosystem | Solid, smaller than Voron | **Strong alt** — a big V-Core could unify large-format **and** multi-material in one build (see note) |
| Prusa Core One | Kit or assembled; appliance-ish | ~250 | MMU-adapted | Good but less hackable | Leans "reliable" (overlaps Route D), less tinker |
| VzBot / Annex (K3, etc.) | Expert DIY, niche sourcing | varies | DIY | Small, expert | Only if we want an esoteric build |
| Voron clones (Troodon, Formbot kit) | Semi-assembled Voron-likes | 250–350 | ERCF/BoxTurtle | Rides Voron docs | Middle ground: less sourcing, less "scratch" |

**Key insight — RatRig could collapse the fleet:** every current route treats *large format* and
*multi-material* as **two separate machines**. A single **RatRig V-Core 4 in 400/500** could be
BOTH — a big, enclosed, multi-material CoreXY — letting us retire the Kobra *and* skip a second
machine. Trade-offs: it's a **kit (more $, less sourcing fun, fewer parts to print)**, community is
smaller than Voron's, and a 500mm CoreXY is a lot of machine to tune. But if "one great printer that
does everything" appeals more than "a specialized fleet," this is the option that delivers it.
_(Open question added below.)_

## Route A — roadmap (costs TBD from the Sheet)

### Phase 0 — Stabilize what we have (mostly done / cheap)
Keep both current printers healthy; small maintenance spend.
- [x] Y idlers/tensioners replaced (done)
- [ ] X idler swap (part on order)
- [ ] Re-adhere/replace Kobra PEI magnetic base
- [ ] Secure PTFE couplings (dry box / EIBOS → extruder)
- [ ] OctoPrint update + storage cleanup (Ender)
- **Waypoint 0:** both printers reliable, single-material, as-is. _Est: $_

### Phase 1 — Kobra → large-format / large-nozzle workhorse
Commit the Kobra to its end-state role.
- [ ] Large nozzle(s) — 0.6 / 0.8 mm hardened _(has some hardened nozzles already)_
- [ ] Tune high-flow single-material profiles in Orca (large layer heights)
- [ ] (Optional) hotend flow upgrade if the Micro Swiss all-metal limits volumetric rate
- [ ] (Optional) input shaping — add an ADXL345/accelerometer (none present today)
- **Waypoint 1:** Kobra is the "big + coarse + fast" machine. Ender still covers 0.4 mm. _Est: $_

### Phase 2 — Build the Voron 2.4 R2 300 (0.4 mm, multi-material)
The main project. Model/size/sourcing/MMU now decided (see Decisions log).
- [ ] Print all Voron parts (on Ender + Kobra) — do this **before** Ender retirement
- [ ] Source the BOM (frame extrusion, motion, electronics, hotend, bed) per official 2.4 R2 BOM
- [ ] Build + wire + commission (Klipper) single-material first
- [ ] Add BoxTurtle (AFC) once the base machine is dialed in
- **Waypoint 2a:** Voron running **single-material** 0.4 mm (BoxTurtle deferred). Ender can retire here.
- **Waypoint 2b:** Voron + **BoxTurtle** multi-material running.
- _Est: $ (2.4 BOM) + $ (BoxTurtle) + $ (printed-parts filament)_

### Phase 3 — Retire the Ender 3
Once the Voron covers the 0.4 mm role.
- [ ] Sell / gift / hand fully to son
- **Waypoint 3:** final two-printer fleet as designed. _Est: net $ (may recoup some)_

## Route B — Franken-Voron transplant (roadmap)

Progressively rebuild the Kobra with genuine Voron parts (limited to a smaller print area),
so each expensive part is bought once and immediately used. Then build a Voron *frame* around
those parts and sell what's left of the Kobra. Every phase leaves a **working, better** Kobra.

### Phase B0 — Rails first (fixes today's artifacts)
- [ ] MGN12H linear rails on X and Y (genuine HIWIN, robotdigg #671) — sized **smaller than max**, cap travel in firmware
- [ ] Rework X belt path (the hard mechanical bit) + printed rail-to-Kobra adapters (fun CAD)
- **Waypoint B0:** Kobra prints noticeably cleaner (POM-wheel artifacts gone). Nothing else changed. _Est: $ rails + hardware_

### Phase B1 — Stealthburner toolhead
- [ ] Build a **Stealthburner** + Clockwork2 extruder; mount on the Kobra X carriage (printed adapter)
- [ ] CAN toolhead board (brings wiring sanity; also a future Voron part) — SKR Mini E3 likely can't feed SB + BoxTurtle, so this is where electronics start migrating
- **Waypoint B1:** Kobra runs the Voron toolhead. _Est: $ SB parts + toolhead board_

### Phase B2 — BoxTurtle multi-material
- [ ] Assemble + wire **BoxTurtle** (AFC) alongside the Kobra
- **Waypoint B2:** Kobra is now **multi-material** (limited area). _Est: $ BoxTurtle_

### Phase B3 — Voron bed + build plate
- [ ] Buy a **300 Voron bed** + PEI build plate; mount on the Kobra (adapter, kinematic mounts)
- [ ] Sort heater voltage/PSU (⚠️ AC bed = mains + SSR + safety; DC bed = big PSU) — see open item
- **Waypoint B3:** Kobra hosts nearly all the Voron's expensive parts, limited to ~300×300. _Est: $ bed + plate_

### Phase B4 — Build the Voron frame + transplant
- [ ] Buy the *remaining* Voron-specific parts: **frame extrusion, A/B + Z motors, enclosure panels, remaining rails (Z + any axis-specific), belts**
- [ ] Assemble frame, **transplant** Stealthburner, BoxTurtle, electronics, bed/plate, rails that fit
- [ ] Commission the real Voron 2.4 R2 300
- **Waypoint B4:** Voron running; Kobra reduced to frame + leftovers. _Est: $ frame/motors/enclosure/rails/belts_

### Phase B5 — Sell the Kobra remains
- [ ] Sell frame, gantry, SKR Mini E3, PSU, stock bits — recoup toward the build
- **Waypoint B5:** final fleet = Voron (mine) + Ender (son's). _Est: net recoup +$_

### Route B — parts: transplant vs. buy-for-Voron vs. sell-with-Kobra
| Transplants to the Voron | Bought new at Phase B4 | Sold with Kobra remains |
|--------------------------|------------------------|-------------------------|
| Stealthburner + Clockwork2 | Frame extrusion (2020/2040) | Kobra frame / gantry |
| BoxTurtle (AFC) | A/B motors + 4× Z motors | SKR Mini E3 v3.0 |
| Main + CAN toolhead electronics | Enclosure panels | Kobra PSU (unless reused) |
| 300 Voron bed + PEI plate | Z rails + any axis-specific rails | Stock Kobra bed |
| X/Y rails (**if** lengths match Voron 300) | Belts, pulleys | POM wheels, misc stock |
| Pi 5 host (already have) | Fasteners/hardware | |

⚠️ **Rail-length caveat:** Voron 2.4 300 uses specific rail lengths per axis. Rails you buy for a
"smaller-than-max" Kobra X/Y may or may not match the Voron's — size them with the Voron BOM in
mind so they transplant, or accept buying fresh rails for the Voron and reselling the Kobra ones.

## Open decisions (drive the pricing)
Resolved: Voron model (2.4 R2), size (300), sourcing (self-BOM), MMU (BoxTurtle). Still open:

1. **Voron parts material** — ABS/ASA (needs Kobra enclosure?) vs PETG/PC-blend for the printed parts.
2. **Kobra large-nozzle target** — 0.6, 0.8, or both? Any high-flow hotend upgrade wanted?
3. **Budget ceiling** — total the family is likely to approve, and any per-phase cap?
4. **Timeline** — is this months, or a "whenever funds allow" thing?
5. **Electronics choice for the Voron** — Octopus/Manta board class, toolhead board, Pi/CB1, stepper grade (affects cost a lot).
6. **Ender exit** — sell / gift / hand fully to son (affects net budget — may recoup some).
7. **Platform** — commit to Voron, or seriously price a **RatRig V-Core 4** (esp. a big 400/500 that unifies large-format + multi-material into one machine)?
8. **Fleet shape** — a **specialized fleet** (separate big + MM machines) vs **one do-everything printer** (big multi-material CoreXY)?
9. **Who gets the Kobra** — sold (B), kept by me + upgraded (A), or handed to son un-upgraded (F)?
10. **Voron parts sourcing** — print in PETG then reprint ABS, vs **Print-It-Forward** ABS parts from the start.

## Cost menu (to be filled from the Sheet)
Structured so it maps 1:1 into the Google Sheet.

### Track A — Kobra Max upgrades
| Item | Option(s) | Link | Qty | Unit $ | Line $ | Phase | Notes |
|------|-----------|------|-----|--------|--------|-------|-------|
| Large nozzles (0.6/0.8 hardened) | | | | | | 1 | |
| ADXL345 / input shaper (optional) | | | | | | 1 | |
| High-flow hotend (optional) | | | | | | 1 | |

### Track B — Voron 2.4 R2 300 (self-sourced BOM)
Categories follow the official 2.4 R2 BOM groupings. Ballpark ranges are indicative only —
**real numbers come from the Sheet.** Rough self-sourced total historically lands ~$700–1200
for the printer + ~$150–300 for BoxTurtle, highly dependent on part grade and sourcing.

| Subsystem | Option(s) | Link | Qty | Unit $ | Line $ | Ballpark | Notes |
|-----------|-----------|------|-----|--------|--------|----------|-------|
| Frame — 2020/2040 extrusion + brackets | | | | | | $80–140 | 300 size cut list |
| Motion — linear rails (MGN9/MGN12), belts, pulleys | | | | | | $120–220 | rail grade drives cost |
| Motors — 4× Z + 2× AB steppers | | | | | | $80–160 | LDO vs generic |
| Electronics — main board (Octopus/Manta), toolhead board, Pi/CB1, PSU(s) | | | | | | $150–260 | see open decision #5 |
| Hotend + extruder (0.4mm) — e.g. Dragon/Rapido + Clockwork2/Galileo | | | | | | $80–160 | |
| Bed — heater, aluminum plate, PEI, thermistor | | | | | | $60–120 | 300×300 |
| Fasteners / hardware / heatsets | | | | | | $40–80 | |
| Wiring / connectors / loom | | | | | | $40–80 | |
| Panels / enclosure (acrylic/foam/hardware) | | | | | | $40–90 | 2.4 is enclosed |
| Printed parts filament (ABS/ASA, ~1–1.5 kg) | | | | | | $25–45 | we print these |
| **BoxTurtle (AFC) multi-material** — extrusion, steppers, board, printed parts, hardware | | | | | | $150–300 | Phase 2b |

## Decisions log
- **Voron model: 2.4 R2** — flagship flying-gantry CoreXY; the most rewarding build, which fits the "fun" motivation.
- **Build size: 300mm _or_ 350mm — coupled to the route (see below).**
  - **Route A (keep Kobra): 300** — Kobra covers big prints, so no reason to pay the 350 tax (heavier gantry, slower/hotter bed, more power, longer rails/belts). No overlap needed.
  - **Route B (sell Kobra): 350** — the Voron becomes the only larger-capable machine, so 350 buys back most of the large-format capability. Since the Kobra's full 400×425 is rarely used, 350×350×350 covers nearly all "big" jobs. The 2.4 (flying gantry + quad-Z) stays rigid at 350. Extra cost vs 300 ≈ $80–150.
- **Sourcing: self-sourced BOM** — cheapest and the most building fun; we print our own parts (see note below).
- **Multi-material: BoxTurtle (AFC)** — modern, actively developed Voron-ecosystem MMU with good 2025–26 community momentum.

### Consequence: we print the Voron's own parts
Self-sourcing means printing ~1–1.5 kg of parts for the 2.4. Two implications:
- **Material:** Voron parts want **ABS/ASA** (chamber heat resistance). The Kobra Max is **open-frame**, so large ABS parts risk warping — may need a temporary enclosure, or print in ASA/PC-blend, or accept PETG for non-critical parts. **← open item.**
- **Sequencing:** print all Voron parts **before** retiring the Ender, so we always have a working 0.4mm machine during the build. Good reason to keep the Ender until Waypoint 2a.
