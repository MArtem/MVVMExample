#!/usr/bin/env python3
from pathlib import Path
import re
import sys

root=Path(__file__).resolve().parents[1]
exclude={'Tests','UITests','.git','DerivedData','.zenflow','docs/reusable-baseline/external-environment'}
patterns=[
 ('GeometryReader usage; verify not in repeated row hot path', re.compile(r'\bGeometryReader\b')),
 ('PreferenceKey usage; verify scroll/layout update rate', re.compile(r'\bPreferenceKey\b')),
 ('Broad animation without obvious value parameter', re.compile(r'\.animation\s*\([^\n)]*\)')),
]
task_pattern = re.compile(r'\bTask\s*\{')
findings=[]
for path in root.rglob('*.swift'):
    rel=str(path.relative_to(root))
    if any(part in rel for part in exclude):
        continue
    text=path.read_text(errors='ignore')
    for name,rx in patterns:
        for m in rx.finditer(text):
            line=text[:m.start()].count('\n')+1
            findings.append((name,rel,line))
    if 'Interactor.swift' in rel:
        for m in task_pattern.finditer(text):
            prefix = text[max(0, m.start()-80):m.start()]
            if '= ' not in prefix and '=\n' not in prefix:
                line=text[:m.start()].count('\n')+1
                findings.append(('Task without explicit Interactor task ownership', rel, line))
if findings:
    print('SwiftUI hot-path review candidates:')
    for name,rel,line in findings[:150]:
        print(f'- {name}: ./{rel}:{line}')
    if len(findings)>150:
        print(f'... {len(findings)-150} more')
    sys.exit(0)
print('SwiftUI hot-path candidate scan OK')
