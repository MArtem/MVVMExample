# iOS Performance Budgets

## Purpose
Defines measurable performance expectations for production iOS work.

Record project-specific budgets and evidence in `./docs/IOS_RELEASE_PRIVACY_PERFORMANCE_MATRIX.md`.
This document supplies the performance rules; it does not set a universal latency, frame or memory
number for every product.

## Default Budgets
Adjust per product/device class when real targets exist.

### Launch
- Cold launch: no unnecessary synchronous network/database/media work before first usable screen.
- Warm launch: restore visible local content quickly; defer refresh.
- Treat cold launch, warm launch, and foreground resume as separate user paths with separate evidence.
- Do not recreate the dependency container, root navigation state, observers, or root ViewModels during normal foreground resume.
- First usable UI may show a minimal shell, but only when it preserves product correctness; do not show meaningless skeletons to hide missing required data.
- Refresh on activation must follow an explicit freshness policy instead of reloading everything on every `.active`.

### Scrolling
- Repeated rows use `ScrollView -> LazyVStack/List -> ForEach -> RowView` or an equivalent virtualized pattern.
- No sync media/file/database/network work in row render paths.
- Scroll callbacks update semantic state only, not every pixel.
- `ForEach` IDs must be stable domain IDs; `.id(UUID())` or index identity in mutable lists is a blocking review finding unless locally justified.
- Recommend Instruments when users report hitching or when feed/list work
  changes; run it only if the user separately delegates performance/runtime
  verification. Otherwise keep the performance claim unverified.

### Main Thread
- No known >250ms main-thread hangs in primary flows.
- The 250ms diagnostic hang signal is not a user-facing responsiveness target; define interaction
  and frame budgets for the actual scenario and device class.
- Heavy parsing, decoding, thumbnail generation, compression, hashing, and DB preparation run off-main.
- No synchronous file, database, network, image decoding, or expensive formatting work in SwiftUI `body`, row builders, `updateUIView`, or view modifiers that run during rendering.
- Repeated presentation values such as formatted dates, filtered lists, sorted sections, and expensive derived strings are prepared outside hot render paths.

### Memory
- Media caches are bounded.
- Full-resolution media is not retained across many rows.
- Repeated navigation/scrolling must not show unbounded growth.
- Screen-specific state must be released with the feature/screen owner; do not keep transient search results, forms, decoded buffers, or opened full-text payloads in app-global stores without a durable ownership reason.
- Long-lived streams and observation tasks must have explicit cancellation ownership and a `deinit`/stop path where applicable.

### Rendering
- Heavy shadows/materials/blur/masks/clips in repeated rows require review/profiling.
- Avoid broad implicit animations on large containers.
- Debounce or throttle high-frequency user input, sensors, timers, search, and local AI/ML inference. Prefer `.task(id:)` for SwiftUI query-driven async work when view lifecycle cancellation is the intended owner.
- Avoid polling when push, event streams, user-triggered refresh, background tasks, or TTL cache can satisfy the product requirement.
- Images must be downsampled to target pixel size before repeated display; compressed file size is not a proxy for decoded memory footprint.

## Measurement Rule
Use the cheapest evidence that can prove the claim, but do not claim real-user launch, energy, memory, or hitch performance from Simulator-only evidence.

Preferred evidence:
- Instruments templates relevant to the bottleneck: App Launch, SwiftUI, Time Profiler, Core Animation, Allocations, Leaks, VM Tracker, Power Profiler.
- Xcode Organizer and MetricKit for real-user launch, hang, memory, energy, and crash trends.
- Use only currently authorized evidence. Under `CURRENT_USER_OVERRIDES.md`, omit iPad, physical-device and actual VoiceOver checks from plans and acceptance. Preserve historical results, mark excluded coverage `OMITTED_BY_USER`, and state the resulting evidence gap. Simulator evidence does not establish hardware performance.

Optimization loop:
1. Measure or identify a concrete static hot-path risk.
2. Fix the smallest root cause.
3. Re-measure or state the remaining evidence gap.

## Required Performance Report
State:
1. Scenario tested.
2. Device/simulator.
3. Tool used.
4. Metrics observed.
5. Remaining risk if profiling was not possible.
6. Interaction latency, frame/hitch result, memory result and the project budget they were compared
   with, when those axes are applicable.
