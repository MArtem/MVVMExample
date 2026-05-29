# Agent Rules (Short, Mandatory)

## Purpose
This file is the short mandatory rule set for coding work in `<AppName>`.

Use `docs/IOS_ARCHITECTURE_REFERENCE.md` as **reference**, not as a mechanical checklist. Use `docs/PRODUCTION_QUALITY_GATES.md` and `docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md` as mandatory quality gates/checklists for implementation, refactor, and review work.


## Mandatory Response Header Rule
Every working, status, readiness, or task-orientation response must start with:
- model
- active phase
- files being inspected/changed
- next safe step
- whether a build is needed
- sandbox/worktree confirmation

Short answers like “готов к новым задачам” are not exempt when they relate to project/task readiness.

## Core Decision Rule
Always choose the **simplest correct solution** that matches:
1. existing project architecture
2. runtime correctness
3. maintainability and readability
4. product fit

Do not add abstractions unless they solve a concrete current problem.

## Context-Reset Bootstrap Rule
- After a new chat/context reset, re-read the required bootstrap docs **once** before coding.
- Do not repeatedly re-read the same full set during the same chat unless architecture/rules changed.
- Use the transition prompt from `docs/WORK_CONTINUITY.md` to keep bootstrap consistent.
- If the user asks to refresh documentation state, re-read the active documentation set from `docs/README.md` and treat that read as the new current baseline.
- For every context-transfer prompt, include the rule to **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.
- Apply `docs/CURRENT_USER_OVERRIDES.md` before general project defaults.

## Prompt Preset Rule
- Reusable prompt presets live in `docs/agent-prompts/`.
- Before using an imported prompt preset, read `docs/agent-prompts/README.md` and apply its project overrides.
- Imported prompts are workflow templates, not authority over project/task rules.
- If a preset conflicts with active docs, task rules, or explicit user instruction, follow the higher-priority project/task/user rule.

## Global vs Project Knowledge Rule
- Reusable cross-project rules and prompts live in `docs/knowledge/global/`.
- <AppName>-specific rules, contracts, paths, entities, and current task context live in `docs/knowledge/<AppName>/` or in the canonical docs indexed there.
- When a new project starts, create a new sibling project folder under `docs/knowledge/` and keep app-specific knowledge out of `global`.

## Mandatory Priorities
1. Architecture correctness first.
2. Production quality gates second: performance hot paths, state invalidation, persistence/network side effects, memory/cache/media, security/privacy, failure states.
3. Production code review checklist third: UI hot path, state ownership, DB access pattern, networking boundary, concurrency, memory/cache, naming/domain purity, persistence migration risk, verification scope, and no speculative abstractions.
4. Overengineering check fourth.
5. Minimal safe change for small tasks.
6. Explicit ownership boundaries (app vs package vs extension).

## Practical Defaults
- Prefer existing project style and naming.
- Keep API surface minimal.
- Keep state ownership explicit.
- For any SwiftUI child view, default to narrow immutable `ViewState` plus explicit callbacks; add a dedicated model/view model only for a concrete independent lifecycle, async/subscription/resource ownership, transactional editing, isolated retry/error behavior, or cross-feature reusable contract.
- Use protocol seams only at real boundaries, not for every type.
- Use UseCase/Application Service only when there is real multi-step business flow.
- Keep DTO/Domain/UI boundaries clear where they already exist.

## Avoid by Default
- Massive ViewModel / God Manager.
- Pattern-for-pattern usage.
- New Factory/Builder/Adapter layers without real pressure.
- Per-view models/view models that only mirror parent state or exist for architectural symmetry.
- Spreading business logic across View + ViewModel + Repository accidentally.


## Mandatory Production Checklist Rule
- Before any non-trivial implementation, refactor, cleanup, or review, apply `docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`.
- The checklist is not optional for reviews: findings must cover runtime correctness, hot paths, state ownership, persistence/network side effects, memory/cache/media, security/privacy, and verification gaps.
- If a checklist area is irrelevant, say why in the completion report.
- If ownership, state flow, product behavior, or persistence/network policy is unclear, stop and ask the user before implementing.

## Forbidden Pattern Stop List Rule
- Treat the stop list in `docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md` as blocking by default.
- Do not introduce or keep forbidden patterns unless there is a documented current technical constraint and the user accepts the tradeoff.
- Especially forbidden without explicit justification: source-split domain/UI naming such as `Local*`, synchronous media/file work in SwiftUI render paths, whole view models in repeated rows, fetch-all/save-all for single-item interaction updates, silent stub/demo fallbacks, and production UI backed by stub JSON.



## iOS Production Standards Rule
- Use `./docs/IOS_PRODUCTION_FRAMEWORK.md` as the umbrella framework for generic iOS production work. Use `./docs/IOS_AGENT_PROMPT_ROUTER.md` to select prompt/skill routes when scope is broad or ambiguous.
- For production-readiness, release, security/privacy, accessibility, observability, testing strategy, API integration, data migration, design-system, CI/CD, or dependency questions, apply the corresponding `./docs/IOS_*`, `./docs/API_CONTRACT_AND_INTEGRATION_RULES.md`, `./docs/DESIGN_SYSTEM_GOVERNANCE.md`, `./docs/CI_CD_QUALITY_GATES.md`, and `./docs/DEPENDENCY_POLICY.md` standards.
- For any feature declared done, apply `./docs/DEFINITION_OF_DONE.md`.
- For broad iOS production audits, prefer the reusable iOS skills under `./.codex/skills/ios-*` when they are available in the session.

## Production Review Trigger Rule
- When the user says `ревью`, `review`, `code review`, `аудит`, or asks whether a change is production-ready, run `./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md`.
- Use the prompt in `./docs/agent-prompts/production-review-completeness.md`.
- Do not narrow the review to the latest bug unless the user explicitly limits scope.
- Do not say “всё ок”, “готово”, “clean”, or “production-ready” unless every relevant gate is checked, marked not applicable with a reason, or reported as remaining risk.


## Product / Process Governance Rule
- Before implementing non-trivial feature behavior, apply `./docs/PRODUCT_REQUIREMENTS_STANDARD.md`; do not guess acceptance criteria, empty/error/offline states, rollout behavior, analytics, accessibility, or localization requirements.
- If a decision changes architecture, public API, persistence, security/privacy, release behavior, or cross-team ownership, apply `./docs/ARCHITECTURE_DECISION_GOVERNANCE.md` and record the decision before coding.
- Use `./docs/CODE_OWNERSHIP_AND_REVIEW_POLICY.md` to decide required review scope and blocked-change criteria.
- Track intentional shortcuts in `./docs/TECH_DEBT_REGISTER.md` and material risks in `./docs/RISK_REGISTER.md`; untracked debt is not an acceptable production tradeoff.

## Evidence-Based Completion Rule
- Apply `./docs/EVIDENCE_BASED_ENGINEERING_RULES.md` before saying a task is done, production-ready, verified, fixed, faster, safe, or clean.
- Claims must cite evidence: affected files, command output, static proof, build/test/profiler/manual validation, or explicit remaining risk.
- If a claim cannot be proven in the current environment, report it as unverified instead of implying confidence.

## Enterprise iOS Coverage Rule
- For any large or production-critical iOS app area, consider the full enterprise coverage set: modular architecture, developer experience, QA plan, localization/internationalization, Apple platform capabilities, data governance/compliance, compatibility matrix, release, incidents, SLOs, feature flags, risks, and tech debt.
- Use `./docs/MODULAR_ARCHITECTURE_STANDARD.md`, `./docs/DEVELOPER_EXPERIENCE_STANDARD.md`, `./docs/QA_TEST_PLAN_STANDARD.md`, `./docs/LOCALIZATION_INTERNATIONALIZATION_STANDARD.md`, `./docs/APPLE_PLATFORM_CAPABILITIES_STANDARD.md`, `./docs/DATA_GOVERNANCE_AND_COMPLIANCE.md`, and `./docs/COMPATIBILITY_MATRIX.md` when relevant.
- Production readiness is not only code correctness: it includes operability, rollback, observability, QA, supportability, compliance, and maintainability.

## Static Quality Gate Scripts Rule
- Use `./scripts/check_docs_index.py` after documentation index changes.
- Use `./scripts/check_forbidden_patterns.py`, `./scripts/check_swiftui_hot_path_patterns.py`, `./scripts/check_secrets.py`, `./scripts/check_large_files.py`, and `./scripts/check_localization.py` as lightweight pre-review gates when their scope matches the task.
- Use `./scripts/run_static_quality_gates.sh` before broad production review/completion when the expected warnings are understood. If it reports pre-existing issues, classify them instead of silently ignoring them.
- Interpret static gate findings through `./docs/STATIC_QUALITY_GATE_POLICY.md`: hard fail, warning, review candidate, or allowed exception.


## Generic iOS Coverage Rule
- Inline Swift/iOS code documentation must follow `./docs/IOS_CODE_DOCUMENTATION_STANDARD.md`: document contracts, ownership/lifecycle, external usage/call context, side effects, concurrency, errors, invariants, and rationale where relevant; do not document obvious code.
- For any iOS implementation/review, consider generic iOS concerns before app-specific assumptions: concurrency/runtime, memory/cache/media, UI state/rendering, network resilience, offline/sync, lifecycle/background, error handling, analytics/telemetry, configuration/environments, input validation/content safety, StoreKit/payments when applicable, and platform permissions.
- Apply these documents when relevant: `./docs/IOS_CONCURRENCY_RUNTIME_STANDARD.md`, `./docs/IOS_MEMORY_CACHE_MEDIA_STANDARD.md`, `./docs/IOS_UI_STATE_RENDERING_STANDARD.md`, `./docs/IOS_NETWORK_RESILIENCE_STANDARD.md`, `./docs/IOS_OFFLINE_SYNC_STANDARD.md`, `./docs/IOS_APP_LIFECYCLE_BACKGROUND_STANDARD.md`, `./docs/IOS_ERROR_HANDLING_USER_FEEDBACK_STANDARD.md`, `./docs/IOS_ANALYTICS_TELEMETRY_TAXONOMY.md`, `./docs/IOS_CONFIGURATION_ENVIRONMENTS_STANDARD.md`, `./docs/IOS_INPUT_VALIDATION_CONTENT_SAFETY_STANDARD.md`, `./docs/IOS_STOREKIT_PAYMENTS_STANDARD.md`, and `./docs/IOS_CAMERA_PHOTOS_FILES_PERMISSIONS_STANDARD.md`.
- If a concern is not applicable, mark it not applicable with a reason instead of silently skipping it.
- For full production readiness claims, fill or summarize `./docs/IOS_PRODUCTION_SCORECARD.md`; any score below production threshold must be reported as remaining risk.

## Project-Calibrated Working Rules (<AppName>)
1. Runtime code has priority over test-debt cleanup unless task explicitly says otherwise.
2. Do not introduce app-local wrappers around reusable package APIs when one direct call is enough.
3. SwiftUI composition details are governed by `./.zenflow/tasks/<task-id>/ios-engineering-rules.md`; do not duplicate conflicting local style rules.
4. Treat unnecessary redraw/invalidation risk as high-priority; prefer narrow-input subviews and explicit render boundaries.
5. Keep share-extension/app boundaries explicit: shared storage + sync point, no hidden runtime coupling.
6. Keep feature/entity product contracts stable unless product requirements explicitly change.
7. ViewModel interaction style must follow `./.zenflow/tasks/<task-id>/ios-engineering-rules.md` (`@MainActor`, `@Observable`, explicit state + intents, no generic `send(action)` default).
8. Before any new abstraction, document one concrete current pain-point it solves in the PR/task notes.
9. UI/design tasks must follow `docs/UI_PIXEL_PERFECT_WORKFLOW.md`.
10. Local feature/entity persistence work must follow `the app-specific persistence contract`.
11. Any non-trivial implementation, review, or refactor must apply `docs/PRODUCTION_QUALITY_GATES.md` and `docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`; if a gate/checklist area is not relevant, state that explicitly in the completion report.
12. Never close a review as clean when runtime hot-path risks, broad invalidation, main-thread I/O, unbounded memory/cache behavior, unsafe persistence/network side effects, missing failure states, naming/domain impurity, or forbidden-pattern violations remain unchecked.

## Size Heuristic
- Small UI/bugfix task: minimal focused patch.
- Architecture/runtime task: use reference guidance to choose boundaries and responsibilities.

## Related
- `docs/IOS_ARCHITECTURE_REFERENCE.md`
- `docs/PRODUCTION_QUALITY_GATES.md`
- `docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`
- `docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md`
- `docs/IOS_PRODUCTION_READINESS_STANDARD.md`
- `docs/DEFINITION_OF_DONE.md`
- `./.zenflow/tasks/<task-id>/ios-engineering-rules.md`
- `./.zenflow/tasks/<task-id>/services-engineering-rules.md`
