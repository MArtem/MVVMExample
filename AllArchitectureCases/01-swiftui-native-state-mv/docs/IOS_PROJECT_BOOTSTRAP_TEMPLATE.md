# iOS Project Bootstrap Template

## Purpose
How to install this reusable iOS production framework into a new project.

## Required Project Decisions
Before coding, define:
- app purpose and critical user journeys
- supported iOS versions/devices
- architecture style and module boundaries
- environment model: dev/staging/prod
- persistence/source-of-truth model
- API/backend contract ownership
- observability/crash/analytics tools
- security/privacy classification
- release/signing/TestFlight process
- QA/manual validation process
- risk/debt ownership

## Minimum Files To Copy
- `./docs/IOS_PRODUCTION_FRAMEWORK.md`
- `./docs/IOS_FEATURE_LIFECYCLE_PLAYBOOK.md`
- `./docs/IOS_PRODUCTION_AUDIT_MATRIX.md`
- `./docs/IOS_PR_REVIEW_TEMPLATE.md`
- all standards referenced by `./docs/IOS_PRODUCTION_FRAMEWORK.md`
- relevant prompts under `./docs/agent-prompts/`
- relevant skills under `./.codex/skills/ios-*`
- static scripts under `./scripts/`

## Project-Specific Layer
Create a project-specific docs area for:
- product contracts
- app architecture
- API endpoints
- persistence schemas
- feature flags
- localization/design tokens
- release runbooks
- known risks/debt

Do not put project-specific facts into the generic global framework.
