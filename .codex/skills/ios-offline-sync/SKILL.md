---
name: ios-offline-sync
description: Use this skill for iOS offline/sync reviews involving local mutations, pending operations, conflict resolution, idempotency, app groups, widgets, extensions, relaunch durability, and optimistic UI failure behavior. Trigger whenever offline, sync, pending operations, app group, widget data, extension data, conflict, or relaunch durability is mentioned.
---

# iOS Offline Sync

## Workflow
1. Identify source of truth and mutation ownership.
2. Separate local, pending, acknowledged, failed, and conflicted states.
3. Check idempotency, replay, dedupe, and crash/relaunch behavior.
4. Check app-group atomic writes, quarantine, cleanup, and extension/widget ownership.
5. Report remaining risks when manual/relaunch verification is needed.

## References
- `./docs/IOS_OFFLINE_SYNC_STANDARD.md`
- `./docs/IOS_DATA_MIGRATION_STANDARD.md`
