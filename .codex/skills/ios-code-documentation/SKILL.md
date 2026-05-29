---
name: ios-code-documentation
description: Use this skill for iOS/Swift inline code documentation standards and reviews involving documentation comments, API contracts, ownership, created-by/runtime owner, external usage/call context, side effects, concurrency, errors, invariants, rationale, and temporary workaround comments. Trigger whenever the user mentions code documentation, comments, doc comments, ownership comments, callers, or documenting methods/types/properties.
---

# iOS Code Documentation

## Workflow
1. Document contracts, not obvious code.
2. For key types, require purpose, responsibilities, ownership/lifecycle, and important invariants where relevant.
3. For methods used outside their declaring type, require external usage/call context; prefer scenario-based context over fragile caller lists.
4. For side-effecting or async methods, require side effects, concurrency/cancellation, errors/failure behavior.
5. Reject comments that repeat the code, promise unsupported guarantees, or have temporary workaround text without reason and revisit condition.

## References
- `./docs/IOS_CODE_DOCUMENTATION_STANDARD.md`
- `./docs/EVIDENCE_BASED_ENGINEERING_RULES.md`
