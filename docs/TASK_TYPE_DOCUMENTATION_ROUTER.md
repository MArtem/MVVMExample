# Task Type Documentation Router

## Purpose
Keep decision and code quality high while loading only context that can affect the current task.

## Core Rule
Read this router first. Load the compact Level 0 baseline once per new chat or explicit rules refresh, then add only the routes required by the task. Do not treat `./docs/README.md` or the full documentation library as an always-read list.

Report the selected route for meaningful work:

```text
Docs route: Level 0 + <route names>
Deep references skipped/applied: <reason>
```

When a task crosses concerns, combine routes. If a route reveals ambiguity or elevated risk, open the next deeper reference for that concern.

## Level 0 — Always-read operating baseline

Read once after a new chat/context reset or an explicit rules refresh:

1. `./docs/CURRENT_USER_OVERRIDES.md`
2. `./docs/MODEL_ROUTING_RULE.md`
3. current task `handoff.md` and `plan.md`, when present
4. `./docs/TASK_TYPE_DOCUMENTATION_ROUTER.md`

`AGENTS.md` is supplied as repository instruction context and is not duplicated in the Level 0 read list.

Level 0 only establishes authority, model choice, current task state, and routing. It is not enough for implementation, review, documentation movement, or completion claims.

## Level 1 — Orientation and governance

Read only when the route requires it:

- Project/code/package orientation: `./PROJECT_DOCUMENTATION.md`, `./PROJECT_HEALTH.md`, `./docs/AGENT_RULES.md`.
- Non-trivial planning or execution: `./docs/AGENT_PREFLIGHT_CHECKLIST.md`,
  `./docs/ENGINEERING_CHANGE_QUALITY_STANDARD.md`.
- Documentation/rule/prompt/skill/template/package-doc changes: `./docs/DOCUMENT_CHANGE_GOVERNANCE_STANDARD.md`, `./docs/DOCUMENT_BOUNDARY_STANDARD.md`, `./docs/SOURCE_OF_TRUTH_MAP.md`, `./docs/DOCS_REPO_OPERATIONS.md`.
- Documentation library inventory/operations: `./docs/README.md`, `./docs/DOCUMENT_LIBRARY_GUIDE.md`, `./docs/DOCUMENTATION_VAULT_SUMMARY.md`.
- Task plan/handoff/archive changes: `./docs/TASK_STATE_DOCUMENTATION_STANDARD.md`.
- Context transfer or resume-state maintenance: `./docs/WORK_CONTINUITY.md`, `./docs/CONTEXT_TRANSFER_AND_NEW_CHAT_STANDARD.md`.
- Meaningful completion report: `./docs/COMPLETION_REPORT_CONTRACT.md`.
- New task/project/worktree/app: `./docs/NEW_PROJECT_START_CONTRACT.md`.
- Local reusable-rule exception: `./docs/LOCAL_EXCEPTION_ADR_TEMPLATE.md`.

## Level 2 — Task-specific standards and prompts

| Task type | Read |
|---|---|
| iOS implementation or refactor | `./docs/PRODUCT_REQUIREMENTS_STANDARD.md`, `./docs/PRODUCTION_QUALITY_GATES.md`, `./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`, relevant iOS standards below |
| iOS review/audit/production-ready claim | `./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md`, `./docs/IOS_PRODUCTION_READINESS_STANDARD.md`, `./docs/DEFINITION_OF_DONE.md`, `./docs/EVIDENCE_BASED_ENGINEERING_RULES.md`, `./docs/IOS_PRODUCTION_EXCEPTION_POLICY.md` |
| Pull request review | `./docs/IOS_PR_REVIEW_TEMPLATE.md`, review/audit route above |
| Architecture/navigation/state ownership | `./docs/IOS_ARCHITECTURE_STYLE_ROUTER.md`, `./docs/MODULAR_ARCHITECTURE_STANDARD.md`, `./docs/IOS_MVVM_INTENT_API_STANDARD.md`, `./docs/ARCHITECTURE_DECISION_GOVERNANCE.md`, `./docs/CODE_OWNERSHIP_AND_REVIEW_POLICY.md` |
| Swift concurrency/runtime/task lifecycle | `./docs/IOS_CONCURRENCY_RUNTIME_STANDARD.md` |
| SwiftUI rendering/performance | `./docs/IOS_UI_STATE_RENDERING_STANDARD.md`, `./docs/IOS_PERFORMANCE_BUDGETS.md` |
| Memory/cache/media/files | `./docs/IOS_MEMORY_CACHE_MEDIA_STANDARD.md`, `./docs/IOS_CAMERA_PHOTOS_FILES_PERMISSIONS_STANDARD.md` |
| Persistence/migration/data loss | `./docs/IOS_DATA_MIGRATION_STANDARD.md`, `./docs/DATA_GOVERNANCE_AND_COMPLIANCE.md` |
| Network/API/offline/sync | `./docs/API_CONTRACT_AND_INTEGRATION_RULES.md`, `./docs/IOS_NETWORK_RESILIENCE_STANDARD.md`, `./docs/IOS_OFFLINE_SYNC_STANDARD.md` |
| Security/privacy/secrets/imported project intake | `./docs/SECRET_HANDLING_AND_SECURITY_INTAKE_STANDARD.md`, `./docs/IOS_SECURITY_PRIVACY_GATE.md`, `./docs/IOS_CONFIGURATION_ENVIRONMENTS_STANDARD.md`, `./docs/IOS_INPUT_VALIDATION_CONTENT_SAFETY_STANDARD.md` |
| Accessibility/localization/QA/testing/compatibility | `./docs/IOS_ACCESSIBILITY_STANDARD.md`, `./docs/LOCALIZATION_INTERNATIONALIZATION_STANDARD.md`, `./docs/QA_TEST_PLAN_STANDARD.md`, `./docs/IOS_TESTING_STRATEGY.md`, `./docs/COMPATIBILITY_MATRIX.md` |
| Release/signing/TestFlight/App Store | `./docs/IOS_RELEASE_CHECKLIST.md`, `./docs/APPLE_PLATFORM_CAPABILITIES_STANDARD.md`, `./docs/CI_CD_QUALITY_GATES.md` |
| Observability/incidents/rollout/analytics | `./docs/IOS_OBSERVABILITY_STANDARD.md`, `./docs/IOS_ANALYTICS_TELEMETRY_TAXONOMY.md`, `./docs/FEATURE_FLAGS_AND_ROLLOUTS.md`, `./docs/INCIDENT_RESPONSE_STANDARD.md`, `./docs/PRODUCT_HEALTH_SLO.md`, `./docs/RISK_REGISTER.md`, `./docs/TECH_DEBT_REGISTER.md` |
| Lifecycle/background/deep links/widgets/extensions | `./docs/IOS_APP_LIFECYCLE_BACKGROUND_STANDARD.md`, `./docs/APPLE_PLATFORM_CAPABILITIES_STANDARD.md`, current `./docs/SHARE_EXTENSION_VALIDATION.md` when share-extension behavior is in scope |
| Error handling/user feedback | `./docs/IOS_ERROR_HANDLING_USER_FEEDBACK_STANDARD.md` |
| StoreKit/payments | `./docs/IOS_STOREKIT_PAYMENTS_STANDARD.md` |
| Figma/design-to-SwiftUI | `./docs/agent-prompts/FIGMA_TASK_ROUTER.md`, `./docs/UI_PIXEL_PERFECT_WORKFLOW.md`, `./docs/DESIGN_SYSTEM_GOVERNANCE.md`; load `figma-mcp-swiftui-implementation.md` only when the router requires deep Figma reference |
| AI/App Intents/Foundation Models | `./docs/agent-prompts/AI_iOS_TASK_ROUTER.md`, routed ranges from `AI_iOS_MASTER_PROMPT.md`, relevant package README only when package adoption is in scope |
| Deep iOS specialist knowledge | Select the matching `ios-*` machine route; scope and maturity start at `./docs/IOS_PLATFORM_SCOPE_AND_KNOWLEDGE_POLICY.md` and `./docs/knowledge/global/ios/README.md` |
| Code comments/documentation pass | `./docs/IOS_CODE_DOCUMENTATION_STANDARD.md`, `./docs/IOS_DOCUMENTATION_MAINTENANCE_STANDARD.md` |
| Reusable packages/managers/dependencies/adoption | `./docs/PACKAGES_AND_MANAGERS.md`, `./docs/PACKAGE_USAGE_SOURCE_ONLY.md`, `./docs/IOS_REUSABLE_INFRASTRUCTURE_PACKAGE_STANDARD.md`, `./docs/DEPENDENCY_POLICY.md`, relevant package README/catalog |
| Current content/feed persistence contract | `./docs/LOCAL_FEED_PERSISTENCE_CONTRACT.md`, persistence/migration/data-loss route |
| New iOS app/project bootstrap | `./docs/IOS_PROJECT_BOOTSTRAP_TEMPLATE.md`, `./docs/STATIC_GATE_ADOPTION.md`, `./docs/SECRET_HANDLING_AND_SECURITY_INTAKE_STANDARD.md`, architecture route, `./docs/DEVELOPER_EXPERIENCE_STANDARD.md` |
| Universal Xcode quality control, manual GitHub checks, Codex Review policy, verifier/bootstrap design | `./docs/UNIVERSAL_XCODE_QUALITY_CONTROL_GOVERNANCE.md`, `./docs/STATIC_QUALITY_GATE_POLICY.md`, `./docs/CI_CD_QUALITY_GATES.md`, `./docs/IOS_TESTING_STRATEGY.md`, `./docs/EVIDENCE_BASED_ENGINEERING_RULES.md`, `./docs/IOS_PRODUCTION_EXCEPTION_POLICY.md` |
| Static gates/scripts | `./docs/STATIC_QUALITY_GATE_POLICY.md`, relevant `./scripts/check_*.py` or `./scripts/run_static_quality_gates.sh` |

## Level 3 — Deep references

Read only when Level 2 requires more depth, the task is broad/high-risk, or the user asks for a full audit/design:

- `./docs/IOS_PRODUCTION_FRAMEWORK.md`
- `./docs/IOS_FEATURE_LIFECYCLE_PLAYBOOK.md`
- `./docs/IOS_PRODUCTION_AUDIT_MATRIX.md`
- `./docs/IOS_PRODUCTION_SCORECARD.md`
- `./docs/IOS_PLATFORM_SCOPE_AND_KNOWLEDGE_POLICY.md`
- `./docs/knowledge/global/ios/*.md`
- `./docs/IOS_AGENT_PROMPT_ROUTER.md`
- `./docs/IOS_ARCHITECTURE_REFERENCE.md`
- root `MANIFEST.md` in the canonical documentation repository, only for library completeness/recovery work
- architecture catalog under the canonical documentation repository
- complete package-vault documentation

## Archive — Not default input

Read archive/history/recovery material only when active docs conflict, current state is unclear, the user requests history, or a migration requires old behavior.

## Classification And Maintenance Contract

- `./docs/DOCUMENT_ROUTING_REGISTRY.json` is the machine-readable primary Level assignment for active top-level documents. It is validated, not read during normal startup.
- `./docs/TASK_DOCUMENT_ROUTES.json` is the machine-readable ordered route membership. It is resolved on demand, not read during normal startup.
- Every new active top-level doc must be indexed, assigned exactly one primary level, and reachable from a task route before completion.
- Prompts, skills, package docs, architecture cases, and archives use registry path patterns plus trigger-based routes.
- Level 0 has a validator-enforced word budget. Importance alone is not a reason to expand it.
- Keep one canonical rule plus short links. Do not copy long rules or startup lists across `AGENTS.md`, onboarding docs, continuity docs, overrides, or templates.
- App-specific decisions and exceptions remain in the matching app/task boundary unless the user explicitly approves app-neutral promotion.
- After routing changes, run `./scripts/check_task_type_documentation_router.py`, `./scripts/check_docs_index.py`, `./scripts/check_docs_consistency.py`, and `./scripts/check_documentation_boundaries.py` when available.

## Non-Goals

- Routing does not lower the engineering bar.
- Routing does not remove a gate required by the selected task.
- Passing routing checks does not prove production readiness.
- This router does not override explicit user instructions, repository instructions, or task-local rules.
