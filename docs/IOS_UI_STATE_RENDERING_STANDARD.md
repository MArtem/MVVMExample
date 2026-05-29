# iOS UI State And Rendering Standard

## Purpose
Make SwiftUI/UIKit UI predictable, performant, accessible, and maintainable.

## Required Rules
- Repeated rows receive narrow immutable input and explicit callbacks, not broad global state unless justified.
- Derived presentation state should be precomputed or memoized when it is read in hot paths.
- `ScrollView` + `LazyVStack`/`LazyHStack`/`LazyVGrid` lists should expose repeated items directly to the lazy container.
- Use stable identity; never use unstable indices for persisted/user-interactive rows.
- Avoid side effects in `body`, layout callbacks, and computed view properties.
- Avoid broad animations without a specific `value` and review repeated shadows, blurs, masks, and clips.
- Keep empty/loading/error/offline/permission states explicit.


## View Model Ownership Decision Rule
A SwiftUI view should not receive its own model or view model by default. Start with immutable input state plus explicit callbacks, then promote to a dedicated state owner only when the view has a concrete lifecycle or ownership problem that cannot be handled cleanly by the parent feature state.

Use this decision rule for any screen, section, row, card, reusable component, sheet, toolbar, media preview, form section, widget surface, or extension UI:

### Default Shape
- The parent feature state owner prepares presentation state.
- The child view receives narrow immutable state and explicit callbacks.
- The child view renders and forwards user intent; it does not own repositories, persistence, networking, cache, or product policy.

### A Dedicated Model/ViewModel Is Justified When
At least one current requirement is true:

1. The view owns an async lifecycle that must start, cancel, retry, or ignore stale results independently from the parent.
2. The view owns long-lived local state that must survive body recomputation and is not just simple SwiftUI interaction state.
3. The view subscribes to external events such as player state, device/peripheral state, upload progress, sync status, live comments, notifications, timers, or sensors.
4. The view has isolated error/retry/rollback behavior that should not invalidate or complicate the parent state owner.
5. The view performs editable or transactional work with validation, save/cancel, pending changes, or dirty-state tracking.
6. The view owns media/runtime resources such as playback, thumbnail generation, camera/session handling, Bluetooth connection state, file import progress, or cache warming.
7. The view is reused across multiple feature owners and needs a stable, documented contract that is larger than simple input state plus callbacks.

### A Dedicated Model/ViewModel Is Not Justified When
- The view only formats and renders already prepared state.
- The view only forwards taps, gestures, or field changes to a parent.
- The view model would only mirror its input properties.
- The goal is only to reduce the size of a SwiftUI body; extract a pure subview instead.
- The goal is architecture symmetry or pattern consistency without a concrete lifecycle/state ownership need.

### Target State
Prefer this progression:

1. `View` with narrow immutable input and callbacks.
2. `ViewState` prepared by the parent state owner for non-trivial presentation decisions.
3. Dedicated component model/view model only when the component has independent lifecycle, async work, subscriptions, transactional editing, or resource ownership.

If a dedicated model/view model is introduced, document its ownership, creation point, external usage/call context, side effects, cancellation/error behavior, and invariants according to `./docs/IOS_CODE_DOCUMENTATION_STANDARD.md`.

## Review Checklist
- What state change invalidates this view?
- Which rows redraw for one item update?
- Is any map/sort/filter/formatting happening during render?
- Are gesture targets accessible and deterministic?
- Does layout stay stable while async content loads?

## Stop Rules
- No heavy sync work in render path.
- No hidden eager rendering inside an opaque section wrapper for large feeds/lists.
- No production screen without explicit failure/empty state.
