# Hexagonal / Ports & Adapters

## Case Folder
`./AllArchitectureCases/06-hexagonal-ports-adapters`

## Target Architecture
Hexagonal / Ports & Adapters

## Purpose
Domain ports and adapters only where infrastructure variability is real.

## Baseline Reuse
This case starts from the current `MVVMExample` app baseline and reuses app code, assets, tests, docs, scripts, and app-local `LocalSupport` infrastructure to avoid mechanical duplication.

## Conversion Status
- [x] Self-contained project clone created.
- [ ] Architecture-specific conversion completed.
- [ ] `git diff --check` passed for this case.
- [ ] Build passed for this case.

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
