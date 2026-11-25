---
name: ios-offline-sync
description: "Use this skill for durable offline mutation and synchronization: outbox/replay, pending operations, conflicts, idempotency across relaunch, app-group/widget/extension data, and optimistic failure recovery. Trigger when durable local state or reconciliation is in scope; a generic offline error state does not activate this route alone."
---

# iOS Offline Sync

## Workflow
1. Identify source of truth and mutation ownership.
2. Separate local, pending, acknowledged, failed, and conflicted states.
3. Check idempotency, replay, dedupe, and crash/relaunch behavior.
4. Check app-group atomic writes, quarantine, cleanup, and extension/widget ownership.
5. Report remaining risks when manual/relaunch verification is needed.

## References
Resolve `DOC:` identifiers through the active task router in canonical
`reusable/baseline/docs/` or the project-root `docs/` mirror, not relative to this skill.
- `DOC:IOS_OFFLINE_SYNC_STANDARD.md`
- `DOC:IOS_DATA_MIGRATION_STANDARD.md`
