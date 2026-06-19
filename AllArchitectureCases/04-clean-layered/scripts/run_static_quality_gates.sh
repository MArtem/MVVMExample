#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python3 "$ROOT/scripts/check_docs_index.py"
python3 "$ROOT/scripts/validate_ios_production_framework.py"
python3 "$ROOT/scripts/check_secrets.py"
python3 "$ROOT/scripts/check_large_files.py"
python3 "$ROOT/scripts/check_forbidden_patterns.py"
python3 "$ROOT/scripts/check_localization.py"
python3 "$ROOT/scripts/check_swiftui_hot_path_patterns.py"
