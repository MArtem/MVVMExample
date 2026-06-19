# iOS Agent Prompt Router

## Purpose
Route work to the correct prompt/skill so reviews are not accidentally narrow.

## Routing Rules
- Feature request → `./docs/agent-prompts/product-requirements-review.md` then relevant domain prompts.
- UI/scroll/performance → `./docs/agent-prompts/ios-ui-state-rendering-review.md` and `./docs/agent-prompts/ios-performance-audit.md`.
- Async/tasks/main-thread → `./docs/agent-prompts/ios-concurrency-review.md`.
- Media/files/cache → `./docs/agent-prompts/ios-memory-cache-media-review.md`.
- API/network → `./docs/agent-prompts/ios-network-resilience-review.md` and `./docs/agent-prompts/ios-api-contract-review.md`.
- Offline/sync/extensions/widgets → `./docs/agent-prompts/ios-offline-sync-review.md` and `./docs/agent-prompts/ios-lifecycle-background-review.md`.
- Security/privacy/permissions → `./docs/agent-prompts/ios-security-privacy-review.md` and `./docs/agent-prompts/ios-input-validation-content-safety-review.md`.
- Accessibility → `./docs/agent-prompts/ios-accessibility-review.md`.
- Localization → `./docs/agent-prompts/localization-review.md`.
- Release/rollout → `./docs/agent-prompts/ios-release-readiness.md` and `./docs/agent-prompts/feature-flag-rollout-review.md`.
- Done/verified/production-ready claim → `./docs/agent-prompts/evidence-based-completion-review.md`.

## Stop Rule
If no route clearly fits, run `./docs/agent-prompts/ios-production-readiness-review.md` and list uncertain domains explicitly.
