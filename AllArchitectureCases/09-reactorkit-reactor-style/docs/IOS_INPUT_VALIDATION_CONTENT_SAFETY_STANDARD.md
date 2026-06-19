# iOS Input Validation And Content Safety Standard

## Purpose
Make user input, imported files, URLs, and external content safe and predictable.

## Required Rules
- Validate size, type, count, duration, dimensions, encoding, and source for imported files/media.
- Treat share extension, document picker, clipboard, URL scheme, universal link, push payload, and backend text as untrusted input.
- Sanitize or safely render HTML/Markdown/rich text.
- External URLs require scheme allowlist and product-defined open behavior.
- Imported content must define storage location, file protection, cleanup, and failure behavior.

## Review Checklist
- What is the maximum accepted input size?
- What happens with corrupt or unsupported files?
- Can a URL open an unsafe scheme?
- Can untrusted text break layout or accessibility?
- Are temporary files cleaned up?
