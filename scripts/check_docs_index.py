#!/usr/bin/env python3
from pathlib import Path
import re, sys
root = Path(__file__).resolve().parents[1]
text = (root / 'docs' / 'README.md').read_text()
paths = set(re.findall(r'`(\./[^`]+)`', text))
missing = []
for item in sorted(paths):
    # Ignore globs and placeholders.
    if '*' in item or '<' in item or '...' in item:
        continue
    p = root / item[2:]
    if not p.exists():
        missing.append(item)
if missing:
    print('Missing indexed docs/files:')
    for m in missing:
        print(f'- {m}')
    sys.exit(1)
print(f'Docs index OK: {len(paths)} indexed paths checked')
