# iOS Input Validation And Content Safety Review Prompt

Use this for imports, external URLs, share extensions, files, rich text, push payloads, and untrusted backend content.

## Prompt
Проведи production-grade iOS input-validation/content-safety review.

Проверь:
- size/type/count/duration/dimension limits;
- corrupt/unsupported file behavior;
- URL scheme allowlists;
- safe rendering of rich text/Markdown/HTML;
- temporary file cleanup;
- file protection and storage ownership;
- untrusted push/link/backend payload handling.

For every finding provide severity, affected files, evidence, target state, remediation order, and verification.
