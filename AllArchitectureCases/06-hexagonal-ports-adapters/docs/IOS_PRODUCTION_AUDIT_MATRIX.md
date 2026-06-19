# iOS Production Audit Matrix

## Purpose
Uniform checklist for broad iOS audits. Use for whole-app, feature, PR, release, or incident-readiness review.

## Severity
- **P0**: crash/data loss/security breach/core flow blocked/severe performance failure.
- **P1**: architecture/runtime flaw likely to cause defects or costly rewrite.
- **P2**: incorrect pattern that should be fixed before expanding the affected area.
- **P3**: cleanup, consistency, docs, or maintainability issue.

## Required Finding Format
- Severity
- Affected files
- Evidence
- Why it matters
- Target state
- Remediation order
- Required verification
- Remaining risk

## Audit Domains
| Domain | Required Evidence |
|---|---|
| Product behavior | Acceptance criteria, non-goals, user states |
| UI/rendering | Lazy structure, stable identity, hot-path proof |
| Performance | Budget, profiler/manual proof for critical flows |
| Concurrency | Actor/cancellation/lifetime proof |
| Memory/media/cache | Bounded memory/cache/file behavior |
| Persistence | Source of truth, migration, relaunch durability |
| Network/API | Error taxonomy, retry/cancel/idempotency |
| Offline/sync | Pending/conflict/replay semantics |
| Security/privacy | Secrets, PII, logs, permissions, privacy manifest |
| Accessibility | VoiceOver, Dynamic Type, contrast, focus, controls |
| Localization | All visible strings, formatters, RTL/length expansion |
| Lifecycle/platform | Launch, background, scene, push, widgets/extensions |
| Observability | Crash/log/analytics/performance signals |
| Release/rollback | Signing, rollout, flags, rollback path |
| Ops/governance | Owner, risk, debt, docs, supportability |
