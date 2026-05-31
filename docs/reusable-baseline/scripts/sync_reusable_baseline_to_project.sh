#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <target-project-root> [AppName] [task-id]" >&2
  exit 2
fi

TARGET_ROOT="$1"
APP_NAME="${2:-AppName}"
TASK_ID="${3:-task-id}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"${SCRIPT_DIR}/install_reusable_baseline.sh" "${TARGET_ROOT}" "${APP_NAME}" "${TASK_ID}"

cat <<MSG
Reusable baseline synced into ${TARGET_ROOT}.

Important:
- Existing project-specific root files are not blindly overwritten by template generation.
- Generic docs, scripts, reusable-baseline metadata, skills, and external skill snapshots are refreshed.
- If a global rule changes and the existing project's AGENTS.md/CURRENT_USER_OVERRIDES.md must be updated, apply that project-specific edit explicitly.
MSG
