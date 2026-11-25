---
name: ios-code-documentation
description: Write or review Swift documentation comments and inline code-documentation standards; not for ordinary caller, ownership, or API analysis without a documentation task.
---

# iOS Code Documentation

## Workflow
1. Document contracts, not obvious code.
2. For key types, require purpose, responsibilities, ownership/lifecycle, and important invariants where relevant.
3. For methods used outside their declaring type, require external usage/call context; prefer scenario-based context over fragile caller lists.
4. For side-effecting or async methods, require side effects, concurrency/cancellation, errors/failure behavior.
5. Reject comments that repeat the code, promise unsupported guarantees, or have temporary workaround text without reason and revisit condition.

## References
Resolve `DOC:` identifiers through the active task router in canonical
`reusable/baseline/docs/` or the project-root `docs/` mirror, not relative to this skill.
- `DOC:IOS_CODE_DOCUMENTATION_STANDARD.md`
- `DOC:EVIDENCE_BASED_ENGINEERING_RULES.md`
