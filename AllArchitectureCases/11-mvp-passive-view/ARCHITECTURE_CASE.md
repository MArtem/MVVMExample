# Architecture Case: MVP Passive View

## Case Identity

- **Folder:** `./AllArchitectureCases/11-mvp-passive-view`
- **Project:** `MVPPassiveViewCase`
- **Architecture style:** MVP Passive View
- **Purpose:** Preserve the full app behavior/design while moving presentation decisions into presenters and keeping SwiftUI screens passive/render-forwarding where practical.

## Current Status

- [x] Full functional clone created.
- [x] Source identity removed from app, tests, project, docs, and scripts.
- [x] Presentation ownership converted to screen-scoped `*Presenter` types.
- [x] SwiftUI screens kept passive through observable presenter state and explicit event forwarding.
- [x] Static/build/test-build verification completed.
- [x] Central vault mirror synchronized.

## Architecture Mapping

- **Passive SwiftUI View:** renders presenter state and forwards explicit user events.
- **Presenter:** owns presentation decisions, loading/error/content transitions, form state, async orchestration, navigation handoff, optimistic UI, and error mapping for one screen.
- **Repository / Store:** remains separate for data access, persistence, session, pending mutation sync, and interaction state.
- **Router / Coordinator:** remains separate for navigation stack ownership and app-level session transitions.
- **ViewStateBuilder:** remains separate for formatting and accessibility text; presenters decide when to use builders but do not absorb all formatting details.

## View Protocol Decision

Classic MVP often uses a UIKit view protocol. In this SwiftUI case, the display channel is `@Observable` presenter state rather than imperative `display(...)` calls. Adding unused UIKit-style view protocols would be decorative. The meaningful passive-view seam here is intentionally small: SwiftUI observes state and invokes explicit presenter methods.

## Stop Rules

- Do not reintroduce `ViewModel` identity or old source identity.
- Do not add broad view protocols that duplicate SwiftUI observation without a real test seam.
- Do not put API/DB implementation inside presenters.
- Do not add presenters for pure formatting-only subviews without real presentation decisions.
- Do not add generic `send(_:)` or `dispatch(_:)` APIs.
- Do not remove functionality/design to make the case easier.

## Verification Checklist

- Source identity grep for old names.
- Stale `ViewModel`/`Controller` grep.
- Public generic `send(_:)` / `dispatch(_:)` grep.
- MVP boundary grep/review for screen-scoped `*Presenter` ownership and passive SwiftUI render-forwarding.
- Prohibited action/reducer/Reactor scaffold grep.
- `./scripts/verify.sh static`.
- `./scripts/verify.sh build`.
- `./scripts/verify.sh test-build`.
- `git diff --check`.
