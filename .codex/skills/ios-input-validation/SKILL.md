---
name: ios-input-validation
description: Use this skill for iOS input validation and content safety involving file imports, share extensions, document picker, photos, camera, clipboard, URL schemes, universal links, push payloads, backend text, Markdown/HTML rendering, and temporary file cleanup. Trigger whenever imported content, file validation, external URL, clipboard, push payload, or content safety is mentioned.
---

# iOS Input Validation

## Workflow
1. Treat external files, URLs, payloads, clipboard, and backend text as untrusted.
2. Check type/size/count/duration/dimension/encoding limits.
3. Check URL scheme allowlists and safe rich-text rendering.
4. Check file storage, protection, cleanup, and corrupt-file behavior.
5. Report manual/device validation needed for permissions/import flows.

## References
- `./docs/IOS_INPUT_VALIDATION_CONTENT_SAFETY_STANDARD.md`
- `./docs/IOS_CAMERA_PHOTOS_FILES_PERMISSIONS_STANDARD.md`
