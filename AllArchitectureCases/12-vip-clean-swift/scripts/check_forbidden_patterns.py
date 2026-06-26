#!/usr/bin/env python3
from pathlib import Path
import re
import sys

root = Path(__file__).resolve().parents[1]
exclude_parts = {
    'Tests', 'UITests', '.git', 'DerivedData', '.zenflow',
    'docs/archive', 'docs/reusable-baseline/external-environment'
}
patterns = [
    ('UIImage(contentsOfFile:) in SwiftUI/source', re.compile(r'UIImage\s*\(\s*contentsOfFile\s*:')),
    ('Data(contentsOf:) sync file read', re.compile(r'Data\s*\(\s*contentsOf\s*:')),
    ('PDFDocument(url:) sync PDF load', re.compile(r'PDFDocument\s*\(\s*url\s*:')),
    ('AVAssetImageGenerator usage', re.compile(r'AVAssetImageGenerator')),
    ('ForEach(Array(...))', re.compile(r'ForEach\s*\(\s*Array\s*\(')),
    ('AnyView usage', re.compile(r'\bAnyView\s*\(')),
    ('default Interactor send(_ action:) API', re.compile(r'func\s+send\s*\(\s*_\s+action\s*:')),
    ('UI action enum boilerplate', re.compile(r'enum\s+\w+Action\s*:\s*Equatable')),
]
network_boundary = re.compile(r'(Infrastructure/Networking|Packages/AppNetworking/Sources/AppNetworking|Data/API)')
try_optional = re.compile(r'try\?')
findings=[]
for path in root.rglob('*.swift'):
    rel=str(path.relative_to(root))
    if any(part in rel for part in exclude_parts):
        continue
    text=path.read_text(errors='ignore')
    for name,rx in patterns:
        for match in rx.finditer(text):
            line=text[:match.start()].count('\n')+1
            findings.append((name, rel, line))
    if network_boundary.search(rel):
        for match in try_optional.finditer(text):
            line=text[:match.start()].count('\n')+1
            findings.append(('try? in networking/API boundary', rel, line))
if findings:
    print('Forbidden/high-risk Swift patterns found:')
    for name, rel, line in findings:
        print(f'- {name}: ./{rel}:{line}')
    sys.exit(1)
print('Forbidden/high-risk Swift pattern scan OK')
