# Agent Rules (Short, Mandatory)

## Purpose
Mandatory guardrails for non-trivial implementation, refactor, review, planning, or documentation work. Detailed standards are loaded through `./docs/TASK_TYPE_DOCUMENTATION_ROUTER.md`.

## Core Decision Rule
Choose the simplest correct solution that preserves existing architecture, runtime correctness, product behavior, maintainability, and verification confidence.

Simplicity does not permit skipping required structure, composition, navigation/state ownership, persistence safety, security/privacy, accessibility, localization, error states, performance work, or evidence.

## Before Work
- Apply `./docs/MODEL_ROUTING_RULE.md` and report the selected route.
- Apply `./docs/AGENT_PREFLIGHT_CHECKLIST.md` for non-trivial work.
- Read `./PROJECT_DOCUMENTATION.md` and `./PROJECT_HEALTH.md` when touching code, architecture, packages, persistence, navigation, state, or runtime ownership.
- Stop and ask when product behavior, ownership, state flow, persistence, privacy, navigation, or acceptance criteria are unclear.

## Implementation Guardrails
- Implement only approved behavior; no speculative UI or business logic.
- Do not add wrappers, protocols, factories, adapters, use cases, managers, or extra layers without a concrete current boundary problem.
- Keep API surface minimal and ownership explicit.
- ViewModels expose explicit intent methods by default; generic action dispatch requires explicit approval and rationale.
- Views render state and forward intents. They do not construct repositories/services or perform synchronous file, media, database, or network work in render paths.
- Routes carry stable identifiers or values, not views, ViewModels, DTOs, or persistence records.
- Reusable packages own app-neutral mechanisms; app/feature layers own product policy, composition, routing, DTO/domain mapping, persistence choices, and user-facing behavior.

## Quality Gates
- Implementation/refactor: apply `./docs/PRODUCTION_QUALITY_GATES.md` and `./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md` plus relevant routed standards.
- Review/audit/production-readiness: apply `./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md` and routed evidence/readiness standards.
- High-risk areas always route to their specialized standards: security/privacy, persistence/migration/data loss, concurrency, navigation/state ownership, SwiftUI performance, networking/offline/sync, memory/media/files, accessibility/localization, and release.
- Treat forbidden hot-path, data-loss, privacy, silent-fallback, unbounded-cache, missing-failure-state, and ownership violations as blocking until fixed, explicitly accepted, or reported as remaining risk.
- A passing static script is supporting evidence, not proof of production readiness.

## Documentation And Boundaries
- Apply `./docs/DOCUMENT_CHANGE_GOVERNANCE_STANDARD.md` before adding, materially restructuring, splitting, merging, superseding, archiving, or removing rules, docs, prompts, skills, templates, registries, validators, or package docs.
- Apply `./docs/DOCUMENT_BOUNDARY_STANDARD.md` and `./docs/SOURCE_OF_TRUTH_MAP.md` before moving or promoting docs, rules, prompts, skills, templates, package docs, or app/task knowledge.
- Reusable docs stay app-neutral. App decisions and local exceptions stay in the matching app/task boundary unless the user explicitly approves promotion and app-neutral rewriting.
- Apply `./docs/TASK_STATE_DOCUMENTATION_STANDARD.md` before changing task plan/handoff/archive/recovery docs.
- Every new active document must be indexed and classified through `./docs/DOCUMENT_ROUTING_REGISTRY.json` before completion.

## Verification And Completion
- Respect current build/test/simulator permissions from `./docs/CURRENT_USER_OVERRIDES.md` and task docs.
- Apply `./docs/COMPLETION_REPORT_CONTRACT.md` and `./docs/EVIDENCE_BASED_ENGINEERING_RULES.md` before meaningful completion claims.
- Report files changed, checks run/not run, remaining risks, intentional non-goals, model result, docs route, and context health.
- Do not hide pre-existing failures; classify them as blocking, pre-existing, or out of scope.

## Context Transfer
- Recommend a new chat proactively when context size, phase change, stale rules, or accumulated history threatens reliability.
- Apply `./docs/WORK_CONTINUITY.md` and `./docs/CONTEXT_TRANSFER_AND_NEW_CHAT_STANDARD.md` for handoff work.
- Include: **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**.
