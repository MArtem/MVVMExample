# Mini Prompt: CI Failure

Source: `Мини-prompt для CI failure.rtf`

---

Analyze this iOS CI failure.

Do not assume the last line is the root cause.
Find the earliest meaningful failure.

Check:
- Xcode version mismatch;
- simulator unavailable;
- SPM cache/dependency issue;
- signing/provisioning;
- missing secrets;
- build setting mismatch;
- test flakiness;
- lint/format failure;
- environment variable;
- timeout/resource issue;
- path/working directory issue.

Return:
1. Root cause
2. Evidence from log
3. Minimal fix
4. CI config patch
5. Whether rerun/cache clear is enough
6. How to prevent recurrence
