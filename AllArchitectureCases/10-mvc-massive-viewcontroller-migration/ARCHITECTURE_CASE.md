# Architecture Case: MVC / Massive ViewController Migration

## Case Identity

- **Folder:** `./AllArchitectureCases/10-mvc-massive-viewcontroller-migration`
- **Project:** `MVCMigrationCase`
- **Architecture style:** MVC / Massive ViewController Migration
- **Purpose:** Preserve the full app behavior/design while demonstrating a legacy MVC migration boundary that keeps controller responsibilities screen-scoped instead of creating one unreviewable app-wide object.

## Current Status

- [x] Full functional clone created.
- [x] Source identity removed from app, tests, project, docs, and scripts.
- [x] Presentation ownership converted to screen-scoped `*Controller` types.
- [x] Controller responsibilities documented as intentionally legacy-shaped but bounded per screen.
- [x] Static/build/test-build verification completed.
- [x] Central vault mirror synchronized.

## Architecture Mapping

- **SwiftUI View:** renders state and forwards explicit UI events to the controller.
- **Controller:** owns screen state, form fields, async tasks, navigation handoff, repository calls, optimistic updates, and error mapping for one screen.
- **Repository / Store:** remains separate for data access, persistence, session, pending mutation sync, and interaction state.
- **Router / Coordinator:** remains separate for navigation stack ownership and app-level session transitions.
- **ViewStateBuilder:** remains separate for formatting and accessibility text so the controller does not absorb every formatting concern.

## Intentional Legacy Shape

This case is not an endorsement of a massive object. It models an incremental migration state where a legacy controller still owns several responsibilities. The guardrail is that each controller is **screen-scoped** and the rest of the app keeps clear boundaries for persistence, networking, routing, and reusable UI formatting.

## Stop Rules

- Do not collapse all app behavior into one global controller.
- Do not add decorative presenters/interactors/use cases just to hide MVC naming.
- Do not reintroduce `ViewModel` identity or old source identity.
- Do not add generic `send(_:)` or `dispatch(_:)` APIs.
- Do not remove functionality/design to make the migration case easier.

## Verification Checklist

- Source identity grep for old names.
- Stale `ViewModel` grep.
- Public generic `send(_:)` / `dispatch(_:)` grep.
- MVC boundary grep/review for screen-scoped `*Controller` ownership and absence of Action/Mutation/Reactor-style presentation scaffolding.
- `./scripts/verify.sh static`.
- `./scripts/verify.sh build`.
- `./scripts/verify.sh test-build`.
- `git diff --check`.
