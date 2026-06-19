# iOS Offline And Sync Review Prompt

Use this for local mutations, pending operations, app-group files, widgets/extensions, sync conflicts, and relaunch durability.

## Prompt
Проведи production-grade iOS offline/sync review.

Проверь:
- source of truth;
- local mutation vs pending sync vs server acknowledgment;
- idempotency/dedupe;
- replay after crash/relaunch;
- conflict resolution;
- optimistic UI failure behavior;
- app-group atomic writes/quarantine/cleanup;
- widget/extension data ownership.

For every finding provide severity, affected files, evidence, target state, remediation order, and verification.
