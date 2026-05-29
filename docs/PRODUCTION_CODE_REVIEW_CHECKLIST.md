# Production Code Review Checklist

## Purpose
This checklist is mandatory for any non-trivial implementation, refactor, cleanup, or review in `<AppName>`.

It exists to prevent hidden production defects before the project grows: scroll jank, broad state invalidation, bad persistence access, unsafe network/sync behavior, memory leaks, duplicated domain concepts, and speculative architecture.

## Usage Rule
Before starting implementation or declaring a review complete:

1. Read the active docs index in `./docs/README.md`.
2. Apply `./docs/CURRENT_USER_OVERRIDES.md` before general defaults.
3. Apply this checklist together with `./docs/PRODUCTION_QUALITY_GATES.md`.
4. If a section is irrelevant, explicitly state why in the completion report.
5. If intent, ownership, state flow, or product behavior is unclear, stop and ask the user before implementing.

## Mandatory Review Areas
Every meaningful change must be checked against these areas.

### UI Hot Path
- SwiftUI `body`, row builders, layout callbacks, scroll callbacks, gestures, and animations must stay cheap and side-effect free.
- No synchronous file/media/database/network work in render paths.
- Scrollable or repeated UI must use stable identity, narrow row inputs, and bounded invalidation.
- Media previews must be async/cached/downsampled, not generated during row render.
- Heavy shadows, blur, masks, materials, gradients, and clipping in repeated rows require explicit review or profiling.

### State Ownership
- One source of truth per state concept.
- UI-only state stays local where possible.
- Feature state is owned above consumers and injected down.
- Views should not observe broad global objects when they need only scalar values or callbacks.
- Child views should start as narrow immutable `ViewState` plus explicit callbacks; add a dedicated model/view model only for concrete independent lifecycle, async ownership, subscriptions, transactional editing, isolated retry/error behavior, resource ownership, or cross-feature reusable contract pressure.
- A child model/view model that only mirrors parent input, hides simple callbacks, or exists for pattern symmetry is forbidden.
- Async tasks must protect against stale results and duplicated writes.

### Persistence And Database Access
- Writes must be scoped to the affected record(s) by default.
- Fetch-all/save-all for a single item is forbidden unless justified by a current technical constraint.
- Persist durable product data only; keep caches and rendering artifacts separate.
- Persisted model changes must consider migration/decode compatibility unless the user explicitly says production migration is irrelevant.
- Persistence failures must not silently destroy in-memory user work.

### Network And Sync
- UI must not depend on network when local data can remain visible.
- DTO/backend shape must not leak into SwiftUI rows.
- Offline, partial failure, auth expiration, retry/backoff, duplicate submission, and cancellation must be considered.
- Sync must preserve local-only data and local user interaction state unless backend policy explicitly overrides it.

### Concurrency And Main Thread
- Main actor is for UI state and APIs that require it.
- Heavy work must run off-main: parsing, decoding, image/video/PDF generation, compression, hashing, large filtering/sorting, and database preparation.
- Unbounded tasks in loops, rows, gestures, or scroll callbacks are forbidden.
- Shared mutable state must be actor-isolated, value-isolated, or otherwise synchronized.

### Memory, Media, And Cache
- Images must be downsampled for target display size.
- Full-resolution media must not be retained across many rows.
- Caches must be bounded and distinguish source-of-truth data from regenerable data.
- Temporary/imported files must have an ownership and cleanup policy.
- Large arrays/dictionaries must not be repeatedly copied in hot paths.

### Naming And Domain Purity
- Product/domain/UI types must not encode storage/source split such as local-vs-remote unless the product explicitly requires different behavior.
- Storage-only implementation details may use storage-specific names only when they do not leak into domain/UI contracts.
- Avoid duplicated concepts with different names across app, extension, package, and docs.

### Architecture And Abstractions
- No speculative layers, protocols, factories, adapters, managers, UseCases, services, or per-view models without one concrete current problem.
- App-specific product policy stays in `./<AppName>`.
- Reusable entity-agnostic mechanics belong in `./Packages/<ReusableInfrastructurePackage>`.
- Package APIs should be used directly when they already fit; do not wrap them decoratively.
- Use `./docs/IOS_UI_STATE_RENDERING_STANDARD.md` as the decision gate before adding a dedicated model/view model to any view.

### Error, Empty, Loading, And Retry States
- Empty, loading, failure, offline, and partial-success states must be distinct when product behavior differs.
- Failures must not clear valid existing content unless explicitly required.
- Retry must not duplicate work or create inconsistent state.
- User-facing errors must be localized and actionable where practical.


### Code Documentation Contracts
- Inline documentation must follow `./docs/IOS_CODE_DOCUMENTATION_STANDARD.md`.
- Document contracts, not obvious code. Prefer better names over comments that repeat code.
- Key types should document purpose, responsibilities, runtime ownership/created-by, and important invariants when lifecycle or boundary usage matters.
- Methods/properties used outside their declaring type should document stable external usage/call context when that helps explain who calls it, when, and why.
- Avoid fragile exhaustive caller lists unless the caller is part of the API contract.
- Side-effecting and async methods should document side effects, concurrency/cancellation, failure behavior, and rollback/pending behavior where relevant.
- Temporary workaround comments must include reason and revisit/expiry condition.
- Comments must not promise thread safety, performance, persistence, or error behavior that the code does not guarantee.

### Security, Privacy, And Logging
- Secrets, tokens, private keys, PII, private URLs, full payloads, and service-account data must not be logged or committed.
- App-group storage, file protection, backups, and external URL opening must be reviewed for sensitive or large data.

### Verification Scope
- Build-only is not enough for behavior, persistence, concurrency, or performance claims.
- Performance-sensitive UI requires manual exercise or Instruments when user allows it.
- Persistence changes require relaunch/migration thinking.
- Network/sync changes require offline/error/retry thinking.
- If tests are out of scope, state the test strategy instead of pretending coverage exists.

## Forbidden Pattern Stop List
These patterns are blocked by default. If a change truly needs one, document the reason before implementation.

### SwiftUI / UI Hot Path
- `UIImage(data:)` in SwiftUI render paths.
- `UIImage(contentsOfFile:)` in SwiftUI render paths.
- `Data(contentsOf:)` in SwiftUI render paths.
- `FileManager` existence/metadata checks in repeated row render paths.
- `PDFDocument(url:)` or PDF thumbnail generation in `body`.
- `AVAssetImageGenerator` frame generation in `body`.
- JSON encode/decode in `body`.
- Database fetch/write in `body`.
- Network calls in `body`.
- Inline sorting/filtering/mapping of large collections in `body`.
- `ForEach(Array(...))` without a concrete identity or collection-shape reason.
- `ForEach(..., id: \.self)` for mutable/domain data where stable identity exists.
- `AnyView` inside repeated rows without measured justification.
- Broad implicit animation on large containers.
- Heavy shadow/blur/material/mask/clip stacks in repeated rows without review/profiling.

### State / Observation
- Passing an entire view model into every row when rows need narrow data and callbacks.
- Creating a view-specific model/view model that only mirrors parent input or forwards simple callbacks.
- Multiple owners for the same state concept.
- Multiple booleans that can represent impossible UI states.
- Silent state fallback that hides real failures.
- Generic `send(action)` as the default ViewModel API when explicit intents are clearer.

### Persistence / Files
- Fetch-all/save-all for single-record interaction updates without a documented current constraint.
- Persisting temporary picker/provider URLs as durable product state.
- Storing full binary media blobs in JSON payloads when durable file references are expected.
- Using `UserDefaults` for product data beyond small preferences/snapshots.
- Removing/migrating persisted fields without migration/decode decision unless the app is explicitly pre-production and the user approves breakage.

### Network / Sync
- Production UI backed by stub JSON or fake backend data.
- Silent fallback to demo/stub/local account data in production runtime.
- Mutations without duplicate-submission/idempotency thinking.
- Sync code that can overwrite local user-created content or local interaction state without explicit policy.
- Logging full request/response payloads, tokens, private URLs, or PII by default.

### Naming / Domain
- `Local*` in domain/UI naming to represent card/content behavior when source does not change product semantics.
- Permanent local-vs-remote branches in UI for the same product entity unless product behavior genuinely differs.
- DTO/backend naming leaking into SwiftUI rows.
- Duplicate model types for one product concept without a clear boundary.

### Code Documentation
- Comments that repeat method/property names without adding contract information.
- `Created by` comments that refer to a human author instead of runtime ownership/lifecycle.
- Exhaustive caller lists that are not part of the stable API contract.
- Temporary workaround comments without reason and revisit/expiry condition.
- Comments claiming thread safety, performance, persistence, or failure behavior not guaranteed by code.

### Architecture
- New protocols/factories/builders/adapters/managers/use cases with no concrete current need.
- App-local wrappers around package APIs that already fit.
- Business rules split accidentally across View, ViewModel, Repository, and package code.
- Marking repositories/services/packages `@MainActor` for UI convenience.

## Severity Policy
- **P0 Blocker**: crash, data loss/corruption, broken core flow, severe jank/main-thread stalls in primary UI, security/privacy leak.
- **P1 Production Risk**: likely performance degradation, incorrect state ownership, broad invalidation, bad persistence/network/sync shape, memory growth, brittle migration.
- **P2 Maintainability Risk**: duplicated concepts, naming confusion, unnecessary abstraction, unclear ownership, hard-to-test structure, hidden coupling.
- **P3 Polish/Consistency**: wording, visual polish, documentation, naming consistency, or cleanup that does not threaten correctness/runtime quality.

## Required Audit/Review Output
For each finding include:

1. Severity: P0/P1/P2/P3.
2. Affected files.
3. Evidence: concrete code pattern, symbol, or path.
4. Why it is a problem.
5. Correct target state.
6. Recommended remediation order.
7. Verification required: static check, build, manual simulator/device, relaunch check, offline check, or Instruments.

## Completion Report Requirements
Every meaningful implementation/review completion must state:

- Files changed or inspected.
- User-facing behavior changed.
- Quality gates/checklist sections applied.
- Verification run.
- Verification intentionally not run.
- Known remaining risks, or `no known remaining risks after checked gates`.
