---
name: ios-performance-profiler
description: Use this skill for iOS performance investigations, scroll jank, launch slowness, memory growth, SwiftUI hot paths, Instruments traces, hitches, hangs, media decoding, caching, and comparing before/after metrics. Trigger whenever the user mentions profiler, Instruments, lag, jank, FPS, memory, launch time, or performance metrics.
---

# iOS Performance Profiler

## Workflow
1. Define the scenario and expected user interaction.
2. Check source for known hot-path violations before profiling.
3. Select verification: static review, simulator profiling, real-device profiling, or manual QA.
4. Prefer real device for SwiftUI/performance truth; simulator is useful but limited.
5. Compare before/after using the same scenario and device.
6. Report failed captures honestly; do not infer metrics from invalid traces.

## Review Areas
- SwiftUI body and repeated rows.
- Lazy list structure and identity.
- Scroll callbacks and state updates.
- Main-thread media/file/db/network work.
- Memory/cache bounds.
- Heavy rendering effects.

## Output
- Scenario.
- Tool/device.
- Metrics/evidence.
- Findings P0-P3.
- Next measurements.

## References
- `./docs/IOS_PERFORMANCE_BUDGETS.md`
- `./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`
