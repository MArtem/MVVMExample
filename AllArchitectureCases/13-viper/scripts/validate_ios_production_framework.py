#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = [
    './docs/IOS_PRODUCTION_FRAMEWORK.md',
    './docs/IOS_FEATURE_LIFECYCLE_PLAYBOOK.md',
    './docs/IOS_PRODUCTION_AUDIT_MATRIX.md',
    './docs/IOS_PR_REVIEW_TEMPLATE.md',
    './docs/IOS_PROJECT_BOOTSTRAP_TEMPLATE.md',
    './docs/IOS_AGENT_PROMPT_ROUTER.md',
    './docs/IOS_PRODUCTION_EXCEPTION_POLICY.md',
    './docs/IOS_PRODUCTION_SCORECARD.md',
    './docs/IOS_DOCUMENTATION_MAINTENANCE_STANDARD.md',
    './docs/IOS_CODE_DOCUMENTATION_STANDARD.md',
    './docs/PRODUCT_REQUIREMENTS_STANDARD.md',
    './docs/ARCHITECTURE_DECISION_GOVERNANCE.md',
    './docs/CODE_OWNERSHIP_AND_REVIEW_POLICY.md',
    './docs/EVIDENCE_BASED_ENGINEERING_RULES.md',
    './docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md',
    './docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md',
    './docs/IOS_CONCURRENCY_RUNTIME_STANDARD.md',
    './docs/IOS_MEMORY_CACHE_MEDIA_STANDARD.md',
    './docs/IOS_UI_STATE_RENDERING_STANDARD.md',
    './docs/IOS_NETWORK_RESILIENCE_STANDARD.md',
    './docs/IOS_OFFLINE_SYNC_STANDARD.md',
    './docs/IOS_APP_LIFECYCLE_BACKGROUND_STANDARD.md',
    './docs/IOS_ERROR_HANDLING_USER_FEEDBACK_STANDARD.md',
    './docs/IOS_SECURITY_PRIVACY_GATE.md',
    './docs/IOS_ACCESSIBILITY_STANDARD.md',
    './docs/LOCALIZATION_INTERNATIONALIZATION_STANDARD.md',
    './docs/IOS_DATA_MIGRATION_STANDARD.md',
    './docs/API_CONTRACT_AND_INTEGRATION_RULES.md',
    './docs/IOS_RELEASE_CHECKLIST.md',
    './docs/FEATURE_FLAGS_AND_ROLLOUTS.md',
    './docs/INCIDENT_RESPONSE_STANDARD.md',
    './docs/PRODUCT_HEALTH_SLO.md',
    './docs/RISK_REGISTER.md',
    './docs/TECH_DEBT_REGISTER.md',
    './docs/STATIC_QUALITY_GATE_POLICY.md',
    './docs/agent-prompts/ios-production-readiness-review.md',
    './docs/agent-prompts/evidence-based-completion-review.md',
    './docs/agent-prompts/ios-concurrency-review.md',
    './docs/agent-prompts/ios-memory-cache-media-review.md',
    './docs/agent-prompts/ios-ui-state-rendering-review.md',
    './docs/agent-prompts/ios-network-resilience-review.md',
    './docs/agent-prompts/ios-offline-sync-review.md',
    './docs/agent-prompts/ios-lifecycle-background-review.md',
    './docs/agent-prompts/ios-code-documentation-review.md',
    './.codex/skills/ios-production-auditor/SKILL.md',
    './.codex/skills/ios-evidence-gate/SKILL.md',
    './.codex/skills/ios-concurrency-runtime/SKILL.md',
    './.codex/skills/ios-memory-cache-media/SKILL.md',
    './.codex/skills/ios-network-resilience/SKILL.md',
    './.codex/skills/ios-offline-sync/SKILL.md',
    './.codex/skills/ios-lifecycle-background/SKILL.md',
    './.codex/skills/ios-code-documentation/SKILL.md',
]

missing = [path for path in REQUIRED if not (ROOT / path[2:]).exists()]
if missing:
    print('iOS production framework missing required files:')
    for path in missing:
        print(f'- {path}')
    sys.exit(1)

framework = (ROOT / 'docs/IOS_PRODUCTION_FRAMEWORK.md').read_text(errors='ignore')
not_linked = [path for path in REQUIRED if path.startswith('./docs/') and not path.startswith('./docs/agent-prompts/') and path not in framework and path != './docs/IOS_PRODUCTION_FRAMEWORK.md']
if not_linked:
    print('iOS production framework does not reference required docs:')
    for path in not_linked:
        print(f'- {path}')
    sys.exit(1)

print(f'iOS production framework OK: {len(REQUIRED)} required files present')
