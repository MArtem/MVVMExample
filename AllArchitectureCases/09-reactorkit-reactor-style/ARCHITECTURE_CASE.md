# ReactorKit / Reactor-style

## Case Folder
`./AllArchitectureCases/09-reactorkit-reactor-style`

## Target Architecture
ReactorKit / Reactor-style

## Purpose
Action/Mutation/State reactive style for Rx-oriented comparison; no Rx dependency added until conversion is explicit.

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
