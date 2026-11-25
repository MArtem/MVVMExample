# iOS Offline And Sync Standard

## Purpose
Keep app data correct across offline use, relaunch, multi-device sync, extensions, widgets, and partial failures.

## Required Rules
- Define source of truth per data type.
- UI reads from the local source of truth first for offline-capable data; network/backend is synchronized through repositories/sync engines, not treated as the direct render source.
- Separate local mutation, pending sync operation, server acknowledgment, and conflict state.
- Every sync operation needs stable identity, idempotency key or equivalent dedupe strategy, retry policy, and failure state.
- Never hide unsynced data loss behind optimistic UI.
- Do not model sync as a single boolean such as `isSynced` when create/update/delete order, retry, or failure explanation matters.
- Use an outbox/pending-operation model for durable mutations that must survive relaunch, process death, duplicate replay, and partial backend failure.
- Deletes that must sync remotely need tombstones or explicit pending-deletion operations; do not physically remove the only local record before the delete is durably recorded.
- Conflict strategy must be explicit per entity/field: last-write-wins, server-wins, client-wins, field-level merge, or user-mediated resolution.
- Extension/widget/app-group data must define ownership, atomic writes, quarantine/corruption handling, and cleanup.
- Clock/order assumptions must be explicit.
- Network reachability is only a hint to try sync; it is not proof that the backend is reachable or that a mutation succeeded.

## Review Checklist
- What happens if the app is killed mid-write?
- What happens if a pending operation is replayed twice?
- What happens if a delete is requested offline, then the app relaunches before sync?
- What happens if push succeeds but pull fails, or pull succeeds but local apply fails?
- What wins in a conflict?
- Is the UI showing synced, pending, failed, or local-only state clearly when needed?
- Are app-group files atomic and recoverable?
