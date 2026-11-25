# iOS Concurrency Runtime Standard

## Purpose
Prevent data races, main-thread stalls, unbounded tasks, and lifecycle leaks in iOS apps.

## Addressed Deep Reading

This standard owns the operating rules below. The [deep reference](knowledge/global/ios/SWIFT_CONCURRENCY_DEEP_REFERENCE.md)
explains their application; its distribution mirror has the same authority as the canonical knowledge source.
After this standard, select sections by the actual task:

| Task | Required deep sections |
| --- | --- |
| Task lifetime, cancellation or stale publication | Core Model; Task Ownership; Cancellation; Ordering And Stale Results |
| Actor ownership or cross-actor transfer | Core Model; Isolation Design; Swift 6.x Discipline |
| Callback/continuation bridge | Core Model; Task Ownership; Cancellation; Continuations And Callbacks |
| Reactive/legacy queue bridge | Core Model; Task Ownership; Cancellation; Reactive And Queue Bridges; Isolation Design |
| Async stream or fan-out | Core Model; Task Ownership; Cancellation; Streams |
| Compiler/language-mode migration | Core Model; Isolation Design; Swift 6.x Discipline |

Combine rows when the scope crosses concerns. Read Testing And Evidence when selecting verification;
its checks remain permission-bounded. Read the complete reference for cross-cutting concurrency design
or when state ownership/order remains ambiguous after the selected sections. Reopen only newly relevant
sections after a scope change; an omitted relevant requirement is not PASS. This selection changes reading,
not the required engineering guarantees or build/test authority.

## Conditional Practical Mechanism

For replacement/cancellation publication unresolved after those sections, select
[Invocation Publication Practical Slice](knowledge/global/ios/SWIFT_CONCURRENCY_DEEP_REFERENCE.md#invocation-publication-practical-slice).
For review, stop before Illustrative Owner Example; expand it for implementation or a specific
unresolved mechanism question. Apply its negative controls and evidence limits; no second normative pass or verification permission.

## Required Rules
- UI state mutations happen on the main actor.
- Long-running file, media, crypto, database, parsing, and CPU-bound work must not run on the main actor. An asynchronous wait and CPU-bound work require different reasoning; `async` alone does not prove a background executor.
- Every `Task` must have an owner, cancellation policy, and lifecycle reason.
- Prefer structured concurrency. Use detached tasks only for clear non-main utility work and document why actor inheritance is not wanted.
- Avoid fire-and-forget work for user-visible operations unless failure is intentionally non-blocking and observable.
- Do not capture `self` in async work without checking owner lifetime and cancellation.
- Swift 6 warnings must be treated as future production failures, not cosmetic noise.
- Record compiler version, Swift language mode, strict-concurrency settings, default actor isolation, and upcoming features separately when diagnostics or behavior depend on them.
- `@MainActor` is valid for UI-facing state when ownership requires it; do not flag it merely because it is MainActor-isolated.
- Swift 6.2 default MainActor isolation and `@concurrent` are profile-selected toolchain features, not universal defaults. See `./docs/IOS_TOOLCHAIN_PROFILE_STANDARD.md`.

## Review Checklist
- Which actor owns the state?
- Can the task outlive the screen/session/object?
- What cancels the work?
- Is any heavy work accidentally inherited by `@MainActor`?
- Are sendability boundaries explicit?
- Are callbacks bridged to async/await safely?

## Stop Rules
- No unbounded recurring task without cancellation.
- No main-actor media/file/database loop.
- No silence around cancellation/failure for user-visible work.
