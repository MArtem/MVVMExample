# MVPPassiveViewCase

`MVPPassiveViewCase` is a standalone full-functional architecture case that preserves the source app behavior/design while expressing feature presentation through **MVP Passive View**.

The SwiftUI screens are treated as passive render-forwarding views: they observe presenter state, render it, and forward user events. Screen-scoped `*Presenter` types own presentation decisions, async orchestration, navigation handoff, error mapping, and view-state updates.

## Architecture Intent

- **Passive view**: SwiftUI screens do not decide loading/error/content transitions; they render presenter state and forward explicit events.
- **Presenter ownership**: `LoginPresenter`, `NewsListPresenter`, `NewsDetailPresenter`, `ProfilePresenter`, and `ProfileEditPresenter` own presentation decisions for real feature behavior.
- **Small view seam**: the SwiftUI view-to-presenter seam is limited to explicit user-event methods and observable state; no broad view protocol is added where SwiftUI observation already provides the display channel.
- **No action/reducer scaffold**: this is not TCA/UDF/Reactor-style. SwiftUI calls explicit presenter methods; presenters update their owned presentation state directly.

## Verification

Use the case-local script so DerivedData, package caches, and result bundles remain inside this folder:

```zsh
./scripts/verify.sh static
./scripts/verify.sh build
./scripts/verify.sh test-build
```

Manual simulator, UI automation, and Instruments runs require separate approval.
