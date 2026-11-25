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
- Status: proposed, accepted, or superseded, with decision owner and acceptance evidence.
- Context
- Problem
- Options considered
- Decision
- Consequences
- Migration plan
- Rollback plan
- Review/revisit trigger
- Owner

A proposed ADR does not authorize implementation. An accepted status must reference the actual
scoped decision; a superseded record identifies its replacement and preserves prior rationale.

## Bounded Investigation And Migration
Recommend a spike only for a concrete uncertainty: name the question, stop condition and evidence
budget. Compare viable alternatives when ownership, compatibility, reversibility or evidence
cost differs materially; do not invent an alternative, document or flag to fill a template.

An explicitly authorized modernization needs a real benefit and success metric: characterize,
migrate one bounded slice, compare, then expand or stop. Review dual-state/dual-write hazards,
old/new compatibility and consumer cleanup criteria. Characterize existing observable behavior
from source and permitted evidence. Require only compatibility seams needed by actual consumers,
with rollout/rollback and an explicit old-path retirement criterion; do not introduce adapters or
shims merely to reproduce a historical checklist. A minimum-OS change also needs supported-user/
device impact, availability-shim inventory and release communication ownership. These decisions
do not authorize framework/language-mode/deployment changes; apply the relevant specialist route
and current app-owned permission before implementation.

## Stop Rule
Do not implement broad architecture changes without recording the decision or explicitly documenting why ADR is not needed.
