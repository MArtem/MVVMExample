# Project Health

## Purpose
Ownership and runtime health map for `MVVMExample`.

Use it to decide:
- what is reusable
- what must stay app-specific
- where new behavior should live
- what risks are known

## Root Rule
This project currently keeps only minimal app-local infrastructure support under `./MVVMExample/MVVMExampleDemo/Infrastructure/LocalSupport` to avoid duplicating reusable package folders. Reusable/cross-app rules and source context are maintained in `/Users/Artem/.zenflow/worktrees/new-task-be0b/documentation-vault`; app-specific demo behavior, UI composition, feature contracts, and DummyJSON mapping stay in the app layer.

## Current Project Shape
- App target: `MVVMExample`
- Platform: iOS SwiftUI
- Deployment target: iOS 17.0
- App mode: demo/pre-production
- Session persistence: in-memory demo store only
- Networking: app-local configuration/client/error/logging support copied from the reusable baseline
- Core goal: educational MVVM demonstration with production-minded boundaries

## Demo/Test API Policy
- Test API base URL must come from environment/configuration.
- Demo credentials may be shown only when debug/demo configuration allows them.
- Release/production runtime must not silently use demo credentials, fake sessions, stubs, or token-like fixtures.
- Token-like demo strings should be obviously synthetic and kept out of production runtime paths.

## MVVM API Policy
- ViewModels expose explicit intent methods.
- `send(_ action:)` and feature action enums are not default boilerplate.
- Reducer/action architecture requires explicit user approval and an ADR.

## Module / Package Inventory
### `./MVVMExample/`
Owns:
- app entry point
- SwiftUI screens
- app coordinators/routers
- app-specific feature code
- DTO-to-domain mapping

Must not own:
- reusable generic networking/error/logging/config/localization mechanics
- speculative infrastructure unrelated to current requirements

### `./MVVMExample/MVVMExampleDemo/Infrastructure/LocalSupport`
Owns minimal local infrastructure primitives copied from the reusable baseline:
- request primitives, URLSession execution, retries, and cancellation-aware network calls;
- typed app/API error taxonomy;
- runtime environment, API base URL, retry policy, demo credential gates, and demo session storage;
- localized lookup and formatting helpers;
- logging and redaction primitives;
- controlled remote image loading and cache behavior;
- Liquid Glass availability/fallback mechanics.

Must not own app-specific feature behavior, product-specific DTOs, navigation, or screen composition.

## Current Known Risks
- Build must be rerun after Swift/project changes.
- Unit tests and UI tests are intentionally separated; UI smoke remains explicit because it requires simulator execution.
- Manual simulator and accessibility verification beyond smoke tests are still deferred unless explicitly requested.
- Session store is demo in-memory only; production persistence remains a future requirement.
- Release/App Store readiness is not established yet: signing, bundle identity, privacy manifest, analytics/crash routing, and rollout/rollback policy require a separate release-readiness phase before TestFlight/App Store claims.

## Verification Baseline
```zsh
./scripts/verify.sh static
./scripts/verify.sh list
./scripts/verify.sh build
./scripts/verify.sh test-unit
# Explicit UI lane only when requested/needed:
./scripts/verify.sh test-ui
```


### Local Liquid Glass support
`./MVVMExample/MVVMExampleDemo/Infrastructure/LocalSupport/AppGlassUI/` owns Liquid Glass availability and fallback chrome mechanics. App code owns semantic colors, layout, and feature-specific visual policy.


## Documentation Vault Risk
Durable MVVMExample documentation must be synchronized with `/Users/Artem/.zenflow/worktrees/new-task-be0b/documentation-vault/apps/MVVMExample/`. Reusable documentation updates must also be synchronized with `documentation-vault/reusable/`.
