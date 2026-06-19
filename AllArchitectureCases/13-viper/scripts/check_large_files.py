#!/usr/bin/env python3
from pathlib import Path
import sys
root = Path(__file__).resolve().parents[1]
limit = 5 * 1024 * 1024
exclude = {'.git', 'DerivedData', '.build', '.zenflow', '.zenflow-attachments', 'docs/reusable-baseline/external-environment'}
large=[]
for path in root.rglob('*'):
    if not path.is_file():
        continue
    rel=str(path.relative_to(root))
    if any(part in rel for part in exclude):
        continue
    size=path.stat().st_size
    if size > limit:
        large.append((rel,size))
if large:
    print('Large files over 5MB:')
    for rel,size in large:
        print(f'- ./{rel}: {size/1024/1024:.1f} MB')
    sys.exit(1)
print('Large file scan OK')
