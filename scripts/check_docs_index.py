#!/usr/bin/env python3
from pathlib import Path
import re, sys
root = Path(__file__).resolve().parents[1]
text = (root / 'docs' / 'README.md').read_text()
paths = set(re.findall(r'`(\./[^`]+)`', text))
missing = []
checked = 0
for item in sorted(paths):
    # Ignore globs, placeholders, and Zenflow-local task state. The latter is intentionally
    # untracked, so a clean GitHub checkout must not fail documentation validation for it.
    if '*' in item or '<' in item or '...' in item or item.startswith('./.zenflow/'):
        continue
    checked += 1
    p = root / item[2:]
    if not p.exists():
        missing.append(item)
if missing:
    print('Missing indexed docs/files:')
    for m in missing:
        print(f'- {m}')
    sys.exit(1)
print(f'Docs index OK: {checked} tracked paths checked')
