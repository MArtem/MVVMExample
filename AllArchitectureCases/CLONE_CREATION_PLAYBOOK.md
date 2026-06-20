# Architecture Case Clone Creation Playbook

## Purpose
This document is the mandatory working plan for every new project clone under `AllArchitectureCases`.

The goal is not to create small examples, empty apps, toy demos, or partially renamed copies. Each architecture case must become a full standalone project that preserves the source app's functionality and design while replacing only the architecture and ownership model according to the selected architecture.

This playbook exists because the first VIPER iteration exposed costly mistakes:

- creating a minimal placeholder app instead of a full functional clone;
- leaving source-project names in files, targets, strings, tests, scripts, and docs;
- copying folders without actually converting architectural ownership;
- letting Presenters depend on repositories directly instead of respecting architecture boundaries;
- committing or syncing generated/user-local files;
- validating too late, after avoidable work had accumulated.

Every future architecture case must follow this plan before implementation, during implementation, and before commit.

## Non-Negotiable Outcome
For each architecture folder, the final result must be:

1. **Full functional clone**: same user-visible app behavior and design as the source app.
2. **Standalone project**: independent Xcode project, targets, schemes, test plans, scripts, and docs.
3. **Architecture-specific ownership**: code structure and dependency direction must match the selected architecture.
4. **No stale source identity**: no source-project names, architecture labels, file names, bundle IDs, environment names, docs, test names, or UI strings from the previous project unless the selected case explicitly requires them.
5. **Buildable and test-buildable**: app build and test-build must pass through sandboxed commands.
6. **Shared visibility**: local `AllArchitectureCases` and the central documentation vault mirror must stay in sync.

## Required Mindset
Do not optimize for speed by reducing scope. Optimize by reusing existing implementation safely.

Allowed reuse:

- source app UI layout and design system;
- data repositories and DTO mapping if architecture permits that layer;
- persistence/local support behavior;
- localization resources;
- accessibility identifiers;
- tests after renaming and architecture alignment;
- scripts after project-name and sandbox updates.

Forbidden shortcuts:

- creating an empty demo instead of a full clone;
- leaving `MVVMExample`, previous app names, or stale architecture names in the case;
- doing only file/name replacement without changing architecture ownership;
- adding decorative protocols/factories/wrappers just to look architectural;
- removing functionality to make conversion easier;
- running simulator UI/manual/Instruments lanes without explicit approval;
- committing generated artifacts, `.DS_Store`, `xcuserdata`, `.xcuserstate`, Xcode caches, logs, or result bundles.

## Phase 0 — Preflight And Scope Lock
Before touching a case folder:

1. Read the active task/project rules.
2. Read the selected architecture rules and any architecture-router guidance.
3. Confirm the selected architecture name, project name, target names, and folder path.
4. Identify the complete source app scope to preserve:
   - auth/login;
   - news list;
   - news detail;
   - profile;
   - profile edit;
   - local session persistence;
   - local interaction persistence;
   - pending mutation sync;
   - networking/config/error handling;
   - design system;
   - localization;
   - accessibility identifiers;
   - unit/test-build coverage;
   - UI test target presence, without running UI tests unless approved.
5. Add or update a plan step before implementation.

Preflight commands:

```zsh
git status --short --branch --untracked-files=all
find ./AllArchitectureCases/<case-folder> -maxdepth 3 -print | sed -n '1,200p'
```

## Phase 1 — Start From A Full Functional Clone
The architecture case must start from the current full source app, not from an empty Xcode template.

Required clone contents:

- app Xcode project;
- app source;
- unit tests;
- UI tests;
- test plans;
- assets;
- localization catalogs;
- scripts;
- docs that are relevant to the standalone case.

Do not delete behavior during this phase. The first checkpoint is a renamed full app that builds before architecture conversion.

## Phase 2 — Rename The Project Completely
Rename the case so it has its own identity.

Minimum rename surface:

- folder name;
- `.xcodeproj` name;
- app source root folder;
- app module folder;
- app entry-point file and type;
- app target;
- unit test target;
- UI test target;
- schemes;
- `.xctestplan` files;
- bundle identifiers;
- launch environment variables;
- script variables;
- README/docs;
- localization strings;
- test fixture labels;
- UI test launch environment names;
- generated comments that reference the old identity.

Mandatory check:

```zsh
grep -R "<old-project-name>\|<old-architecture-name>\|<old-env-prefix>" \
  ./AllArchitectureCases/<case-folder> \
  --exclude-dir=.xcode-derived-data \
  --exclude-dir=.xcode-package-cache \
  --exclude-dir=.xcode-result-bundles
```

The grep must be empty unless the selected architecture is intentionally the same as the source architecture and the reference is explicitly documented.

## Phase 3 — Make The Renamed Clone Build Before Architectural Work
Before restructuring architecture, prove that the renamed full clone still builds.

Required script rules:

- `verify.sh` must use case-local sandbox paths:
  - `./<case>/.xcode-derived-data/`;
  - `./<case>/.xcode-package-cache/`;
  - `./<case>/.xcode-result-bundles/`.
- Build destination should use a generic simulator destination for build-only lanes.
- Runtime test/UI lanes must remain explicit.

Required commands:

```zsh
git diff --check
./scripts/verify.sh build
```

If this fails, fix rename/project integration before changing architecture.

## Phase 4 — Convert Architecture By Ownership, Not By Names
A case is not converted just because files were renamed.

For every feature, define the selected architecture's roles and map existing responsibilities into those roles.

For example, in VIPER:

- **View**: render-only SwiftUI screens/components; forwards explicit user intents.
- **Interactor**: business/data/persistence/sync work; owns repository/local-store calls.
- **Presenter**: presentation state, user intent orchestration, cancellation/backpressure, error-to-state transitions.
- **Entity**: domain/presentation entities and route payloads that do not leak DTO/database models into UI.
- **Router**: navigation state, route payloads, navigation transitions only.
- **Builder**: module assembly; creates Interactors and Presenters at boundaries.

Critical VIPER boundary learned from the VIPER pass:

- Presenters must not accept repositories directly.
- Builders create Interactors.
- Presenters receive Interactors.
- Views receive Presenters.
- Routers do not perform business/data work.

Equivalent boundaries must be written down before implementing every other architecture.

## Phase 5 — Preserve Existing Product Behavior
During architecture conversion, preserve behavior unless the user explicitly approves a product change.

Required preserved behavior:

- login success/failure/demo credential behavior;
- auth session restoration;
- logout cleanup;
- news initial load;
- pull-to-refresh failure preservation;
- pagination and pagination backpressure;
- article like/favorite optimistic behavior;
- detail/list state reconciliation;
- profile load/edit/save/logout;
- local profile merge behavior;
- pending mutation enqueue/replay behavior;
- user-safe error mapping;
- accessibility identifiers;
- localized user-facing text;
- light/dark semantic color behavior;
- image loading/cache behavior.

Never remove tests or features to make the architecture conversion pass.

## Phase 6 — Update Tests To Match The New Architecture
Tests must compile against the new architecture's real seams.

Do not leave tests calling stale initializers or old architecture names.

Examples from VIPER:

- tests should construct `Interactor` and pass it to `Presenter`;
- tests should not instantiate `Presenter(repository:)` when that violates VIPER boundaries;
- test file names should match the new role names;
- test suite names should match the new role names;
- UI test environment names should use the new project prefix.

Required command:

```zsh
./scripts/verify.sh test-build
```

Runtime UI tests remain separate and require explicit approval.

## Phase 7 — Architecture Review Before Commit
Run an architecture review before commit.

Review checklist:

1. **Role correctness**: each role owns the right responsibility for the selected architecture.
2. **Dependency direction**: UI does not depend on data details; business/data work is behind the correct role boundary.
3. **No stale architecture API**: no generic `send(_:)`, `dispatch(_:)`, UI action enum boilerplate unless the selected architecture explicitly requires it and the user approved it.
4. **No decorative layers**: every new protocol/builder/interactor/router has a real responsibility.
5. **No lost behavior**: compare against source app scope from Phase 0.
6. **No old identity**: project names, class names, docs, scripts, tests, env vars, and strings are clean.
7. **No generated/user-local files**: no `.DS_Store`, `xcuserdata`, `.xcuserstate`, Xcode caches, result bundles, logs.

Required greps:

```zsh
grep -R "MVVMExample\|ViewModel\|viewModel\|MVVM\|BestMVVM\|MVVMEXAMPLE\|TaskDemo" \
  ./AllArchitectureCases/<case-folder> \
  --exclude-dir=.xcode-derived-data \
  --exclude-dir=.xcode-package-cache \
  --exclude-dir=.xcode-result-bundles

grep -R "func[[:space:]]\+send[[:space:]]*(\|func[[:space:]]\+dispatch[[:space:]]*(\|enum[[:space:]]\+[[:alnum:]_]*Action[[:space:]]*:" \
  ./AllArchitectureCases/<case-folder>/<ProjectName>/<AppModule> \
  --exclude-dir=.xcode-derived-data \
  --exclude-dir=.xcode-package-cache \
  --exclude-dir=.xcode-result-bundles

find ./AllArchitectureCases/<case-folder> \
  \( -name .DS_Store -o -path '*xcuserdata*' -o -name '*.xcuserstate' \)
```

Expected result: no output for all three checks.

## Phase 8 — Verification Before Commit
Minimum verification before commit:

```zsh
git diff --check
./scripts/verify.sh static
./scripts/verify.sh build
./scripts/verify.sh test-build
```

Notes:

- If `static` reports test-only token fixture warnings but exits successfully, document them as non-blocking test fixtures.
- Do not run `test-ui` unless explicitly approved.
- Do not use global Xcode/SwiftPM caches.

## Phase 9 — Sync The Documentation Vault
After local case verification, sync the finalized case to the central vault mirror.

Target:

```text
/Users/Artem/.zenflow/worktrees/new-task-be0b/documentation-vault/reusable/architecture-cases/AllArchitectureCases/<case-folder>
```

Use `rsync --delete`, excluding generated artifacts:

```zsh
rsync -a --delete \
  --exclude '.xcode-derived-data/' \
  --exclude '.xcode-package-cache/' \
  --exclude '.xcode-result-bundles/' \
  --exclude '*.log' \
  ./AllArchitectureCases/<case-folder>/ \
  /Users/Artem/.zenflow/worktrees/new-task-be0b/documentation-vault/reusable/architecture-cases/AllArchitectureCases/<case-folder>/
```

Then re-run the identity and generated-file greps against both local and vault paths.

## Phase 10 — Commit Rules
Commit only after:

- architecture review passes;
- all required greps are clean;
- `git diff --check` passes;
- static/build/test-build pass;
- local case and vault mirror are synced;
- no generated/user-local files are staged.

Commit local worktree and vault separately if both are changed.

Do not push unless explicitly approved.

## Completion Report Template
Every completed architecture case report must include:

- selected architecture;
- project name;
- source behavior preserved;
- architecture ownership mapping;
- defects found during review and fixes applied;
- verification commands and results;
- commit hashes, if committed;
- remaining risks, if any;
- whether push was performed.

## Stop Conditions
Stop and ask the user before continuing if:

- the selected architecture requires a product behavior change;
- the selected architecture requires a broad ADR/user decision;
- runtime UI tests, manual simulator flows, or Instruments are needed;
- preserving full functionality conflicts with the selected architecture;
- a generated/source identity grep cannot be made clean without destructive changes;
- build/test-build fails due to an environment blocker rather than code.

## Checklist For The Next Clone
Before starting the next architecture folder, copy this checklist into the active plan:

- [ ] Confirm selected architecture and final project name.
- [ ] Start from full source app clone, not an empty template.
- [ ] Rename project/targets/schemes/tests/scripts/docs/env vars completely.
- [ ] Build renamed clone before architecture conversion.
- [ ] Define the selected architecture role mapping.
- [ ] Convert features by ownership while preserving behavior/design.
- [ ] Update tests to new seams and names.
- [ ] Run architecture greps and generated-file checks.
- [ ] Run `git diff --check`, `static`, `build`, `test-build`.
- [ ] Sync central vault mirror.
- [ ] Commit only after review passes; do not push without approval.
