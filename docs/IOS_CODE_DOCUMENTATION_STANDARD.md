# iOS Code Documentation Standard

## Purpose
Define a unified, low-noise standard for documenting Swift/iOS code contracts directly in code.

## Core Principle
Document contracts, not obvious code.

A comment is required when a future developer or AI agent could misuse the type, method, property, or flow without understanding ownership, usage context, side effects, concurrency, errors, invariants, or rationale.

## Default Project Documentation Scope
When the user asks to add, improve, refresh, or review code documentation for a project and does not specify exact files, the scope is the whole project.

Treat that as an inventory and completion target, not permission for an
unbounded edit. Apply the current small-batch, source-file, token-budget,
test, and build authority limits; seek the required scope decision before a
larger implementation block. Report a bounded partial pass honestly and
retain the remaining-file inventory rather than claiming project-wide
completion.

Every logically significant executable source file must contain contract-level code documentation for its primary responsibility. This applies to Swift files that define or coordinate app behavior, UI behavior, state ownership, navigation, persistence, services, platform capabilities, scripts, reusable package code, or build/runtime tooling.

The required minimum is:
- each significant file documents its main type, owner, or file-level responsibility;
- each ViewModel/state owner/service/repository/store/actor/coordinator/router documents purpose, responsibilities, ownership/lifecycle, and relevant invariants;
- each async, side-effecting, persistence, file, network, navigation, privacy, or platform-capability entry point documents behavior plus concurrency/cancellation/error or failure behavior where relevant;
- project documentation files explain scope, ownership, and source-of-truth placement.

Trivial private helpers, generated files, pure data literals, simple view fragments, and self-evident one-line glue may remain undocumented only when a better name or surrounding documented type makes the contract obvious. This is an exception, not the default.

Therefore:
- “add documentation to the project” means “document all significant executable files and project documentation surfaces”;
- “add comments” means “add contract comments everywhere they are required by this standard”, not only in the currently edited file;
- partial documentation passes must be reported as partial, with the remaining files listed as follow-up work.

## What To Document
Document these by default:
- public/internal protocols and APIs
- ViewModels and state owners
- repositories, stores, caches, sync services, clients, managers
- mappers and boundary translators
- actors and thread-safe components
- navigation/router/coordinator entry points
- async methods and task owners
- methods with side effects
- computed properties read in UI/render hot paths
- persistence records or migration-sensitive models
- platform capability wrappers: Bluetooth, Camera, Photos, Files, Location, Push, App Groups, StoreKit
- non-obvious SwiftUI views or reusable UI components
- temporary workarounds and compatibility bridges

Do not document obvious private helpers, trivial properties, or code where a better name would remove the need for a comment.

## Required Comment Dimensions
Use only the dimensions that are relevant. Do not force every block into every comment.

### Purpose
Why the entity exists.

### Responsibilities
What it owns and what it explicitly does not own.

### Ownership / Created By
Who owns or creates the entity in runtime terms.

Use stable ownership descriptions:
- screen composition layer
- dependency container
- repository
- sync scheduler
- platform delegate
- app lifecycle owner
- feature coordinator

Do not use personal authorship or fragile implementation facts.

Good:
```swift
/// Ownership:
/// Created by the feed composition layer. One instance is owned by one feed screen flow.
```

Avoid:
```swift
/// Created by Artem.
/// Created by `SomeView`.
```

A concrete caller/type may be named only when it is part of the actual API contract and expected to remain stable.

### External Usage / Call Context
For methods/properties used outside their declaring type, document who may call them and when.

Prefer scenario-based call context over brittle exhaustive caller lists.

Good:
```swift
/// External usage:
/// Called by user-triggered refresh flows such as pull-to-refresh and retry.
```

Good when the caller is contractual:
```swift
/// External usage:
/// Called by `UIApplicationDelegate` during remote notification registration callbacks.
```

Avoid:
```swift
/// Called by FeedView, HomeView, SearchView.
```

### Behavior
Important state transitions, loading/refresh/error/offline/retry behavior.

### Side Effects
State, cache, database, file, network, navigation, analytics, sync, device connection, or permission effects.

### Concurrency
Actor isolation, main-thread expectations, task ownership, cancellation, stale-response handling, thread safety.

### Errors / Failure Behavior
Thrown errors, non-throwing failure presentation, retry behavior, rollback behavior.

### Invariants
Rules that must always remain true.

### Rationale
Why the implementation uses this shape when it is not obvious.

### Temporary Workaround / Expiry
Temporary comments must include reason and revisit condition.

Good:
```swift
/// Temporary workaround:
/// SwiftData `#Predicate` currently produces Swift 6 warnings for this model.
/// Revisit after upgrading the Xcode toolchain.
```

## Templates

### Type / ViewModel / Service
```swift
/// Owns presentation state and user actions for the feed screen.
///
/// Responsibilities:
/// - prepares visible content;
/// - handles user-triggered actions;
/// - keeps UI state isolated on the main actor.
///
/// Ownership:
/// Created by the screen composition layer. One instance is owned by one screen flow.
///
/// Important:
/// DTO and persistence models must not be exposed from this type.
@MainActor
final class FeedViewModel {
}
```

### Method With External Usage
```swift
/// Refreshes current content without replacing it with a full-screen loader.
///
/// External usage:
/// Called by user-triggered refresh flows: pull-to-refresh and non-blocking retry.
///
/// Behavior:
/// - preserves current content while refresh is running;
/// - replaces content on success;
/// - keeps old content and reports failure on error;
/// - ignores `CancellationError`.
func refresh() async {
}
```

### Computed Property In UI Hot Path
```swift
/// Precomputed cards visible in the current feed state.
///
/// This value must stay cheap to read because SwiftUI may access it during
/// body evaluation. Expensive filtering/sorting must happen when inputs change.
var visibleContent: FeedVisibleContent {
    currentVisibleContent
}
```

## Review Checklist
Before adding a comment, ask:
- Has every significant executable file in the requested scope received contract-level documentation or an explicit trivial-file rationale?
- Does this explain a contract rather than repeat code?
- Is ownership/lifecycle unclear without it?
- Is this API used outside its declaring type?
- Are side effects or failure behavior non-obvious?
- Are concurrency/cancellation/thread-safety rules important?
- Is there an invariant or rationale that future edits could break?
- Will this comment stay true if a concrete caller changes?

## Stop Rules
- Do not document every method mechanically, but do document every significant executable file's contract surface.
- Do not duplicate the method name in prose.
- Do not list fragile callers unless the caller is contractual.
- Do not claim thread safety, performance, or failure behavior that code does not guarantee.
- Do not leave temporary workaround comments without reason and revisit condition.
