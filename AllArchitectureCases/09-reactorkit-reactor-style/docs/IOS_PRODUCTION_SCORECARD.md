# iOS Production Scorecard

## Purpose
Quantify readiness without pretending uncertainty is confidence.

## Scoring
Each area is rated:
- **0**: not checked
- **1**: known gaps
- **2**: partially covered, risks remain
- **3**: covered with evidence
- **N/A**: not applicable with reason

## Areas
- Product requirements
- Architecture ownership
- UI/rendering performance
- Concurrency/runtime
- Memory/cache/media
- Persistence/migration
- Network/API/offline/sync
- Security/privacy/data governance
- Accessibility
- Localization
- Lifecycle/platform capabilities
- Error handling
- Observability
- Testing/QA
- CI/static gates
- Release/rollout/rollback
- Incidents/SLO/supportability
- Documentation/risk/debt

## Production-Ready Threshold
No area may be `0`. Any `1` in a critical user journey blocks production-ready status. Any `2` requires explicit remaining-risk statement and owner.
