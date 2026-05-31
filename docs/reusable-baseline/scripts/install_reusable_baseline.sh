#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <target-project-root> <AppName> [task-id]" >&2
  exit 2
fi

TARGET_ROOT="$1"
APP_NAME="$2"
TASK_ID="${3:-task-id}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASELINE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

mkdir -p "${TARGET_ROOT}"

# Copy reusable docs, project-local skills, and root quality scripts.
rsync -a "${BASELINE_ROOT}/docs/" "${TARGET_ROOT}/docs/"
if [[ -d "${BASELINE_ROOT}/root-scripts" ]]; then
  mkdir -p "${TARGET_ROOT}/scripts"
  rsync -a "${BASELINE_ROOT}/root-scripts/" "${TARGET_ROOT}/scripts/"
fi
if [[ -d "${BASELINE_ROOT}/.codex" ]]; then
  rsync -a "${BASELINE_ROOT}/.codex/" "${TARGET_ROOT}/.codex/"
fi

# Preserve environment-level skill snapshots for recovery/reference.
mkdir -p "${TARGET_ROOT}/docs/reusable-baseline"
rsync -a "${BASELINE_ROOT}/external-environment/" "${TARGET_ROOT}/docs/reusable-baseline/external-environment/"
if [[ -d "${BASELINE_ROOT}/scripts" ]]; then
  mkdir -p "${TARGET_ROOT}/docs/reusable-baseline/scripts"
  rsync -a "${BASELINE_ROOT}/scripts/" "${TARGET_ROOT}/docs/reusable-baseline/scripts/"
fi
cp "${BASELINE_ROOT}/REUSABLE_USER_AND_AGENT_RULES.md" "${TARGET_ROOT}/docs/reusable-baseline/"
cp "${BASELINE_ROOT}/NEW_PROJECT_PORTING_GUIDE.md" "${TARGET_ROOT}/docs/reusable-baseline/"
cp "${BASELINE_ROOT}/EXTERNAL_SKILL_DEPENDENCIES.md" "${TARGET_ROOT}/docs/reusable-baseline/"
cp "${BASELINE_ROOT}/TRANSFER_CHECKLIST.md" "${TARGET_ROOT}/docs/reusable-baseline/"
if [[ -f "${BASELINE_ROOT}/MVVMEXAMPLE_REMEDIATION_SPEC.md" ]]; then
  cp "${BASELINE_ROOT}/MVVMEXAMPLE_REMEDIATION_SPEC.md" "${TARGET_ROOT}/docs/reusable-baseline/"
fi

# Instantiate canonical project-specific templates only when missing.
copy_template_if_missing() {
  local src="$1"
  local dest="$2"
  if [[ ! -e "${dest}" ]]; then
    mkdir -p "$(dirname "${dest}")"
    sed -e "s/<AppName>/${APP_NAME}/g" -e "s/<task-id>/${TASK_ID}/g" "${src}" > "${dest}"
  fi
}

copy_template_if_missing "${BASELINE_ROOT}/templates/AGENTS.template.md" "${TARGET_ROOT}/AGENTS.md"
copy_template_if_missing "${BASELINE_ROOT}/templates/PROJECT_DOCUMENTATION.template.md" "${TARGET_ROOT}/PROJECT_DOCUMENTATION.md"
copy_template_if_missing "${BASELINE_ROOT}/templates/PROJECT_HEALTH.template.md" "${TARGET_ROOT}/PROJECT_HEALTH.md"
copy_template_if_missing "${BASELINE_ROOT}/templates/TESTING_INSTRUCTIONS.template.md" "${TARGET_ROOT}/TESTING_INSTRUCTIONS.md"
copy_template_if_missing "${BASELINE_ROOT}/templates/docs/README.template.md" "${TARGET_ROOT}/docs/README.md"
copy_template_if_missing "${BASELINE_ROOT}/templates/docs/CURRENT_USER_OVERRIDES.template.md" "${TARGET_ROOT}/docs/CURRENT_USER_OVERRIDES.md"
copy_template_if_missing "${BASELINE_ROOT}/templates/docs/WORK_CONTINUITY.template.md" "${TARGET_ROOT}/docs/WORK_CONTINUITY.md"
copy_template_if_missing "${BASELINE_ROOT}/templates/scripts/verify.template.sh" "${TARGET_ROOT}/scripts/verify.sh"
chmod +x "${TARGET_ROOT}/scripts/verify.sh" 2>/dev/null || true

# Ensure gitignore exists with common generated artifacts.
if [[ ! -e "${TARGET_ROOT}/.gitignore" ]]; then
  cat > "${TARGET_ROOT}/.gitignore" <<'EOF'
# macOS / Xcode
.DS_Store
DerivedData/
*.xcuserstate
xcuserdata/

# Swift / build artifacts
.build/
build/
DerivedData/
*.log

# Node / web tooling
node_modules/
dist/
.cache/

# Secrets / local env
.env
.env.*
*.p8
*.p12
*.mobileprovision
*.cer
*.key
EOF
fi

( cd "${TARGET_ROOT}" && git diff --check )

echo "Reusable baseline installed into ${TARGET_ROOT}"
