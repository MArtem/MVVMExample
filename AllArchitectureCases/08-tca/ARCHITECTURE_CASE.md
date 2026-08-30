# TCA Architecture Case

## Project
`TCACase`

## Goal
Full functional clone using TCA-style state/action/reducer/effect ownership while preserving the app behavior, design, accessibility identifiers, localization, persistence behavior, pending mutation sync, and test-build coverage.

## Current Status
- [x] Full app functionality/design baseline copied into a standalone project name.
- [x] Source app project name removed from paths and identifiers.
- [x] Presentation ownership converted to feature-local Stores with explicit `State`, `Action`, `Effect`, and reducer-style state mutation paths.
- [x] TCA boundary review completed.
- [x] Static/build/test-build verification completed.
- [x] Central vault mirror synchronized.

## Target State
- **State**: each screen Store owns explicit observable state through a `State` alias to the existing precomputed view-state model.
- **Action**: a typed feature-local enum for user/system events such as appear, retry, refresh, favorite, save, edit, logout, and demo-credential intents.
- **Reducer**: a local `reduce(_ mutation:)` path applies state mutations synchronously; it does not perform network, persistence, routing, logging, or task creation.
- **Effect**: a typed feature-local enum for async work. Store-owned `run(_ effect:)` / `runAsync(_ effect:)` methods execute repository calls, cancellation, pending sync, and profile/session effects outside the reducer.
- **Store**: SwiftUI-facing observable object exposing explicit product intent methods, not public generic `send(_:)` or `dispatch(_:)`.
- **AppShell**: composition root that wires stores, repositories, routers, persistence, and session ownership.

## Allowed Reuse
- Preserve source app UI layout, design system tokens, localization resources, accessibility identifiers, networking behavior, persistence behavior, pending mutation queue, and tests.
- Reuse existing repository contracts as effect dependencies.
- Use lightweight in-project TCA-style mechanics rather than adding a third-party package, because package adoption is not approved for this architecture exploration.
- Keep one Store per screen where state is screen-scoped; do not force a single global app Store for local visual state.

## Stop Rules
- Do not add local `./Packages` or a SwiftPM dependency for The Composable Architecture unless explicitly approved.
- Do not create superficial `Reducer`/`Effect` names while leaving side effects hidden in SwiftUI views.
- Do not use public generic `send(_:)` or `dispatch(_:)` as the Store API.
- Do not put networking/persistence work inside reducers.
- Do not remove functionality/design to simplify the architecture case.

## Architecture Review
- **Detected style**: TCA-style local Stores with explicit `State`, typed `Action`, typed `Effect`, reducer-style `StateMutation` application, and side effects executed outside reducers.
- **Evidence**: `LoginStore`, `NewsListStore`, `NewsDetailStore`, `ProfileStore`, and `ProfileEditStore` each declare `State`, `Action`, `Effect`, `StateMutation`, and `reduce(_ mutation:)`; SwiftUI calls explicit intent methods; async effects remain in Store-owned tasks and repository calls.
- **Applicable gate**: actions are meaningful feature events, reducers only mutate state, effects own async/cancellation/error behavior, and app composition remains in `AppShell`.
- **Rejected for this case**: third-party dependency adoption, a global store, pass-through actions for every trivial helper, and reducer rewrites that delete navigation/persistence behavior.

## Verification Checklist
- Source-identity grep for stale project/product names.
- Architecture grep/review for `State`/`Action`/`Effect`/reducer evidence and absence of public generic `send(_:)`/`dispatch(_:)` APIs.
- `git diff --check`.
- `./scripts/verify.sh static`.
- `./scripts/verify.sh build`.
- `./scripts/verify.sh test-build`.
- Vault sync and post-sync identity/generated-file greps.
