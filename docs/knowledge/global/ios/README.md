# Global iOS Production Knowledge

## Purpose
Reusable iOS production knowledge that is not tied to one app. The implementation core covers supported iPhone and iPad platforms; verification remains subject to `CURRENT_USER_OVERRIDES.md` and current permission. watchOS, visionOS, tvOS, and macOS-specific guidance is added only when an explicit task trigger requires it.

## Scope And Maturity
- `./docs/IOS_PLATFORM_SCOPE_AND_KNOWLEDGE_POLICY.md`
- `./docs/IOS_KNOWLEDGE_COVERAGE_REGISTRY.json`
- `./scripts/validate_ios_knowledge_system.py`

## Modular Deep References
- `./docs/knowledge/global/ios/SWIFT_LANGUAGE_RUNTIME_AND_API_DESIGN.md`
- `./docs/knowledge/global/ios/SWIFT_CONCURRENCY_DEEP_REFERENCE.md`
- `./docs/knowledge/global/ios/SWIFTUI_UIKIT_AND_ADAPTIVE_IPAD_UI.md`
- `./docs/knowledge/global/ios/NETWORKING_WEB_AND_REALTIME_SYSTEMS.md`
- `./docs/knowledge/global/ios/IDENTITY_AUTHENTICATION_AND_APP_SECURITY.md`
- `./docs/knowledge/global/ios/PERSISTENCE_DATA_AND_CLOUDKIT.md`
- `./docs/knowledge/global/ios/TESTING_DEBUGGING_AND_DIAGNOSTICS.md`
- `./docs/knowledge/global/ios/XCODE_BUILD_BINARY_AND_SUPPLY_CHAIN.md`
- `./docs/knowledge/global/ios/APPLE_CAPABILITIES_AND_EXTENSIONS.md`
- `./docs/knowledge/global/ios/MEDIA_SENSORS_AND_DEVICE_INTEGRATIONS.md`
- `./docs/knowledge/global/ios/PERFORMANCE_OBSERVABILITY_AND_OPERATIONS.md`
- `./docs/knowledge/global/ios/APP_STORE_PRIVACY_AND_COMPLIANCE.md`

Load these through `./docs/TASK_TYPE_DOCUMENTATION_ROUTER.md`; do not read the complete set for every task.

## Legacy Coverage Backlog
The former monolithic senior/lead/staff handbook is retained only in the canonical documentation vault at `reusable/knowledge-global/ios/legacy/IOS_SENIOR_LEAD_ARCHITECT_STAFF_HANDBOOK_OUTLINE.md`. It is historical coverage-planning material, not an active routed authority and not part of the reusable baseline.

## Framework Entry Points
- `./docs/IOS_PRODUCTION_FRAMEWORK.md`
- `./docs/IOS_FEATURE_LIFECYCLE_PLAYBOOK.md`
- `./docs/IOS_PRODUCTION_AUDIT_MATRIX.md`
- `./docs/IOS_PR_REVIEW_TEMPLATE.md`
- `./docs/IOS_PROJECT_BOOTSTRAP_TEMPLATE.md`
- `./docs/IOS_AGENT_PROMPT_ROUTER.md`
- `./docs/IOS_PRODUCTION_EXCEPTION_POLICY.md`
- `./docs/IOS_PRODUCTION_SCORECARD.md`
- `./docs/IOS_DOCUMENTATION_MAINTENANCE_STANDARD.md`
- `./docs/IOS_CODE_DOCUMENTATION_STANDARD.md`
- `./scripts/validate_ios_production_framework.py`

## Recommended Standards To Route When Applicable
- `./docs/IOS_PRODUCTION_READINESS_STANDARD.md`
- `./docs/IOS_TESTING_STRATEGY.md`
- `./docs/IOS_SECURITY_PRIVACY_GATE.md`
- `./docs/IOS_OBSERVABILITY_STANDARD.md`
- `./docs/IOS_RELEASE_CHECKLIST.md`
- `./docs/IOS_ACCESSIBILITY_STANDARD.md`
- `./docs/IOS_PERFORMANCE_BUDGETS.md`
- `./docs/API_CONTRACT_AND_INTEGRATION_RULES.md`
- `./docs/IOS_DATA_MIGRATION_STANDARD.md`
- `./docs/DESIGN_SYSTEM_GOVERNANCE.md`
- `./docs/DEFINITION_OF_DONE.md`
- `./docs/CI_CD_QUALITY_GATES.md`
- `./docs/DEPENDENCY_POLICY.md`

## Additional Standards To Route When Applicable
- `./docs/PRODUCT_REQUIREMENTS_STANDARD.md`
- `./docs/ARCHITECTURE_DECISION_GOVERNANCE.md`
- `./docs/CODE_OWNERSHIP_AND_REVIEW_POLICY.md`
- `./docs/EVIDENCE_BASED_ENGINEERING_RULES.md`
- `./docs/STATIC_QUALITY_GATE_POLICY.md`
- `./docs/FEATURE_FLAGS_AND_ROLLOUTS.md`
- `./docs/INCIDENT_RESPONSE_STANDARD.md`
- `./docs/PRODUCT_HEALTH_SLO.md`
- `./docs/RISK_REGISTER.md`
- `./docs/TECH_DEBT_REGISTER.md`
- `./docs/MODULAR_ARCHITECTURE_STANDARD.md`
- `./docs/DEVELOPER_EXPERIENCE_STANDARD.md`
- `./docs/QA_TEST_PLAN_STANDARD.md`
- `./docs/LOCALIZATION_INTERNATIONALIZATION_STANDARD.md`
- `./docs/APPLE_PLATFORM_CAPABILITIES_STANDARD.md`
- `./docs/DATA_GOVERNANCE_AND_COMPLIANCE.md`
- `./docs/COMPATIBILITY_MATRIX.md`

## Additional Generic iOS Standards
- `./docs/IOS_CONCURRENCY_RUNTIME_STANDARD.md`
- `./docs/IOS_MEMORY_CACHE_MEDIA_STANDARD.md`
- `./docs/IOS_UI_STATE_RENDERING_STANDARD.md`
- `./docs/IOS_NETWORK_RESILIENCE_STANDARD.md`
- `./docs/IOS_OFFLINE_SYNC_STANDARD.md`
- `./docs/IOS_APP_LIFECYCLE_BACKGROUND_STANDARD.md`
- `./docs/IOS_ERROR_HANDLING_USER_FEEDBACK_STANDARD.md`
- `./docs/IOS_ANALYTICS_TELEMETRY_TAXONOMY.md`
- `./docs/IOS_CONFIGURATION_ENVIRONMENTS_STANDARD.md`
- `./docs/IOS_INPUT_VALIDATION_CONTENT_SAFETY_STANDARD.md`
- `./docs/IOS_STOREKIT_PAYMENTS_STANDARD.md`
- `./docs/IOS_CAMERA_PHOTOS_FILES_PERMISSIONS_STANDARD.md`

## Rule
Keep app-specific file paths, models, product names, and task constraints out of global iOS rules.

## Architecture Style Routing
- `./docs/IOS_ARCHITECTURE_STYLE_ROUTER.md` defines reusable architecture-style detection and review gates for MVVM, SwiftUI Native State, Clean/Layered, Coordinator, Modular, Hexagonal, TCA, Redux/Elm/UDF, ReactorKit, VIP/Clean Swift, VIPER, MVP, RIBs, and MVC migration.
- `./docs/agent-prompts/ios-architecture-style-review.md` is the matching prompt for architecture-style reviews.
