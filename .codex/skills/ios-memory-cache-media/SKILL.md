---
name: ios-memory-cache-media
description: Use this skill for iOS memory/cache/media work involving images, video, audio, PDFs, files, thumbnail generation, downsampling, memory pressure, cache eviction, large files, and scroll media performance. Trigger whenever memory, cache, media, thumbnail, file, image, video, audio, PDF, or downsampling is mentioned.
---

# iOS Memory Cache Media

## Workflow
1. Identify every media/file decode/load path.
2. Separate render hot paths from background/cache preparation.
3. Check cache identity, memory limit, eviction, invalidation, and cleanup.
4. Check file ownership, retention, protection, and relaunch durability.
5. Require profiler/manual evidence for smooth-scroll or memory claims.

## References
- `./docs/IOS_MEMORY_CACHE_MEDIA_STANDARD.md`
- `./docs/IOS_PERFORMANCE_BUDGETS.md`
