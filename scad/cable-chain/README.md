# Cable chain

Openable 45 mm wide cable chains for the Kobra Max X gantry and Z axis,
replacing the old scaled "Chain link 55 degree angle" chains.

- `chain_link.scad`: the link and its snap-in bar (`chain = "x"` or `"z"`)
- `chain_ends.scad`: the end mounts (`x_bottom`, `x_toolhead`, `z_base`, `z_top`)

## Link counts

Each new chain matches its old chain's length, measured pivot to pivot
(number of links × pitch).

| Chain | Old chain               | Old length | New pitch | New links | New length |
|-------|-------------------------|------------|-----------|-----------|------------|
| X     | 15 × 25.5 mm (150%)     | 382.5 mm   | 32 mm     | **12**    | 384 mm     |
| Z     | 23 × 34 mm (200%)       | 782 mm     | 34 mm     | **23**    | 782 mm     |

Print one snap-in bar per link. The bar is the same for both chains
(`bar.stl`). Print a spare link or two of each, plus spare bars: a snap leg
can crack when the bar is pried off.

The Z chain may be longer than it needs to be. To trim it, move Z to the
end of its travel where the gantry is farthest from the base. Any links
that still lie flat past the U-bend there are spare, and each one removed
takes 34 mm off. Then check the other end of the travel, where the chain
bunches up, to make sure the fold doesn't hit anything.

## Clear inside

| Chain | Old              | New            |
|-------|------------------|----------------|
| X     | 16.5 × 13.7 mm   | 33 × 14 mm     |
| Z     | 22 × 18.2 mm     | 33 × 20.6 mm   |

## Rendering

Commit first, then render with `scad/render.sh` so the provenance tag gets
the SHA. From this directory:

    ../render.sh chain_link.scad link_x.stl -D 'chain="x"' -D 'part="link_print"'
    ../render.sh chain_link.scad link_outer_open.stl -D 'chain="z"' -D 'part="link_print"'
    ../render.sh chain_link.scad bar.stl -D 'part="bar"'

The STLs stay next to the .scad files and are gitignored.
