#!/usr/bin/env python3
from pathlib import Path
import re, sys
root = Path(__file__).resolve().parents[1]
exclude = {'Tests', 'UITests', '.git', 'DerivedData', '.zenflow', 'docs/reusable-baseline/external-environment'}
# Heuristic only: flags simple Text("literal") occurrences that do not look like previews/debug/system symbols.
rx = re.compile(r'\bText\s*\(\s*"([^"]*[A-Za-zА-Яа-я][^"]*)"\s*\)')
findings=[]
for path in root.rglob('*.swift'):
    rel=str(path.relative_to(root))
    if any(part in rel for part in exclude):
        continue
    text=path.read_text(errors='ignore')
    for m in rx.finditer(text):
        literal=m.group(1)
        if literal.startswith('system.') or '#Preview' in text[max(0,m.start()-300):m.start()+300]:
            continue
        line=text[:m.start()].count('\n')+1
        findings.append((rel,line,literal))
if findings:
    print('Potential hard-coded user-facing Text literals:')
    for rel,line,literal in findings[:100]:
        print(f'- ./{rel}:{line}: "{literal}"')
    if len(findings)>100:
        print(f'... {len(findings)-100} more')
    sys.exit(1)
print('Localization heuristic scan OK')
