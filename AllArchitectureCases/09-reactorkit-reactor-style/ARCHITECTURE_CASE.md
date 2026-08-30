# ReactorKit / Reactor-style Architecture Case

## Project
`ReactorStyleCase`

## Goal
Full functional clone using ReactorKit / Reactor-style Action → Mutation → State ownership while preserving the app behavior, design, accessibility identifiers, localization, persistence behavior, pending mutation sync, and test-build coverage.

## Current Status
- [x] Full app functionality/design baseline copied into a standalone project name.
- [x] Source app project name removed from paths and identifiers.
- [x] Presentation ownership converted to feature-local Reactors with explicit `State`, typed `Action`, typed `Mutation`, and `mutate`/`reduce` paths.
- [x] ReactorKit / Reactor-style boundary review completed.
- [x] Static/build/test-build verification completed.
- [x] Central vault mirror synchronized.

## Target State
- **State**: each screen Reactor owns observable state through a `State` alias to a precomputed view-state model.
- **Action**: typed feature-local user/system events accepted by `mutate(_ action:)`.
- **Mutation**: typed state transitions applied by `reduce(_ mutation:)`.
- **SideEffect**: async work launched from mutation handling, not from SwiftUI views or reducers.
- **Reactor**: SwiftUI-facing observable owner exposing explicit product intent methods, while internally mapping those methods to Action → Mutation → State flow.
- **AppShell**: composition root that wires reactors, repositories, routers, persistence, and session ownership.

## Allowed Reuse
- Preserve source app UI layout, design system tokens, localization resources, accessibility identifiers, networking behavior, persistence behavior, pending mutation queue, and tests.
- Reuse existing repository contracts as side-effect dependencies.
- Use lightweight in-project Reactor-style mechanics rather than adding a third-party ReactorKit package, because package adoption is not approved for this exploration.
- Keep one Reactor per screen where state is screen-scoped; do not force a global app reactor.

## Stop Rules
- Do not add local `./Packages` or a third-party ReactorKit dependency unless explicitly approved.
- Do not create superficial Action/Mutation names while leaving state mutation scattered outside reducers.
- Do not use public generic `send(_:)` or `dispatch(_:)` as the UI API.
- Do not put networking/persistence work inside `reduce(_:)`.
- Do not remove functionality/design to simplify the architecture case.

## Architecture Review
- **Detected style**: Reactor-style local Reactors with explicit `State`, typed `Action`, typed `Mutation`, `mutate(_ action:)`, and `reduce(_ mutation:)`.
- **Evidence**: `LoginReactor`, `NewsListReactor`, `NewsDetailReactor`, `ProfileReactor`, and `ProfileEditReactor` each declare `State`, `Action`, `Mutation`, `mutate`, and `reduce`; SwiftUI calls explicit intent methods; async work remains in Reactor-owned tasks and side-effect helpers.
- **Applicable gate**: actions are meaningful feature events, mutations represent state transitions, reducers only mutate state, and side effects own async/cancellation/error behavior.
- **Rejected for this case**: third-party dependency adoption, global reactor, pass-through actions for every trivial helper, and reactor rewrites that delete navigation/persistence behavior.

## Verification Checklist
- Source-identity grep for stale project/product names.
- Architecture grep/review for `State`/`Action`/`Mutation`/`mutate`/`reduce` evidence and absence of public generic `send(_:)`/`dispatch(_:)` APIs.
- `git diff --check`.
- `./scripts/verify.sh static`.
- `./scripts/verify.sh build`.
- `./scripts/verify.sh test-build`.
- Vault sync and post-sync identity/generated-file greps.
