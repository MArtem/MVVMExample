# Deprecated Historical Spec

This file is retained only as historical context for the earlier package-boundary remediation phase. It is not the active MVVMExample architecture rule.

Current active decision:
- `MVVMExample` does not keep local Swift Package folders.
- Approved infrastructure lives under `./MVVMExample/MVVMExampleDemo/Infrastructure/LocalSupport/`.
- Do not reintroduce `./Packages/AppInfrastructure` unless the user explicitly approves package-mode adoption again.
- Current rules are `./AGENTS.md`, `./docs/MODEL_ROUTING_RULE.md`, `./PROJECT_DOCUMENTATION.md`, `./PROJECT_HEALTH.md`, and `./docs/PACKAGE_USAGE_IN_MVVMEXAMPLE.md`.

---

# MVVMExample Remediation Spec

## Purpose
Instruction set for applying the reusable iOS production baseline to `MVVMExample` after the initial demo project import.

## Target Project
- Project: `MVVMExample`
- Worktree: `/Users/Artem/.zenflow/worktrees/mvvmexample-3c80`

## Mandatory Startup
Before changing code, read the current project rules:

1. `./AGENTS.md`
2. `./PROJECT_DOCUMENTATION.md`
3. `./PROJECT_HEALTH.md`
4. `./TESTING_INSTRUCTIONS.md`
5. `./docs/README.md`, if present
6. `./docs/CURRENT_USER_OVERRIDES.md`, if present
7. `./docs/AGENT_RULES.md`, if present
8. current Zenflow task `plan.md`

Every working/status/readiness/planning/confirmation response must start with:

- model
- active phase
- files being inspected/changed
- next safe step
- whether a build is needed
- sandbox/worktree confirmation inside `/Users/Artem/.zenflow`

## Non-Negotiable Architecture Rule
Do not use generic ViewModel dispatch as the default MVVM API:

```swift
func send(_ action: SomeAction)
```

Do not use UI action enums as default feature boilerplate.

Use explicit ViewModel intent methods:

```swift
func appeared()
func loginTapped()
func refreshRequested()
func articleTapped(id: Article.ID)
func likeTapped(id: Article.ID)
func saveTapped()
func logoutTapped()
```

A reducer/action architecture is allowed only after explicit user approval and an ADR.

## Current Project Mode
`MVVMExample` may use test API and test credentials while it is a demo/pre-production project. This must be explicit:

- test API base URL comes from environment/configuration;
- test credentials are available only in debug/demo mode;
- production/release must not silently use demo credentials, stubs, or fake sessions;
- token-like fixtures must not look like real committed secrets.

## Implementation Blocks

### Block 1 — Documentation And Rules
- Update `./AGENTS.md`.
- Update `./PROJECT_DOCUMENTATION.md`.
- Update `./PROJECT_HEALTH.md`.
- Create/update root `./README.md`.
- Remove stale clean-baseline or `TaskDemo` instructions if they conflict with the imported app.
- Record explicit-intent MVVM, demo/test API policy, demo credentials policy, and reusable infrastructure direction.

Verification:

```zsh
git diff --check
```

### Block 2 — Neutral Reusable Infrastructure Package
Create or connect a neutral package, not `Tchop*` branded naming:

```text
./Packages/AppInfrastructure/
```

Recommended initial modules:

```text
AppNetworking
AppErrors
AppLocalization
AppConfiguration
AppLogging
```

Use current `TchopInfrastructure` concepts only as source inspiration. Keep naming generic for the new project.

Do not add database, sync, widgets, push, share, media, or AI packages until the project has current requirements for them.

### Block 3 — Network / Config / Auth
- Replace weak app-local networking with `AppNetworking`.
- Make JSON body encoding throwing; no `try?` body loss.
- Add `APIConfiguration` and environment-owned base URL.
- Add typed error taxonomy: offline, timeout, cancelled, unauthorized, forbidden, server, encoding, decoding, invalid response.
- Add redacted logging hooks.
- Add `SessionStore` with `InMemorySessionStore` for demo mode.
- Make logout clear session state.
- Gate demo credentials behind debug/demo configuration.

### Block 4 — Replace `send(_ action:)`
Refactor all ViewModels from generic action dispatch to explicit methods.

Targets include:

- `LoginViewModel`
- `NewsListViewModel`
- `NewsDetailViewModel`
- `ProfileViewModel`
- `ProfileEditViewModel`

Views should call concrete intent methods directly or receive narrow callbacks derived from those methods.

### Block 5 — Concurrency Lifecycle
- Add task cancellation in `deinit` where ViewModels own tasks.
- Split task slots by operation when necessary: load, refresh, save, like/favorite.
- Add stale-result protection.
- Ignore `CancellationError`.
- Remove artificial delays or gate them behind explicit demo/debug dependencies.

### Block 6 — Feature Correctness
- Add a single source of truth for like/favorite state shared by list/detail.
- Stop deriving editable profile names by splitting `displayName`; preserve `firstName` and `lastName` separately.
- Fix card accessibility semantics: whole-card open action must not hide like/comments from VoiceOver.
- Move user-facing strings through localization.

### Block 7 — Static Gates
Update static checks to catch:

- default `send(_ action:)` ViewModel APIs;
- UI action enums used as boilerplate;
- hardcoded user-facing strings;
- `try?` in networking encode/decode boundaries;
- `Task {}` without task ownership/cancellation in ViewModels;
- demo credentials outside debug/demo configuration;
- token-like fixture strings.

## Verification Order
After each code block:

```zsh
git diff --check
```

Run build after code/package changes. Run simulator/manual checks only when the user asks.
