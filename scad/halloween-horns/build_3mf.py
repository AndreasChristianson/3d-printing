#!/usr/bin/env python3
"""Build a multi-part 3MF of the three-color horn for OrcaSlicer.

Renders the base/band/tip parts from horns_tricolor.scad with OpenSCAD, then
packs them into one 3MF as three objects that share one coordinate frame. Open
it in Orca, answer "Yes" to load it as a single object with multiple parts,
and assign a filament to each part.

Usage:  python3 build_3mf.py [SCALE]      (default 5 -> horns_tricolor_x5.3mf)
Needs:  openscad on PATH, and `pip install trimesh numpy`.
"""
import subprocess
import sys
import zipfile
from pathlib import Path

import numpy as np
import trimesh

HERE = Path(__file__).resolve().parent
PARTS = ["base", "band", "tip"]
COLORS = {"base": "#505050", "band": "#8B0000", "tip": "#FF8C00"}


def render(part, scale):
    out = HERE / f"horns_{part}.stl"
    subprocess.run(
        ["openscad", "--backend=manifold", "-D", f"scale_factor={scale}",
         "-D", f'part="{part}"', "-o", str(out), str(HERE / "horns_tricolor.scad")],
        check=True, capture_output=True)
    return trimesh.load(out)


def object_xml(mesh, oid, name, shift):
    verts = "".join('<vertex x="%.5f" y="%.5f" z="%.5f"/>' % tuple(v)
                    for v in mesh.vertices + shift)
    tris = "".join('<triangle v1="%d" v2="%d" v3="%d"/>' % tuple(f) for f in mesh.faces)
    return (f'<object id="{oid}" name="{name}" type="model" pid="1" pindex="{oid - 2}">'
            f"<mesh><vertices>{verts}</vertices><triangles>{tris}</triangles></mesh></object>")


def main():
    scale = float(sys.argv[1]) if len(sys.argv) > 1 else 5
    meshes = {p: render(p, scale) for p in PARTS}

    bounds = np.vstack([m.bounds for m in meshes.values()])
    lo, hi = bounds.min(0), bounds.max(0)
    # One shift for all parts: center in XY, rest on z=0. Orca re-arranges anyway.
    shift = -np.array([(lo[0] + hi[0]) / 2, (lo[1] + hi[1]) / 2, lo[2]])

    materials = "".join(f'<base name="{p}" displaycolor="{COLORS[p]}FF"/>' for p in PARTS)
    objects = "".join(object_xml(meshes[p], i + 2, f"horn_{p}", shift) for i, p in enumerate(PARTS))
    items = "".join(f'<item objectid="{i + 2}"/>' for i in range(len(PARTS)))
    model = (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<model unit="millimeter" xml:lang="en-US" '
        'xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02">'
        f'<resources><basematerials id="1">{materials}</basematerials>{objects}</resources>'
        f"<build>{items}</build></model>")
    content_types = (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/>'
        "</Types>")
    rels = (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Target="/3D/3dmodel.model" Id="rel0" '
        'Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/></Relationships>')

    out = HERE / f"horns_tricolor_x{scale:g}.3mf"
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("[Content_Types].xml", content_types)
        z.writestr("_rels/.rels", rels)
        z.writestr("3D/3dmodel.model", model)
    print(f"wrote {out.name}: {hi[2] - lo[2]:.1f} mm tall, "
          f"volume {sum(m.volume for m in meshes.values()):.0f} mm^3")


if __name__ == "__main__":
    main()
