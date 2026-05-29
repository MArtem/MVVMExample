# Production Review Completeness Gate

## Purpose
This gate prevents narrow reviews that only check the latest bug or the most obvious implementation risk.

When the user asks for **review**, **ревью**, **code review**, **аудит**, or asks whether code is production-ready, the agent must run this gate before saying that everything is correct.

## Trigger Rule
The word **ревью** from the user means:

1. Do not perform a narrow review only around the current bug.
2. Run the full production-grade review prompt from `./docs/agent-prompts/production-review-completeness.md`.
3. Apply `./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md` and `./docs/PRODUCTION_QUALITY_GATES.md`.
4. If any area cannot be proven safe from code/static evidence, report it as a **remaining risk** or ask the user a question.

## Mandatory Completeness Checks
Before responding with “всё ок”, “clean”, “готово”, “production-ready”, or equivalent, verify these areas:

### UI Structure
- Repeated rows in big scrollable screens follow `ScrollView -> LazyVStack/List -> ForEach -> RowView`.
- No opaque wrapper hides repeated rows from the lazy container.
- No nested non-lazy repeated layout breaks virtualization.
- No helper view, `AnyView`, `Group`, `GeometryReader`, or preference pipeline creates hidden repeated layout cost.

### Render Hot Path
- No sync file/media/network/database work in SwiftUI `body` or row render paths.
- No image/video/PDF decoding or thumbnail generation in `body`.
- No expensive formatting, map/filter/sort, JSON encode/decode, or large collection copying in `body`.

### State Invalidation
- Rows receive narrow immutable data and callbacks, not broad screen/root view models unless justified.
- Single-row interactions do not invalidate the whole feed/screen without a concrete reason.
- Scroll callbacks update state only on semantic edge changes, not every pixel.

### Data Identity And Domain Shape
- `id` values are stable.
- Product/domain/UI naming does not encode local-vs-remote/source splits unless product behavior differs.
- Persistence DTOs and backend DTOs do not leak into UI row contracts.

### Persistence And Files
- Single-item updates are scoped to the affected record.
- No fetch-all/save-all for single interactions without documented current constraint.
- No main-thread I/O in UI interaction paths.
- Durable media/file ownership and cleanup are explicit.

### Network And Sync
- Production UI is not backed by stub/demo JSON.
- No silent demo/local fallback in production runtime.
- Offline, retry, auth expiration, duplicate submission, and local-data preservation are considered where relevant.

### Concurrency And Memory
- Heavy work is off-main.
- Tasks are bounded/cancellable where views can disappear.
- Media caches are bounded and separate from source-of-truth data.
- Full-resolution media is not retained across many rows.

### Navigation And Side Effects
- Navigation state has a single owner.
- Deep links/menu/root composition do not depend on fragile UI implementation details.
- SwiftUI `body` has no hidden side effects.


### Code Documentation
- Relevant code comments follow `./docs/IOS_CODE_DOCUMENTATION_STANDARD.md`.
- Contracts, ownership/lifecycle, external usage/call context, side effects, concurrency, errors, invariants, and rationale are documented where they prevent misuse.
- Comments do not repeat obvious code or list fragile callers.
- Temporary workarounds have reason and revisit/expiry condition.

### Verification Honesty
- Build/static checks do not prove behavior or performance.
- Scroll/UI performance requires simulator/device exercise or Instruments when user allows it.
- Persistence changes require relaunch/migration reasoning.
- If verification was not run, state it explicitly as remaining risk.

## Required Review Output
Every production review must include:

1. **Scope**: files/folders inspected and exclusions.
2. **Checklist result**: each mandatory area marked checked, not applicable with reason, or remaining risk.
3. **Findings**: P0/P1/P2/P3 with affected files, evidence, why it is a problem, target state, remediation order, and verification required.
4. **Clean claim rule**: only say “no known remaining risks” after every relevant area is checked or explicitly not applicable.

## Stop Rule
If the agent is not sure whether behavior, ownership, or product intent is correct, the agent must not guess. It must ask the user or report the uncertainty as a remaining risk.
