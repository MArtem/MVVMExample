# Modular / Feature-Sliced Architecture Case

## Project
`ModularFeatureSlicedCase`

## Goal
Full functional clone using Modular / Feature-Sliced ownership while preserving the app behavior, design, accessibility identifiers, localization, persistence behavior, pending mutation sync, and test-build coverage.

## Current Status
- [x] Full app functionality/design baseline copied into a standalone project name.
- [x] Source app project name removed from paths and identifiers.
- [x] Source layout converted to `AppShell`, `Features`, `Core`, and `Shared` boundaries.
- [x] Modular / Feature-Sliced boundary review completed.
- [x] Static/build/test-build verification completed.
- [x] Central vault mirror synchronized.

## Target State
- **AppShell**: app entry point, dependency assembly, root auth/session flow, main tabs, and composition of feature entry screens.
- **Feature slices**: `Auth`, `News`, and `Profile` own their own presentation, navigation, domain contracts, data adapters, DTO mapping, repositories, and feature-local state stores.
- **Core**: reusable app-local mechanics such as design system, network client, persistence primitives, configuration, localization, logging, image cache/loading, and Liquid Glass fallback helpers.
- **Shared**: narrow reusable presentation helpers and accessibility identifiers that are not product-policy owners.

## Allowed Reuse
- Preserve source app UI layout, design system tokens, localization resources, accessibility identifiers, networking behavior, persistence behavior, pending mutation queue, and tests.
- Reuse existing repository contracts when they represent real feature seams.
- Reuse ViewModel presentation ownership inside feature slices; Modular / Feature-Sliced does not require replacing MVVM with a reducer/action architecture.

## Stop Rules
- Do not add local `./Packages` or SwiftPM package extraction for this case.
- Do not introduce decorative protocols, factories, wrappers, or use-case layers only to make the tree look modular.
- Do not allow `Core` or `Shared` to import feature/product-specific policy.
- Do not move routing/business/persistence implementation into `AppShell`.
- Do not use generic `send(_:)`, `dispatch(_:)`, or UI action enums as MVVM boilerplate.
- Do not remove functionality/design to simplify the architecture case.

## Architecture Review
- **Detected style**: Modular / Feature-Sliced with explicit app shell, core mechanics, shared presentation helpers, and feature-owned vertical slices.
- **Evidence**: top-level source folders are `AppShell`, `Features`, `Core`, and `Shared`; each feature owns its data/domain/navigation/presentation seams; app composition is centralized in `AppShell`; reusable mechanics are isolated under `Core`.
- **Applicable gate**: dependency direction must remain acyclic, feature slices must not depend on app shell implementation details, and shared/core code must contain mechanics rather than product-specific policy.
- **Rejected for this case**: package extraction, pass-through use-case layers, feature-empty protocols, and broad wrappers around already-local app mechanics.

## Verification Checklist
- Source-identity grep for stale project/product names.
- Architecture grep/review for accidental app-shell ownership of DTO/API/persistence work and feature references from `Core`/`Shared`.
- `git diff --check`.
- `./scripts/verify.sh static`.
- `./scripts/verify.sh build`.
- `./scripts/verify.sh test-build`.
- Vault sync and post-sync identity/generated-file greps.


## App-scoped Core clarification
`Core/` in this case is **app-scoped shared infrastructure**, not a reusable cross-app package or a feature-neutral platform core. It may contain cross-feature persistence/session/sync mechanics required by this standalone clone, but feature-owned presentation and navigation stay inside their slices. If this case is later evolved into stricter feature-sliced modules, feature-specific pending-mutation/profile adapters should move from `Core/Infrastructure` into the owning feature slices behind narrow shared contracts.
