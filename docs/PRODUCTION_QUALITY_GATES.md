# Production Quality Gates

## Purpose
This document defines mandatory production-quality review gates for any `<AppName>` implementation, refactor, review, or cleanup.

These gates are intentionally broader than the current app surface. They apply to future features as the project grows.

## Core Rule
A change is not production-ready just because it compiles or matches the visible UI. It must also be safe for runtime performance, state ownership, persistence correctness, memory, networking, error handling, accessibility, and future maintenance.

When reviewing or implementing code, explicitly check the relevant gates below. If a gate is skipped because it is not relevant, say so in the task notes. Apply `./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md` together with this file; its forbidden-pattern stop list is blocking by default.

## Universal Definition Of Done
Every non-trivial code change must answer:

1. What user-facing behavior changed?
2. What runtime path is affected?
3. What state owns the behavior?
4. What can happen on slow devices, bad network, large data, low memory, or app relaunch?
5. What work runs on the main actor/main thread?
6. What invalidates SwiftUI views and how wide is the redraw scope?
7. What data is persisted, cached, logged, or sent over the network?
8. What verification was run, and what was intentionally not run?
9. What risks remain?

## Stop-The-Line Rules
Stop and fix or escalate before continuing if any of these appear:

- File I/O, decoding, database fetch/write, network request, PDF/video/image generation, sorting large data, or expensive parsing inside SwiftUI `body`, row builders, layout callbacks, animations, gestures, or scroll callbacks.
- A single row/item update rebuilds or republishes an entire screen collection without a clear reason.
- UI state is stored in multiple owners without a documented source of truth.
- A repository, package, or service is marked `@MainActor` only because UI code is calling it conveniently.
- User data, credentials, tokens, private file paths, API payloads, or PII are printed or logged without sanitization.
- A feature depends on temporary picker URLs, security-scoped URLs after release, or external provider availability after relaunch.
- A network/backend error destroys local user data or local interaction state.
- A new abstraction is introduced without one concrete current pain point.
- A review says “looks good” without checking performance hot paths, state invalidation, persistence/network side effects, and failure states.

## Architecture And Ownership Gate
Check:

- App-specific product policy stays in `<AppName>`.
- Reusable, entity-agnostic mechanics belong in `./Packages/<ReusableInfrastructurePackage>`.
- DTO/domain/UI models are not collapsed unless the type is truly local and trivial.
- View code does not own business rules, persistence policy, retry policy, or backend mapping.
- View models expose explicit state and explicit intents; avoid generic catch-all action dispatch by default.
- Protocols exist only at real seams: package boundaries, test seams requested by task, alternate runtime backends, or integration boundaries.
- No decorative Factory/Builder/Adapter/UseCase layer without current pressure.
- No God ViewModel, God Manager, or hidden singleton dependency.

Required outcome: explain ownership in one sentence for any new non-trivial type.

## SwiftUI Rendering Gate
Check:

- `body` is cheap, deterministic, and side-effect free.
- Computed properties used by `body` are cheap or precomputed.
- Views receive narrow immutable inputs where possible, not whole global view models.
- Large environment objects are not read by many rows if only one scalar is needed.
- Expensive subtrees are extracted and can be skipped by SwiftUI diffing.
- `ForEach` uses stable unique identity and a constant number of top-level views per element.
- Avoid `AnyView` in repeated rows unless there is a measured reason.
- Avoid inline filtering/sorting/mapping of large collections in `body`.
- Avoid layout feedback loops: geometry/preference updates must only write state when threshold/value actually changes.
- Buttons are used for user actions instead of `onTapGesture` unless tap location/count is required.

Hard bans in hot paths:

- `UIImage(data:)`, `UIImage(contentsOfFile:)`, `Data(contentsOf:)`, `FileManager` checks, `PDFDocument(url:)`, `AVAssetImageGenerator`, JSON encode/decode, database fetch/write, and network calls inside SwiftUI render paths.

## Scroll/List/Grid Performance Gate
Applies to every scrollable list, feed, carousel, grid, picker result, message list, gallery, timeline, table, or search result.

Check:

- Use lazy/recycling containers appropriate to the data size and UI requirements.
- Row height is stable or intentionally bounded; avoid unpredictable layout thrash.
- Media thumbnails are precomputed or loaded asynchronously with cancellation.
- Scroll callbacks emit threshold changes, not per-pixel state updates.
- Search/filter/sort results are precomputed on state changes, not during every row render.
- One item update must not invalidate unrelated rows unless product behavior requires it.
- Pagination/incremental loading has backpressure and cancellation.
- Placeholder and loaded states have the same approximate size to avoid scroll jumps.
- Pull-to-refresh does not block scrolling or clear already visible local data unnecessarily.

Required outcome: for performance-sensitive screens, state whether smooth scroll was statically reviewed, manually exercised, or profiled.

## State And Observation Gate
Check:

- There is one source of truth per state concept.
- UI-only ephemeral state stays local to the view when possible.
- Shared feature state is owned above consumers and injected down.
- `@Observable`/Observation dependencies are narrow; views should not observe broad objects accidentally.
- State writes are deduplicated: do not set the same value repeatedly in hot paths.
- Async tasks cannot race stale state into current UI.
- Navigation, modal, selection, loading, error, and content states are explicit.
- Derived state is either cheap or cached with clear invalidation points.

Red flags:

- Multiple booleans that can represent impossible combinations.
- One `State` blob passed everywhere while rows need only one field.
- View models that both format UI and own persistence/network mechanics.

## Concurrency And Threading Gate
Check:

- Main actor is reserved for UI state and APIs that require it.
- Heavy work runs off-main: parsing, decoding, hashing, image/video/PDF processing, compression, encryption, large filtering/sorting, database preparation.
- Async work has cancellation and stale-result protection.
- Tasks started by views use `.task(id:)` when tied to identity and are safe to cancel.
- Long-running operations expose progress or non-blocking UI states.
- Shared mutable state is actor-isolated, value-isolated, or otherwise synchronized.
- Avoid unbounded task creation in loops, scroll callbacks, gestures, or row appearance.

Required outcome: identify which actor/thread owns each new async path.

## Persistence And Database Gate
Check:

- Persist only durable data, not transient UI/rendering objects.
- Local-first product data survives app relaunch and offline usage.
- Writes are scoped: update the specific record(s), not full-table/full-feed by default.
- Reads are scoped, sorted, and limited where appropriate.
- Large payloads are not repeatedly encoded/decoded on main-thread interaction paths.
- Schema changes consider migration/backward compatibility.
- Persistence errors do not silently destroy in-memory user work.
- Optimistic UI updates are reconciled with persistence failures intentionally.
- File references are durable app-owned copies, not temporary picker/provider references.
- Cache data is separated from source-of-truth data and can be regenerated.

Red flags:

- Fetch all records before every single-record update.
- Store full binary media blobs in JSON payloads when file references are expected.
- Use `UserDefaults` for product data beyond small preferences/snapshots.

## Network And Sync Gate
Check:

- Network code has timeout, cancellation, retry/backoff policy, and error mapping appropriate to product risk.
- UI does not block on network when local data can remain visible.
- Request/response DTOs are mapped at boundaries; backend shape does not leak into SwiftUI rows.
- Offline, poor connection, auth expiration, partial failure, and server validation errors are handled.
- Mutations are idempotent or have clear duplicate-submission protection.
- Sync preserves local-only data and local interaction state unless backend explicitly owns newer state.
- Background retries have bounded queues and observable failure states.
- Logs redact tokens, credentials, PII, private URLs, and full payloads by default.

Required outcome: for new network paths, document offline and retry behavior.

## Models And Data Mapping Gate
Check:

- Model identity is stable and unique.
- Equatable/Hashable identity does not hide meaningful UI changes.
- UI models are shaped for rendering and do not perform I/O.
- Domain models express product invariants; invalid states are hard to construct where practical.
- DTOs are isolated to API boundaries.
- Codable compatibility is considered when persisted JSON payloads change.
- Date, locale, currency, timezone, and unit handling are explicit.
- Optional fields have product-defined fallback behavior, not random UI guesses.

Red flags:

- `id` derived from non-unique URL/title/text.
- Adding fields to persisted models without decode defaults/migration thinking.
- Business rules duplicated in model, view model, and view.

## Memory, Media, And Cache Gate
Check:

- Images are downsampled to target display size before rendering.
- Video/PDF previews are generated asynchronously and cached.
- Caches are bounded and respond to memory pressure where possible.
- Full-resolution media is not retained in many rows.
- Temporary files have lifecycle management.
- App-owned media storage has predictable directory ownership and cleanup policy.
- Large arrays/dictionaries are not copied repeatedly in hot paths.
- Closures in long-lived objects do not retain view models or coordinators accidentally.

Required outcome: identify source-of-truth storage vs regenerable cache for every new media artifact.

## Visual Rendering And UI Polish Gate
Check:

- Shadows, blurs, masks, materials, gradients, blend modes, and clipping are reviewed for repeated-row cost.
- Heavy visual effects are avoided in large scrolling collections unless profiled.
- Placeholder, loading, empty, error, and content states are visually stable.
- Dynamic Type and text wrapping do not break layout.
- Tap targets are at least platform-appropriate and do not conflict with nested actions.
- Interactive controls do not accidentally trigger parent gestures.
- Animations are bounded and tied to explicit values; no implicit broad animation on large containers.
- Accessibility labels/traits are present for non-obvious controls.
- Localization does not concatenate user-visible grammar-sensitive strings unless acceptable for target languages.

## Error Handling And Resilience Gate
Check:

- Errors are categorized: user-actionable, retryable, silent recoverable, programmer error.
- User-facing errors are localized and actionable where possible.
- Failure does not erase valid existing content unless product explicitly requires it.
- Empty states are distinct from loading and failure states.
- Retry paths do not duplicate work or create inconsistent state.
- Assertions are not the only runtime error handling for recoverable production failures.

## Security, Privacy, And Logging Gate
Check:

- Secrets, tokens, private keys, provisioning data, service-account data, and user PII are never committed or logged.
- Logs are redacted and appropriate for production diagnostics.
- App group storage is scoped to intended data only.
- File protection and backup behavior are considered for sensitive or large data.
- External URLs are validated before open/dispatch.
- Clipboard, pasteboard, contacts, location, photos, microphone, camera, and file-provider access are user-initiated and permission-aware.

## Testing And Verification Gate
Check:

- The verification level matches the risk level.
- Build-only is not enough for behavior, persistence, concurrency, or performance claims.
- Performance-sensitive UI needs manual exercise or Instruments when the user allows it.
- Persistence changes need relaunch/migration thinking.
- Networking/sync changes need offline/error/retry scenarios.
- Tests are not touched unless explicitly in scope for this task, but test strategy must be stated for risky changes.

Minimum report fields after meaningful work:

- Files changed.
- Behavior changed.
- Quality gates checked.
- Verification run.
- Verification not run.
- Known risks or “no known remaining risks after checked gates”.

## Review Gate
When the user asks for review/refactor/cleanup, the review must explicitly cover:

1. Correctness and product contract.
2. Architecture and ownership.
3. SwiftUI invalidation/rendering scope.
4. Main-thread and concurrency risks.
5. Persistence/database access patterns.
6. Network/sync/offline behavior if relevant.
7. Memory/cache/media handling.
8. Visual rendering cost and interaction polish.
9. Error/empty/loading/retry states.
10. Security/privacy/logging.
11. Verification gaps.

Do not return a purely stylistic review if runtime hot-path issues exist.

## Severity Classification
Use this severity model:

- **P0 Blocker**: crash, data loss, broken core flow, severe jank, main-thread stalls in primary UI, security/privacy leak.
- **P1 Production Risk**: likely performance degradation, incorrect state ownership, broad invalidation, bad persistence/network shape, memory growth, brittle migration.
- **P2 Maintainability Risk**: duplication, naming confusion, unnecessary abstraction, unclear ownership, hard-to-test structure.
- **P3 Polish**: visual/wording cleanup that does not threaten correctness or runtime quality.

P0/P1 must be surfaced immediately and fixed before cosmetic work unless the user explicitly chooses otherwise.
