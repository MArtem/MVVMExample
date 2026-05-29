# Project Health

## Purpose
Ownership and runtime health map for `MVVMExample`.

Use it to decide:
- what is reusable
- what must stay app-specific
- where new behavior should live
- what risks are known

## Root Rule
Reusable, entity-agnostic mechanics should live in shared docs/skills. App-specific demo behavior, UI composition, and feature contracts stay in the app layer.

## Current Project Shape
- App target: `MVVMExample`
- Platform: iOS SwiftUI
- Deployment target: iOS 17.0
- Initial persistence: none
- Initial networking: none
- Core goal: educational MVVM demonstration, not production feature breadth

## Module / Package Inventory
### `MVVMExample`
Owns:
- app entry point
- SwiftUI demo screens
- app-specific MVVM example feature code

Must not know about:
- unrelated product flows
- remote services unless explicitly added later
- speculative infrastructure not needed for the demo

### `./docs` and `./.codex/skills`
Own:
- reusable production baseline
- review/checklist rules
- prompt presets
- reusable iOS skills

Must not know about:
- app-specific behavior unless generalized first

## Current Known Risks
- The MVVM demo feature itself is not implemented yet — status: open.
- Command-line build has not been run yet; only project listing has been verified — status: open.

## Verification Baseline
```zsh
# static
git diff --check

# project structure
xcodebuild -list -project MVVMExample.xcodeproj

# build, when approved/needed
xcodebuild -project MVVMExample.xcodeproj -scheme MVVMExample -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0' CODE_SIGNING_ALLOWED=NO build
```
