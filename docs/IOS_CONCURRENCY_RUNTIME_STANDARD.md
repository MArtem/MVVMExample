# iOS Concurrency Runtime Standard

## Purpose
Prevent data races, main-thread stalls, unbounded tasks, and lifecycle leaks in iOS apps.

## Required Rules
- UI state mutations happen on the main actor.
- Long-running file, media, crypto, database, parsing, and network work must not run on the main actor.
- Every `Task` must have an owner, cancellation policy, and lifecycle reason.
- Prefer structured concurrency. Use detached tasks only for clear non-main utility work and document why actor inheritance is not wanted.
- Avoid fire-and-forget work for user-visible operations unless failure is intentionally non-blocking and observable.
- Do not capture `self` in async work without checking owner lifetime and cancellation.
- Swift 6 warnings must be treated as future production failures, not cosmetic noise.

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
