#!/usr/bin/env python3
"""Build a plate of two-color wire labels as one 3MF for OrcaSlicer.

Each label is rendered from wire_label.scad as a base part and a text part,
then packed as one object with two parts (3MF components). In Orca, set each
label's base part to its category color and every text part to the text color.
The text is raised, so a label needs one filament change.

Usage:  python3 build_3mf.py [PLATE]      (default "test" -> wire_labels_test.3mf)
Needs:  openscad on PATH, and `pip install trimesh numpy`.
"""
import csv
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

import numpy as np
import trimesh

HERE = Path(__file__).resolve().parent
SCAD = HERE / "wire_label.scad"

# The three filaments on hand. Display colors only matter for the preview; the
# filament assignment in Orca decides what actually prints.
COLORS = {"red": "#B22222", "black": "#202020", "white": "#F0F0F0"}

# Category -> (background, text).
CATEGORY = {
    "power":  ("red",   "white"),
    "motor":  ("black", "white"),
    "sensor": ("white", "black"),
    "fan":    ("black", "red"),
    "led":    ("white", "red"),
    "other":  ("black", "white"),
}

# (text, category, style, bundle_d)
PLATES = {
    "test": [
        ("HEATER",  "power",  "stail", 3.0),
        ("THERM",   "sensor", "stail", 2.5),
        ("X MOTOR", "motor",  "stail", 4.5),
        ("24V",     "power",  "clip",  3.5),
        ("PROBE",   "sensor", "clip",  3.0),
        ("Y MOTOR", "motor",  "clip",  4.5),
    ],
    "stail": [
        ("HEATER",  "power",  "stail", 3.0),
        ("THERM",   "sensor", "stail", 2.5),
        ("X MOTOR", "motor",  "stail", 4.5),
        ("24V",     "power",  "stail", 3.5),
    ],
    "v2": [
        ("HEATER",  "power",  "wave", 3.0),
        ("THERM",   "sensor", "wave", 2.5),
        ("X MOTOR", "motor",  "wave", 4.5),
        ("24V",     "power",  "zip",  3.5),
        ("FAN",     "other",  "zip",  3.0),
    ],
    "zip": [
        ("HEATER",  "power",  "zip", 3.0),
        ("THERM",   "sensor", "zip", 2.5),
        ("X MOTOR", "motor",  "zip", 4.5),
        ("24V",     "power",  "zip", 3.5),
    ],
}
PLATES["zip_inlay"] = PLATES["zip"]

# The real set: labels.csv (text, category, bundle_d, qty, note), all zip.
# One plate per background color: face down, mixed backgrounds would need a
# change on every layer, not just the text layers.
with open(HERE / "labels.csv", newline="") as f:
    SET = [(r["text"], r["category"], "zip", float(r["bundle_d"]))
           for r in csv.DictReader(f) for _ in range(int(r["qty"]))]
for bg in COLORS:
    PLATES[f"set_{bg}"] = [l for l in SET if CATEGORY[l[1]][0] == bg]

# Plates with no clips can print face up with raised text: one filament change.
# Inlay prints face down: one change per text layer, but the face is the bed.
TEXT_MODE = {"test": "inlay", "stail": "raised", "v2": "raised", "zip": "raised",
             "zip_inlay": "inlay", **{f"set_{bg}": "inlay" for bg in COLORS}}

GAP = 4         # mm between labels on the plate
COLUMN_H = 200  # mm; start a new column past this


def render(label, part, text_mode, tmp):
    txt, _, style, d = label
    out = Path(tmp) / f"{txt.replace(' ', '_')}_{style}_{d:g}_{part}.stl"
    if out.exists():   # repeated labels: render once
        return trimesh.load(out)
    subprocess.run(
        ["openscad", "--backend=manifold", "--enable=textmetrics",
         "-D", f'part="{part}"', "-D", f'style="{style}"', "-D", f'text_mode="{text_mode}"',
         "-D", f'txt="{txt}"', "-D", f"bundle_d={d}",
         "-o", str(out), str(SCAD)],
        check=True, capture_output=True)
    return trimesh.load(out)


def mesh_xml(mesh, oid, name, pindex):
    verts = "".join('<vertex x="%.4f" y="%.4f" z="%.4f"/>' % tuple(v) for v in mesh.vertices)
    tris = "".join('<triangle v1="%d" v2="%d" v3="%d"/>' % tuple(f) for f in mesh.faces)
    return (f'<object id="{oid}" name="{name}" type="model" pid="1" pindex="{pindex}">'
            f"<mesh><vertices>{verts}</vertices><triangles>{tris}</triangles></mesh></object>")


def main():
    plate = sys.argv[1] if len(sys.argv) > 1 else "test"
    labels = PLATES[plate]

    names = list(COLORS)
    materials = "".join(f'<base name="{n}" displaycolor="{COLORS[n]}FF"/>' for n in names)

    objects, items = [], []
    oid, x, y, col_w = 2, 0.0, 0.0, 0.0
    with tempfile.TemporaryDirectory() as tmp:
        for label in labels:
            txt, cat, style, d = label
            mode = TEXT_MODE[plate]
            base, text = render(label, "base", mode, tmp), render(label, "text", mode, tmp)
            lo = np.minimum(base.bounds[0], text.bounds[0])
            hi = np.maximum(base.bounds[1], text.bounds[1])
            name = f"{txt} ({style} {d:g})"
            bg, fg = CATEGORY[cat]
            objects.append(mesh_xml(base, oid, f"{name} base", names.index(bg)))
            objects.append(mesh_xml(text, oid + 1, f"{name} text", names.index(fg)))
            objects.append(
                f'<object id="{oid + 2}" name="{name}" type="model"><components>'
                f'<component objectid="{oid}"/><component objectid="{oid + 1}"/>'
                "</components></object>")
            # Stack labels along Y in columns, each resting on z = 0.
            if y + hi[1] - lo[1] > COLUMN_H:
                x, y, col_w = x + col_w + GAP, 0.0, 0.0
            col_w = max(col_w, hi[0] - lo[0])
            items.append(f'<item objectid="{oid + 2}" '
                         f'transform="1 0 0 0 1 0 0 0 1 {x - lo[0]:.4f} {y - lo[1]:.4f} {-lo[2]:.4f}"/>')
            y += hi[1] - lo[1] + GAP
            oid += 3
            print(f"{name}: {hi[0] - lo[0]:.1f} x {hi[1] - lo[1]:.1f} x {hi[2] - lo[2]:.1f} mm")

    model = (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<model unit="millimeter" xml:lang="en-US" '
        'xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02">'
        f'<resources><basematerials id="1">{materials}</basematerials>{"".join(objects)}</resources>'
        f'<build>{"".join(items)}</build></model>')
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

    out = HERE / f"wire_labels_{plate}.3mf"
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("[Content_Types].xml", content_types)
        z.writestr("_rels/.rels", rels)
        z.writestr("3D/3dmodel.model", model)
    print(f"wrote {out.name}")


if __name__ == "__main__":
    main()
