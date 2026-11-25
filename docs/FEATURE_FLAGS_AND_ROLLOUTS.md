# Feature Flags And Rollouts

## Purpose
Rules for safe staged delivery, remote config, experiments, and rollback.

Feature flags are conditional, not mandatory infrastructure for every app or change. Each project
profile or adoption record must classify them as `APPLICABLE`, `NOT_APPLICABLE`, or `DEFERRED` with
owner, rationale, and revisit condition. Silence or missing flag infrastructure is not proof that a
release has rollback safety.

Use a flag or kill switch when a feature has material runtime, migration, backend, privacy,
performance, or staged-adoption risk that can be safely isolated. Do not add a flag when it would
create more state combinations than risk reduction, cannot prevent the irreversible operation, or
would conceal a required migration/release decision.

## Required Checks
- Typed configuration keys and value validation, with explicit cache/TTL and expiry behavior.
- Safe default value when offline/unconfigured.
- Kill switch for high-risk features.
- Staged rollout plan.
- Experiment assignment and analytics integrity.
- Fallback behavior when backend/config fails.
- Flag cleanup/removal plan.
- Owner and expiry date for every flag.
- Explicit behavior for stale/malformed configuration and assignment changes during a session.
- Observability, stop thresholds, and named authority for pause/disable/rollback decisions.
- Verification of both enabled and disabled paths when the selected quality mode and permissions
  cover them; otherwise record the unverified path as residual risk.

## Forbidden By Default
- Permanent stale flags.
- Feature behavior depending on remote config without local safe default.
- Experiment changing persistence schema without migration/rollback plan.
- A flag represented as rollback for data loss, irreversible migration, server-side mutation, or
  another effect it cannot actually undo.
- Automatic rollout or flag mutation by the agent without explicit user authority.

## Release Evidence

For an applicable flag, release evidence records the exact source SHA, flag/config identity, safe
default, owner/expiry, enabled and disabled behavior checked, rollout stages, pause/rollback trigger,
and remaining risk. Missing or unavailable flag evidence is non-PASS for a release that depends on
that flag; a correctly validated `NOT_APPLICABLE` classification is not a skipped check.
