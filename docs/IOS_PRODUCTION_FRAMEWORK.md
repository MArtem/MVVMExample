# iOS Production Framework

## Purpose
Canonical reusable framework for production-grade iOS development across any serious app: small, large, consumer, enterprise, offline-first, media-heavy, regulated, or platform-integrated.

This framework is not app-specific. It defines the minimum operating system for building, reviewing, verifying, releasing, and operating iOS software.

## Non-Negotiable Principle
A feature is not production-grade because it compiles or looks correct. It is production-grade only when product behavior, architecture, runtime performance, data safety, privacy/security, accessibility, observability, verification, release, rollback, and operational ownership are covered or explicitly marked not applicable with evidence.


## Framework Operating Documents
- `./docs/IOS_FEATURE_LIFECYCLE_PLAYBOOK.md`
- `./docs/IOS_PRODUCTION_AUDIT_MATRIX.md`
- `./docs/IOS_PR_REVIEW_TEMPLATE.md`
- `./docs/IOS_PROJECT_BOOTSTRAP_TEMPLATE.md`
- `./docs/IOS_AGENT_PROMPT_ROUTER.md`
- `./docs/IOS_PRODUCTION_EXCEPTION_POLICY.md`
- `./docs/IOS_PRODUCTION_SCORECARD.md`
- `./docs/IOS_DOCUMENTATION_MAINTENANCE_STANDARD.md`
- `./docs/IOS_CODE_DOCUMENTATION_STANDARD.md`

## Framework Layers
1. **Product Layer**: requirements, acceptance criteria, non-goals, states, analytics, rollout.
2. **Architecture Layer**: module boundaries, ADRs, ownership, dependency direction, data flow.
3. **Runtime Layer**: UI rendering, state invalidation, concurrency, memory, media, lifecycle.
4. **Data Layer**: persistence, migration, offline/sync, cache, privacy, compliance.
5. **Integration Layer**: network, API contracts, permissions, platform capabilities, third-party SDKs.
6. **User Experience Layer**: accessibility, localization, error handling, design system, performance.
7. **Verification Layer**: tests, static gates, manual QA, Instruments, evidence, CI/CD.
8. **Release/Ops Layer**: signing, TestFlight/App Store, feature flags, rollout, SLOs, incidents, rollback.
9. **Governance Layer**: code ownership, risk, tech debt, documentation, exceptions, review policy.

## Mandatory Workflow For Any Non-Trivial Feature
1. Read the active project docs and this framework index.
2. Apply `./docs/PRODUCT_REQUIREMENTS_STANDARD.md`.
3. Select domain-specific standards from the coverage matrix.
4. If architecture changes, apply `./docs/ARCHITECTURE_DECISION_GOVERNANCE.md`.
5. Implement the simplest correct solution.
6. Apply `./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`.
7. Apply `./docs/EVIDENCE_BASED_ENGINEERING_RULES.md` before claiming completion.
8. Run appropriate static/build/test/manual/profiler gates.
9. Record remaining risks, exceptions, or deferred debt.
10. Update docs/risk/debt/runbooks when behavior or ownership changes.

## Coverage Matrix
| Area | Standard |
|---|---|
| Product requirements | `./docs/PRODUCT_REQUIREMENTS_STANDARD.md` |
| Definition of done | `./docs/DEFINITION_OF_DONE.md` |
| Evidence | `./docs/EVIDENCE_BASED_ENGINEERING_RULES.md` |
| Production gates | `./docs/PRODUCTION_QUALITY_GATES.md` |
| Review completeness | `./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md` |
| Code review checklist | `./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md` |
| Architecture decisions | `./docs/ARCHITECTURE_DECISION_GOVERNANCE.md` |
| Modular architecture | `./docs/MODULAR_ARCHITECTURE_STANDARD.md` |
| Code ownership | `./docs/CODE_OWNERSHIP_AND_REVIEW_POLICY.md` |
| UI state/rendering | `./docs/IOS_UI_STATE_RENDERING_STANDARD.md` |
| Performance budgets | `./docs/IOS_PERFORMANCE_BUDGETS.md` |
| Memory/cache/media | `./docs/IOS_MEMORY_CACHE_MEDIA_STANDARD.md` |
| Concurrency/runtime | `./docs/IOS_CONCURRENCY_RUNTIME_STANDARD.md` |
| Lifecycle/background | `./docs/IOS_APP_LIFECYCLE_BACKGROUND_STANDARD.md` |
| Error handling | `./docs/IOS_ERROR_HANDLING_USER_FEEDBACK_STANDARD.md` |
| Accessibility | `./docs/IOS_ACCESSIBILITY_STANDARD.md` |
| Localization | `./docs/LOCALIZATION_INTERNATIONALIZATION_STANDARD.md` |
| Design system | `./docs/DESIGN_SYSTEM_GOVERNANCE.md` |
| Network resilience | `./docs/IOS_NETWORK_RESILIENCE_STANDARD.md` |
| API contracts | `./docs/API_CONTRACT_AND_INTEGRATION_RULES.md` |
| Offline/sync | `./docs/IOS_OFFLINE_SYNC_STANDARD.md` |
| Persistence/migration | `./docs/IOS_DATA_MIGRATION_STANDARD.md` |
| Security/privacy | `./docs/IOS_SECURITY_PRIVACY_GATE.md` |
| Data governance | `./docs/DATA_GOVERNANCE_AND_COMPLIANCE.md` |
| Input/content safety | `./docs/IOS_INPUT_VALIDATION_CONTENT_SAFETY_STANDARD.md` |
| Permissions/files/photos/camera | `./docs/IOS_CAMERA_PHOTOS_FILES_PERMISSIONS_STANDARD.md` |
| Configuration/environments | `./docs/IOS_CONFIGURATION_ENVIRONMENTS_STANDARD.md` |
| Analytics/telemetry | `./docs/IOS_ANALYTICS_TELEMETRY_TAXONOMY.md` |
| Platform capabilities | `./docs/APPLE_PLATFORM_CAPABILITIES_STANDARD.md` |
| StoreKit/payments | `./docs/IOS_STOREKIT_PAYMENTS_STANDARD.md` |
| Testing | `./docs/IOS_TESTING_STRATEGY.md` |
| QA plan | `./docs/QA_TEST_PLAN_STANDARD.md` |
| CI/CD | `./docs/CI_CD_QUALITY_GATES.md` |
| Static gates | `./docs/STATIC_QUALITY_GATE_POLICY.md` |
| Dependencies | `./docs/DEPENDENCY_POLICY.md` |
| Release | `./docs/IOS_RELEASE_CHECKLIST.md` |
| Feature flags/rollout | `./docs/FEATURE_FLAGS_AND_ROLLOUTS.md` |
| Product health/SLO | `./docs/PRODUCT_HEALTH_SLO.md` |
| Incident response | `./docs/INCIDENT_RESPONSE_STANDARD.md` |
| Risk register | `./docs/RISK_REGISTER.md` |
| Tech debt register | `./docs/TECH_DEBT_REGISTER.md` |
| Compatibility | `./docs/COMPATIBILITY_MATRIX.md` |
| Developer experience | `./docs/DEVELOPER_EXPERIENCE_STANDARD.md` |
| Documentation maintenance | `./docs/IOS_DOCUMENTATION_MAINTENANCE_STANDARD.md` |
| Inline code documentation | `./docs/IOS_CODE_DOCUMENTATION_STANDARD.md` |
| Exception policy | `./docs/IOS_PRODUCTION_EXCEPTION_POLICY.md` |
| Scorecard | `./docs/IOS_PRODUCTION_SCORECARD.md` |

## Completion Rule
Do not claim `production-ready` unless all applicable rows in the coverage matrix are checked, not applicable with reason, or recorded as remaining risk with owner and remediation path.
