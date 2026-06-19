# iOS Memory, Cache, And Media Standard

## Purpose
Keep memory bounded and scrolling responsive when handling images, video, audio, PDFs, files, and caches.

## Required Rules
- Decode/downsample media before display; never keep unnecessary full-resolution assets in repeated UI rows.
- Cache by stable identity and size class, not by transient view lifecycle.
- Define memory limit, eviction behavior, and invalidation triggers for every cache.
- Avoid synchronous media/file work in SwiftUI `body`, repeated rows, layout callbacks, and gesture paths.
- Use placeholders with stable dimensions to avoid layout jumps.
- Release media players, observers, image buffers, and thumbnails when no longer needed.
- Large files must have ownership, retention, cleanup, and file-protection policy.

## Review Checklist
- What is the maximum memory retained?
- What happens after memory pressure?
- Is the thumbnail size bounded?
- Is full media loaded only when necessary?
- Can repeated scrolling create duplicate decode work?
- Are PDF/video thumbnails generated off the hot path?

## Required Verification
- Scroll trace for media-heavy lists.
- Memory graph or allocations check for repeated open/close flows.
- Relaunch check for persistent media references.
