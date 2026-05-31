# Project Health

## Purpose
Ownership and runtime health map for `MVVMExample`.

Use it to decide:
- what is reusable
- what must stay app-specific
- where new behavior should live
- what risks are known

## Root Rule
Reusable, entity-agnostic mechanics should live in `./Packages/AppInfrastructure/` or shared docs/skills. App-specific demo behavior, UI composition, feature contracts, and DummyJSON mapping stay in the app layer.

## Current Project Shape
- App target: `MVVMExample`
- Platform: iOS SwiftUI
- Deployment target: iOS 17.0
- App mode: demo/pre-production
- Session persistence: in-memory demo store only
- Networking: neutral `AppInfrastructure` configuration/client/error/logging direction
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

### `./Packages/AppInfrastructure/`
Owns:
- neutral reusable networking primitives
- typed error taxonomy
- configuration primitives
- redacted logging hooks
- localization helpers

Must not own:
- app-specific feature behavior
- product-specific DTOs
- database/sync/widgets/push/share/media/AI until required

## Current Known Risks
- Build must be rerun after package/project changes.
- Manual simulator and accessibility verification are still deferred unless explicitly requested.
- Session store is demo in-memory only; production persistence remains a future requirement.

## Verification Baseline
```zsh
# static
git diff --check

# project structure
xcodebuild -list -project MVVMExample.xcodeproj

# build, when Swift/package/project code changes
xcodebuild -project MVVMExample.xcodeproj -scheme MVVMExample -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```
