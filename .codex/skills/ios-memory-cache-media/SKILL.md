---
name: ios-memory-cache-media
description: Review or change iOS media decoding/loading, cache policy, file lifecycle, memory pressure, or related performance; not for a simple image or file mention.
---

# iOS Memory Cache Media

## Workflow
1. Identify the affected media/file decode, load, storage, or cache path and its consumers.
2. Check relevant render hot paths, background preparation, cache limits/eviction, and cleanup.
3. For durable files, check ownership, retention, protection, and relaunch behavior.
4. Require profiler/manual evidence for smooth-scroll or memory claims; report it as unverified when not authorized.

## References
Resolve `DOC:` identifiers through the active task router in canonical
`reusable/baseline/docs/` or the project-root `docs/` mirror, not relative to this skill.
- `DOC:IOS_MEMORY_CACHE_MEDIA_STANDARD.md`
- `DOC:IOS_PERFORMANCE_BUDGETS.md`
