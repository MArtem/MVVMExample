#!/usr/bin/env python3
from pathlib import Path
import re
import sys

root = Path(__file__).resolve().parents[1]
patterns = [
    ('private key', re.compile(r'-----BEGIN (RSA |EC |OPENSSH |)PRIVATE KEY-----')),
    ('aws access key', re.compile(r'AKIA[0-9A-Z]{16}')),
    ('generic token assignment', re.compile(r'(?i)(api[_-]?key|secret|token|password)\s*[:=]\s*["\'][^"\']{16,}["\']')),
]
exclude = {'.git', 'DerivedData', '.zenflow', 'docs/reusable-baseline/external-environment'}
allowed_demo_literals = (
    'demo-access-credential-not-a-secret',
    'demo-refresh-credential-not-a-secret',
)
findings=[]
for path in root.rglob('*'):
    if not path.is_file():
        continue
    rel=str(path.relative_to(root))
    if any(part in rel for part in exclude):
        continue
    if path.stat().st_size > 2_000_000:
        continue
    try:
        text=path.read_text(errors='ignore')
    except Exception:
        continue
    for name,rx in patterns:
        for match in rx.finditer(text):
            literal_match = re.search(r'["\']([^"\']+)["\']\s*$', match.group(0))
            literal = literal_match.group(1) if literal_match else ''
            if name == 'generic token assignment' and (
                literal.startswith(('dev-access-', 'dev-refresh-', 'reqres-demo-refresh-'))
                or literal.startswith('${')
                or literal in allowed_demo_literals
            ):
                continue
            line=text[:match.start()].count('\n')+1
            findings.append((name, rel, line))
if findings:
    print('Potential secrets found:')
    for name, rel, line in findings:
        print(f'- {name}: ./{rel}:{line}')
    sys.exit(1)
print('Secret scan OK')
