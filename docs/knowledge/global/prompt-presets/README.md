# Agent Prompt Presets

## Purpose
This directory contains prompt presets imported from the task attachment archive `890c0139-75d6-44f5-bf78-f9d21ce92def.zip`.

Use these prompts as **task-specific operating templates**, not as rules that override the project documentation.
They extend the active documentation set with reusable workflows for feature generation, SwiftUI-from-design work, refactoring, code review, ADRs, tests, CI/debugging, compile errors, signing, and flaky tests.

## Mandatory Project Overrides
Before applying any prompt here, apply the current project/task rules first:

1. Read the active docs/rules from `../README.md` when bootstrapping or when documentation state is refreshed.
2. For this worktree/task, use `GPT-5.5` unless the user explicitly changes the model again.
3. Do not add speculative UI, logic, tests, layers, protocols, UseCases, factories, or adapters.
4. Tests are not written or run by default. Use test prompts only when the user explicitly asks for tests, test review, flaky-test diagnosis, or when a separately justified verification strategy requires it.
5. Repository protocols, ViewState, and extra layers are allowed only when they protect a real boundary or solve a concrete current problem. UI action enums / `send(_ action:)` dispatch are not default MVVM boilerplate; use explicit ViewModel intent methods unless reducer/state-machine architecture is explicitly approved and documented.
6. SwiftUI design work from screenshots/Figma/PDF/CSS uses `GPT-5.5` and must stay pixel-focused.
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
- The imported model-routing material said to use the cheapest reliable model. Current task override is stricter: use `GPT-5.5` until the user explicitly changes it.
- The prompts are generic iOS production templates. Existing `MVVMExample` architecture, task rules, feed/composer contract, localization, design tokens, and verification policy are higher priority.
