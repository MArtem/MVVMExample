#!/usr/bin/env python3
from pathlib import Path
import re
import sys

root = Path(__file__).resolve().parents[1]
exclude = {'Tests', 'UITests', '.git', 'DerivedData', '.zenflow', 'docs/reusable-baseline/external-environment'}
# Heuristic: common SwiftUI user-facing initializers must not receive bare string literals.
rx = re.compile(r'\b(Text|Button|Label|TextField|SecureField|Section)\s*\(\s*"([^"\\]*(?:\\.[^"\\]*)*)"')
findings=[]

string_catalogs = list((root / 'ExplicitIntentMVVMCase').rglob('*.xcstrings'))
if not string_catalogs:
    print('Missing localization resources: expected at least one .xcstrings file under ./ExplicitIntentMVVMCase')
    sys.exit(1)
for path in root.rglob('*.swift'):
    rel=str(path.relative_to(root))
    if any(part in rel for part in exclude):
        continue
    text=path.read_text(errors='ignore')
    for m in rx.finditer(text):
        literal=m.group(2)
        context=text[max(0,m.start()-300):m.start()+300]
        if '#Preview' in context or 'systemImage:' in context:
            continue
        line=text[:m.start()].count('\n')+1
        findings.append((rel,line,literal))
if findings:
    print('Potential hard-coded user-facing literals:')
    for rel,line,literal in findings[:100]:
        print(f'- ./{rel}:{line}: "{literal}"')
    if len(findings)>100:
        print(f'... {len(findings)-100} more')
    sys.exit(1)
print('Localization heuristic scan OK')
