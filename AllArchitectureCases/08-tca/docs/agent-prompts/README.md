# Agent Prompt Presets

## Purpose
This directory contains prompt presets imported from the task attachment archive `890c0139-75d6-44f5-bf78-f9d21ce92def.zip`.

Use these prompts as **task-specific operating templates**, not as rules that override the project documentation.
They extend the active documentation set with reusable workflows for feature generation, SwiftUI-from-design work, refactoring, code review, ADRs, tests, CI/debugging, compile errors, signing, and flaky tests.

## Mandatory Project Overrides
Before applying any prompt here, apply the current project/task rules first:

1. Read the active docs/rules from `../README.md` when bootstrapping or when documentation state is refreshed.
2. For this worktree/task, apply `./docs/MODEL_ROUTING_RULE.md`; do not use the old GPT-5.5-for-all rule.
3. Do not add speculative UI, logic, tests, layers, protocols, UseCases, factories, or adapters.
4. Tests are not written or run by default. Use test prompts only when the user explicitly asks for tests, test review, flaky-test diagnosis, or when a separately justified verification strategy requires it.
5. Repository protocols, ViewState, and extra layers are allowed only when they protect a real boundary or solve a concrete current problem. UI action enums / `send(_ action:)` dispatch are not default MVVM boilerplate; use explicit ViewModel intent methods unless reducer/state-machine architecture is explicitly approved and documented.
6. SwiftUI design work from screenshots/Figma/PDF/CSS uses `GPT-5.5` unless the user explicitly relaxes that requirement, and must stay pixel-focused.
7. Verification commands follow `../../TESTING_INSTRUCTIONS.md`; do not run builds/tests unless the user asks or the current agreed verification policy allows it.
8. Preserve `MVVMExample` conventions, design tokens, localization, SwiftData-first persistence, and feed/composer card contract.

## Prompt Selection Index

| Case | Use prompt | Notes |
|---|---|---|
| New production feature | `feature-generation-master.md` | Use only when the user asks for a full feature and scope is broad enough. Adapt to project rules; do not generate tests unless asked. |
| Small concrete feature | `feature-specific-quick.md` | Use for narrower feature work; keep implementation minimal. |
| SwiftUI screen from Figma/PNG/PDF/SVG/CSS | `swiftui-design-generation-master.md` | Use for design-driven UI. Must use `GPT-5.5`; ask questions if measurements/behavior are unclear. |
| Quick SwiftUI design task | `swiftui-design-generation-quick.md` | Use for smaller pixel-focused design fixes. |
| Refactoring | `refactoring-master.md` | Use for broad refactor requests. Prefer small PR-sized changes. |
| Quick refactoring | `refactoring-quick.md` | Use for local code-quality cleanup. |
| Refactor plan only | `refactoring-plan-only-mini.md` | Use when the user asks for a plan before code. |
| Review refactor after changes | `refactoring-review-mini.md` | Use after a refactor to check behavior preservation and risk. |
| Code review | `code-review-master.md` | Use for strict production review. Do not use costly review flows unless requested. |
| Production completeness review | `production-review-completeness.md` | Mandatory when the user says `ревью`, `review`, `аудит`, or asks whether code is production-ready. |
| iOS production readiness review | `ios-production-readiness-review.md` | Use before claiming broad production readiness. |
| iOS performance audit | `ios-performance-audit.md` | Use for scroll, launch, memory, Instruments, and hot-path work. |
| iOS security/privacy review | `ios-security-privacy-review.md` | Use for Keychain, PII, logs, privacy manifests, permissions, app groups. |
| iOS accessibility review | `ios-accessibility-review.md` | Use for VoiceOver, Dynamic Type, contrast, focus, tap targets. |
| iOS data migration review | `ios-data-migration-review.md` | Use for SwiftData/CoreData/UserDefaults/files/app-group compatibility. |
| iOS API contract review | `ios-api-contract-review.md` | Use for DTOs, errors, retry, pagination, offline, sync, auth. |
| iOS release readiness | `ios-release-readiness.md` | Use for TestFlight/App Store/signing/release checks. |
| iOS feature definition of done | `ios-feature-definition-of-done.md` | Use before calling a feature done. |
| iOS code documentation review | `ios-code-documentation-review.md` | Use for inline Swift documentation comments, ownership, external usage/call context, side effects, invariants, and workaround comments. |
| Product requirements review | `product-requirements-review.md` | Use before non-trivial feature work when behavior/states/acceptance criteria must be proven. |
| Architecture decision review | `architecture-decision-review.md` | Use when a change affects module boundaries, persistence, public API, security/privacy, or long-lived architecture. |
| Evidence-based completion review | `evidence-based-completion-review.md` | Use before claiming done/fixed/verified/production-ready. |
| Feature flag / rollout review | `feature-flag-rollout-review.md` | Use for staged rollout, kill switch, rollback, or remote config changes. |
| Incident response review | `incident-response-review.md` | Use for production incident readiness, triage, mitigation, and postmortem planning. |
| QA test plan review | `qa-test-plan-review.md` | Use when preparing manual/automated QA coverage for a feature or release. |
| Localization review | `localization-review.md` | Use for user-visible strings, pluralization, locale formatting, RTL, or length expansion. |
| Platform capability review | `platform-capability-review.md` | Use for entitlements, app groups, extensions, widgets, deep links, background modes, permissions. |
| iOS concurrency/runtime review | `ios-concurrency-review.md` | Use for async/await, actors, task lifecycle, Sendable, cancellation, and Swift 6 readiness. |
| iOS memory/cache/media review | `ios-memory-cache-media-review.md` | Use for media, files, caches, memory pressure, thumbnails, and scroll media performance. |
| iOS UI state/rendering review | `ios-ui-state-rendering-review.md` | Use for SwiftUI/UIKit state invalidation, lazy structure, rows, animations, and layout stability. |
| iOS network resilience review | `ios-network-resilience-review.md` | Use for retries, timeouts, cancellation, idempotency, pagination, uploads/downloads. |
| iOS offline/sync review | `ios-offline-sync-review.md` | Use for local mutations, pending sync, app groups, extensions/widgets, conflicts, and relaunch durability. |
| iOS lifecycle/background review | `ios-lifecycle-background-review.md` | Use for launch, scene, background tasks, notifications, deep links, widgets, and extensions. |
| iOS error-handling review | `ios-error-handling-review.md` | Use for failure states, retry, optimistic UI, localized errors, and supportability. |
| iOS configuration/environments review | `ios-configuration-environments-review.md` | Use for dev/staging/prod config, secrets, debug gating, flags, analytics/crash routing. |
| iOS input-validation/content-safety review | `ios-input-validation-content-safety-review.md` | Use for imports, files, URLs, rich text, push payloads, and untrusted content. |
| ADR | `adr-master.md` | Use for important architecture decisions. |
| Quick ADR | `adr-quick.md` | Use for lightweight architecture decision notes. |
| Test generation | `test-generation-master.md` | Use only when tests are explicitly requested. |
| Quick test generation | `test-generation-quick.md` | Use only when tests are explicitly requested. |
| Review generated tests | `test-review-mini.md` | Use when reviewing test quality. |
| CI/debug logs | `ci-debug-master.md` | Use for broad build/test/CI/signing/runtime failure investigation. |
| Quick CI/debug logs | `ci-debug-quick.md` | Use for smaller log triage. |
| CI failure | `ci-failure-mini.md` | Use for concise CI root-cause analysis. |
| Swift compile error | `swift-compile-error-mini.md` | Use for compiler errors; find first meaningful error and ignore cascades. |
| Signing/TestFlight | `signing-testflight-mini.md` | Use for signing/archive/TestFlight/App Store Connect issues. |
| Flaky tests | `flaky-tests-mini.md` | Use for flaky test diagnosis only. |

## Conflict Notes Found During Import

- Several prompts recommend generating tests as part of feature work. In this project, tests remain opt-in unless the user explicitly asks.
- Several prompts mention repository protocols and Action enums as defaults. In this project, repository protocols are allowed only at real seams, and UI action enums / `send(_ action:)` dispatch are not default MVVM boilerplate. Use explicit ViewModel intent methods unless reducer/state-machine architecture is explicitly approved and documented.
- Apply the active `./docs/MODEL_ROUTING_RULE.md`; GPT-5.4 is allowed only for approved low-risk execution, while GPT-5.5 remains required for planning/high-risk work.
- The prompts are generic iOS production templates. Existing `MVVMExample` architecture, task rules, feed/composer contract, localization, design tokens, and verification policy are higher priority.
- Evidence-based completion prompt is mandatory before claiming work is done when verification is non-trivial.
