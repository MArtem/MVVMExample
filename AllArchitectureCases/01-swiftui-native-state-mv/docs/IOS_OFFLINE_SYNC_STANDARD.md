# iOS Offline And Sync Standard

## Purpose
Keep app data correct across offline use, relaunch, multi-device sync, extensions, widgets, and partial failures.

## Required Rules
- Define source of truth per data type.
- Separate local mutation, pending sync operation, server acknowledgment, and conflict state.
- Every sync operation needs stable identity, idempotency key or equivalent dedupe strategy, retry policy, and failure state.
- Never hide unsynced data loss behind optimistic UI.
- Extension/widget/app-group data must define ownership, atomic writes, quarantine/corruption handling, and cleanup.
- Clock/order assumptions must be explicit.

## Review Checklist
- What happens if the app is killed mid-write?
- What happens if a pending operation is replayed twice?
- What wins in a conflict?
- Is the UI showing synced, pending, failed, or local-only state clearly when needed?
- Are app-group files atomic and recoverable?
