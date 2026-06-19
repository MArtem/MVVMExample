# SwiftUI Native State / MV

## Case Folder
`./AllArchitectureCases/01-swiftui-native-state-mv`

## Target Architecture
SwiftUI Native State / MV

## Purpose
Local visual state, simple controls, pure SwiftUI value state where no API/DB/business ownership is needed.

## Baseline Reuse
This case starts from the current `MVVMExample` app baseline and reuses app code, assets, tests, docs, scripts, and app-local `LocalSupport` infrastructure to avoid mechanical duplication.

## Conversion Status
- [x] Self-contained project clone created.
- [ ] Architecture-specific conversion completed.
- [ ] `git diff --check` passed for this case.
- [x] Baseline smoke build passed before architecture conversion.
- [ ] Build passed after architecture-specific conversion.

## Safety Rules
- Keep generated artifacts under `/Users/Artem/.zenflow`.
- Do not modify the root `MVVMExample` baseline from this case.
- Do not add empty pass-through layers just to imitate the style.
- Preserve user-visible behavior unless this case explicitly documents a behavioral difference.
- Keep demo/test API policy and token/session safety rules intact.

## Verification Command
Run from this folder after conversion:

```zsh
./scripts/verify.sh build
```
