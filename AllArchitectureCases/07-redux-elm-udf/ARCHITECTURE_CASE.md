# Redux / Elm / UDF Architecture Case

## Project
`ReduxElmUDFCase`

## Goal
Full functional clone using Redux / Elm / UDF ownership while preserving the app behavior, design, accessibility identifiers, localization, persistence behavior, pending mutation sync, and test-build coverage.

## Current Status
- [x] Full app functionality/design baseline copied into a standalone project name.
- [x] Source app project name removed from paths and identifiers.
- [x] Presentation ownership converted to feature-owned `*Store` state owners.
- [x] Store internals now use typed `Action` inputs, typed `Mutation` outputs, reducer-style mutation application, and isolated async effects for network/persistence work.
- [x] Redux / Elm / UDF boundary review completed.
- [x] Static/build/test-build verification completed.
- [x] Central vault mirror synchronized.

## Target State
- **Action**: a feature-local typed user/system event accepted by a Store, for example login, refresh, pagination, favorite, save, edit, or logout intent.
- **Mutation**: a feature-local typed state transition emitted by event/effect handling; reducers apply mutations synchronously and keep state changes explicit.
- **Store**: the observable state owner used by SwiftUI. It exposes explicit product intents to views and keeps generic `send(_:)`/`dispatch(_:)` out of the public UI API.
- **Effect**: async work such as repository calls, pending mutation persistence, session/profile updates, image/network integration, and cancellation generation checks.
- **Reducers**: local pure-ish mutation application paths that update view state and feature domain cache without hiding side effects in view bodies.
- **AppShell**: composition root that wires feature stores, repositories, routers, persistence, and session ownership.

## Allowed Reuse
- Preserve source app UI layout, design system tokens, localization resources, accessibility identifiers, networking behavior, persistence behavior, pending mutation queue, and tests.
- Reuse existing repository contracts where they represent real effect boundaries.
- Keep SwiftUI views simple: views call explicit intent methods, stores map those intents to typed UDF actions internally.
- Use one Store per feature screen where the state machine is already screen-scoped; do not force one global store for local visual state.

## Stop Rules
- Do not add local `./Packages` or SwiftPM package extraction for this case.
- Do not introduce decorative protocols, factories, wrappers, or use-case layers only to make the tree look architectural.
- Do not use generic `send(_:)` or `dispatch(_:)` as public Store API.
- Do not put networking/persistence effects into SwiftUI views or reducers.
- Do not create one global app store unless the case has a real cross-feature state-machine reason.
- Do not remove functionality/design to simplify the architecture case.

## Architecture Review
- **Detected style**: Redux / Elm / UDF with SwiftUI driving explicit Store intents, typed feature-local `Action` enums, typed `Mutation` enums, reducer-style mutation application, and isolated async effects.
- **Evidence**: feature presentation state owners are `LoginStore`, `NewsListStore`, `NewsDetailStore`, `ProfileStore`, and `ProfileEditStore`; each maps explicit view intents to local actions and applies state transitions through `reduce(_ mutation:)`; async repository/persistence work remains outside reducers.
- **Applicable gate**: actions represent real user/system events, mutations represent state transitions, effects own cancellation/error behavior, and reducers do not perform network or persistence work.
- **Rejected for this case**: app-wide global store, pass-through action boilerplate for every trivial helper, reducer-only rewrites that delete existing navigation/persistence behavior, and public generic dispatch APIs.

## Verification Checklist
- Source-identity grep for stale project/product names.
- Architecture grep/review for Store/Action/Mutation/Reducer evidence and for absence of public generic `send(_:)`/`dispatch(_:)` UI APIs.
- `git diff --check`.
- `./scripts/verify.sh static`.
- `./scripts/verify.sh build`.
- `./scripts/verify.sh test-build`.
- Vault sync and post-sync identity/generated-file greps.


## Feature-state traceability
Screen-scoped Stores intentionally keep rendered SwiftUI state public, but non-rendered cache/form/pagination state must stay named and reviewable as feature state. Do not hide new state-machine data in anonymous private fields without adding matching actions/mutations or an explicit `FeatureState` member.
