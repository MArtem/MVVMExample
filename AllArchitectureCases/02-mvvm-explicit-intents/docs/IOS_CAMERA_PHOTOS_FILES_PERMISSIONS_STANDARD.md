# iOS Camera, Photos, Files, And Permissions Standard

## Purpose
Keep privacy-sensitive platform access clear, resilient, and App Store safe.

## Required Rules
- Every permission needs product justification, Info.plist copy, denied/restricted behavior, and recovery path.
- Use least-privilege access: limited photo library, security-scoped resources, scoped file copies when appropriate.
- Do not assume permission state is stable; it can change outside the app.
- Imported files/media require validation, durable storage, cleanup, and file protection.
- Permission prompts should follow user intent, not appear unexpectedly on launch.

## Review Checklist
- What happens when permission is denied, restricted, limited, or revoked?
- Is the reason string user-facing and localized?
- Are security-scoped resources accessed/released correctly?
- Are temporary files cleaned?
