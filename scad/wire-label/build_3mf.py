#!/usr/bin/env python3
"""Build plates of two-color wire labels as Orca-native 3MF projects.

Each label is rendered from wire_label.scad as a base part and a text part,
packed as one object with two parts. The filament slot for every part is
written into Metadata/model_settings.config (Orca/Bambu project format), so
the plate opens already colored: no per-label filament assignment in Orca.

Labels come from labels.csv (text, category, bundle_d, qty, note). There is
one plate per background color: the labels print face down with the text
inlaid, and mixed backgrounds would need a filament change on every layer,
not just the text layers.

Usage:  python3 build_3mf.py [--slots black=2,white=3,red=4] [PLATE ...]
        (default: every set_<color> plate -> wire_labels_set_<color>.3mf)
Needs:  openscad on PATH, and `pip install trimesh numpy`.
"""
import argparse
import csv
import subprocess
import tempfile
import uuid
import zipfile
from pathlib import Path

import numpy as np
import trimesh

HERE = Path(__file__).resolve().parent
SCAD = HERE / "wire_label.scad"

# Filament slot per color (1-based: lane1 = T0 = 1). Lane 1 holds glow PLA, unused.
SLOTS = {"black": 2, "white": 3, "red": 4}

# Category -> (background, text).
CATEGORY = {
    "power":  ("red",   "white"),
    "motor":  ("black", "white"),
    "sensor": ("white", "black"),
    "fan":    ("black", "red"),
    "led":    ("white", "red"),
}

with open(HERE / "labels.csv", newline="") as f:
    SET = [(r["text"], r["category"], float(r["bundle_d"]))
           for r in csv.DictReader(f) for _ in range(int(r["qty"]))]
PLATES = {f"set_{bg}": [l for l in SET if CATEGORY[l[1]][0] == bg] for bg in SLOTS}

GAP = 4         # mm between labels on the plate
COLUMN_H = 200  # mm; start a new column past this

NS = ('xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02" '
      'xmlns:BambuStudio="http://schemas.bambulab.com/package/2021" '
      'xmlns:p="http://schemas.microsoft.com/3dmanufacturing/production/2015/06" '
      'requiredextensions="p"')
# Orca only reads model_settings.config from projects it recognizes as its own.
APP_META = ('<metadata name="Application">BambuStudio-02.06.00.51</metadata>'
            '<metadata name="BambuStudio:3mfVersion">1</metadata>')
IDENTITY = "1 0 0 0 1 0 0 0 1 0 0 0"


def render(label, part, tmp):
    txt, _, d = label
    out = Path(tmp) / f"{txt.replace(' ', '_')}_{d:g}_{part}.stl"
    if out.exists():   # repeated labels: render once
        return trimesh.load(out)
    subprocess.run(
        ["openscad", "--backend=manifold", "--enable=textmetrics",
         "-D", f'part="{part}"', "-D", 'style="zip"', "-D", 'text_mode="inlay"',
         "-D", f'txt="{txt}"', "-D", f"bundle_d={d}",
         "-o", str(out), str(SCAD)],
        check=True, capture_output=True)
    return trimesh.load(out)


def mesh_xml(mesh, oid):
    verts = "".join('<vertex x="%.4f" y="%.4f" z="%.4f"/>' % tuple(v) for v in mesh.vertices)
    tris = "".join('<triangle v1="%d" v2="%d" v3="%d"/>' % tuple(f) for f in mesh.faces)
    return (f'<object id="{oid}" p:UUID="{uuid.uuid4()}" type="model">'
            f"<mesh><vertices>{verts}</vertices><triangles>{tris}</triangles></mesh></object>")


def build(plate, slots):
    files = {}                          # zip path -> contents
    objects, items, settings, instances, assemble = [], [], [], [], []
    x, y, col_w = 0.0, 0.0, 0.0
    with tempfile.TemporaryDirectory() as tmp:
        for i, label in enumerate(PLATES[plate]):
            txt, cat, d = label
            bg, fg = CATEGORY[cat]
            base, text = render(label, "base", tmp), render(label, "text", tmp)
            lo = np.minimum(base.bounds[0], text.bounds[0])
            hi = np.maximum(base.bounds[1], text.bounds[1])

            # Two mesh objects in their own file, one composite object in the root.
            pa, pb, oid = 3 * i + 1, 3 * i + 2, 3 * i + 3
            path = f"/3D/Objects/label_{i + 1}.model"
            files[path[1:]] = (
                f'<?xml version="1.0" encoding="UTF-8"?>\n<model unit="millimeter" xml:lang="en-US" {NS}>'
                f'<metadata name="BambuStudio:3mfVersion">1</metadata>'
                f"<resources>{mesh_xml(base, pa)}{mesh_xml(text, pb)}</resources><build/></model>")
            objects.append(
                f'<object id="{oid}" p:UUID="{uuid.uuid4()}" type="model"><components>'
                f'<component p:path="{path}" objectid="{pa}" p:UUID="{uuid.uuid4()}" transform="{IDENTITY}"/>'
                f'<component p:path="{path}" objectid="{pb}" p:UUID="{uuid.uuid4()}" transform="{IDENTITY}"/>'
                "</components></object>")

            # Stack labels along Y in columns, each resting on z = 0.
            if y + hi[1] - lo[1] > COLUMN_H:
                x, y, col_w = x + col_w + GAP, 0.0, 0.0
            col_w = max(col_w, hi[0] - lo[0])
            xf = f"1 0 0 0 1 0 0 0 1 {x - lo[0]:.4f} {y - lo[1]:.4f} {-lo[2]:.4f}"
            items.append(f'<item objectid="{oid}" p:UUID="{uuid.uuid4()}" transform="{xf}" printable="1"/>')
            y += hi[1] - lo[1] + GAP

            settings.append(
                f'<object id="{oid}"><metadata key="name" value="{txt}"/>'
                f'<metadata key="extruder" value="{slots[bg]}"/>'
                + "".join(
                    f'<part id="{pid}" subtype="normal_part"><metadata key="name" value="{txt} {kind}"/>'
                    f'<metadata key="matrix" value="1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1"/>'
                    f'<metadata key="extruder" value="{slots[color]}"/></part>'
                    for pid, kind, color in ((pa, "base", bg), (pb, "text", fg)))
                + "</object>")
            instances.append(
                f'<model_instance><metadata key="object_id" value="{oid}"/>'
                f'<metadata key="instance_id" value="0"/>'
                f'<metadata key="identify_id" value="{1000 + i}"/></model_instance>')
            assemble.append(f'<assemble_item object_id="{oid}" instance_id="0" transform="{xf}" offset="0 0 0"/>')

    files["3D/3dmodel.model"] = (
        f'<?xml version="1.0" encoding="UTF-8"?>\n<model unit="millimeter" xml:lang="en-US" {NS}>'
        f'{APP_META}<resources>{"".join(objects)}</resources>'
        f'<build p:UUID="{uuid.uuid4()}">{"".join(items)}</build></model>')
    files["3D/_rels/3dmodel.model.rels"] = (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        + "".join(f'<Relationship Target="/{p}" Id="rel-{n + 1}" '
                  'Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/>'
                  for n, p in enumerate(p for p in files if p.startswith("3D/Objects/")))
        + "</Relationships>")
    files["Metadata/model_settings.config"] = (
        '<?xml version="1.0" encoding="UTF-8"?>\n<config>' + "".join(settings)
        + '<plate><metadata key="plater_id" value="1"/><metadata key="plater_name" value=""/>'
        + '<metadata key="locked" value="false"/>' + "".join(instances) + "</plate>"
        + "<assemble>" + "".join(assemble) + "</assemble></config>")
    files["[Content_Types].xml"] = (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/>'
        "</Types>")
    files["_rels/.rels"] = (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Target="/3D/3dmodel.model" Id="rel0" '
        'Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/></Relationships>')

    out = HERE / f"wire_labels_{plate}.3mf"
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        for name in ("[Content_Types].xml", "_rels/.rels"):
            z.writestr(name, files.pop(name))
        for name, data in files.items():
            z.writestr(name, data)
    used = sorted({c for t, cat, _ in PLATES[plate] for c in CATEGORY[cat]}, key=slots.get)
    print(f"wrote {out.name}: {len(PLATES[plate])} labels, slots "
          + ", ".join(f"{c}={slots[c]}" for c in used))


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--slots", help="filament slots, e.g. black=2,white=3,red=4")
    ap.add_argument("plates", nargs="*", default=list(PLATES))
    args = ap.parse_args()
    slots = dict(SLOTS)
    if args.slots:
        slots.update({c: int(n) for c, n in (kv.split("=") for kv in args.slots.split(","))})
    for plate in args.plates:
        build(plate, slots)


if __name__ == "__main__":
    main()
