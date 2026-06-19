# Feature Flags And Rollouts

## Purpose
Rules for safe staged delivery, remote config, experiments, and rollback.

## Required Checks
- Safe default value when offline/unconfigured.
- Kill switch for high-risk features.
- Staged rollout plan.
- Experiment assignment and analytics integrity.
- Fallback behavior when backend/config fails.
- Flag cleanup/removal plan.
- Owner and expiry date for every flag.

## Forbidden By Default
- Permanent stale flags.
- Feature behavior depending on remote config without local safe default.
- Experiment changing persistence schema without migration/rollback plan.
