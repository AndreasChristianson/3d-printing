"""Split a binary STL into connected shells and write them as separate 3MF objects."""
import sys
import zipfile

import numpy as np

src, out = sys.argv[1], sys.argv[2]

with open(src, "rb") as f:
    f.seek(80)
    n = int(np.frombuffer(f.read(4), "<u4")[0])
    rec = np.dtype([("n", "<f4", 3), ("v", "<f4", (3, 3)), ("a", "<u2")])
    tris = np.frombuffer(f.read(n * rec.itemsize), rec)["v"].astype(np.float64)

print(f"{n} triangles")

# Weld vertices on rounded coordinates.
flat = np.round(tris.reshape(-1, 3), 4)
verts, inv = np.unique(flat, axis=0, return_inverse=True)
faces = inv.reshape(-1, 3)

# Union-find over vertices; triangles sharing a vertex are one shell.
parent = np.arange(len(verts))


def find(x):
    root = x
    while parent[root] != root:
        root = parent[root]
    while parent[x] != root:
        parent[x], x = root, parent[x]
    return root


for a, b, c in faces:
    ra, rb, rc = find(a), find(b), find(c)
    parent[rb] = ra
    parent[rc] = ra

roots = np.array([find(i) for i in range(len(verts))])
face_root = roots[faces[:, 0]]
labels = np.unique(face_root)
print(f"{len(labels)} shells")

shells = []
for lab in labels:
    fsel = faces[face_root == lab]
    used, local = np.unique(fsel, return_inverse=True)
    v = verts[used]
    lo, hi = v.min(0), v.max(0)
    shells.append((v, local.reshape(-1, 3), lo, hi))

# Cubes are the big shells, connectors the small ones; name them by size and position.
vols = [np.prod(s[3] - s[2]) for s in shells]
order = sorted(range(len(shells)), key=lambda i: (-round(vols[i], 1), *np.round(shells[i][2], 1)))
big = max(vols)
names = []
counts = {"cube": 0, "connector": 0}
for i in order:
    kind = "cube" if vols[i] > big * 0.5 else "connector"
    counts[kind] += 1
    names.append((i, f"{kind}-{counts[kind]}"))

for i, name in names:
    v, f_, lo, hi = shells[i]
    size = hi - lo
    print(f"{name:13s} tris={len(f_):6d} size={size.round(2)} min={lo.round(2)}")

objs, items = [], []
for oid, (i, name) in enumerate(names, start=1):
    v, f_, lo, hi = shells[i]
    vx = "".join(f'<vertex x="{x:.4f}" y="{y:.4f}" z="{z:.4f}"/>' for x, y, z in v)
    tx = "".join(f'<triangle v1="{a}" v2="{b}" v3="{c}"/>' for a, b, c in f_)
    objs.append(
        f'<object id="{oid}" name="{name}" type="model"><mesh>'
        f"<vertices>{vx}</vertices><triangles>{tx}</triangles></mesh></object>"
    )
    items.append(f'<item objectid="{oid}"/>')

model = (
    '<?xml version="1.0" encoding="UTF-8"?>\n'
    '<model unit="millimeter" xml:lang="en-US" '
    'xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02">'
    f'<resources>{"".join(objs)}</resources><build>{"".join(items)}</build></model>'
)
ctypes = (
    '<?xml version="1.0" encoding="UTF-8"?>\n'
    '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
    '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
    '<Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/>'
    "</Types>"
)
rels = (
    '<?xml version="1.0" encoding="UTF-8"?>\n'
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
    '<Relationship Target="/3D/3dmodel.model" Id="rel0" '
    'Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/>'
    "</Relationships>"
)
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    z.writestr("[Content_Types].xml", ctypes)
    z.writestr("_rels/.rels", rels)
    z.writestr("3D/3dmodel.model", model)
print("wrote", out)
