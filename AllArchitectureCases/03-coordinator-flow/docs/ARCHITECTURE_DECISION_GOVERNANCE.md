# Architecture Decision Governance

## Purpose
Defines when architectural decisions need an ADR/RFC and how they are reviewed.

## ADR Required When
- introducing a new module/package/layer
- changing persistence/backend/sync architecture
- adding a new critical dependency
- changing navigation/session/auth ownership
- introducing feature flags/rollout infrastructure
- making irreversible migration/release decisions

## ADR Template
- Context
- Problem
- Options considered
- Decision
- Consequences
- Migration plan
- Rollback plan
- Review/revisit trigger
- Owner

## Stop Rule
Do not implement broad architecture changes without recording the decision or explicitly documenting why ADR is not needed.
