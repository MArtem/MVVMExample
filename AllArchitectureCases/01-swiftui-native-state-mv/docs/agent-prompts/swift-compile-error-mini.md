# Mini Prompt: Swift Compile Error

Source: `Мини-prompt для Swift compile error.rtf`

---

Analyze this Swift/Xcode compile error.

Find the first meaningful compiler error and ignore cascading type errors.

Check:
- missing import;
- wrong access control;
- protocol conformance;
- generic constraint;
- SwiftUI ViewBuilder mismatch;
- Binding type mismatch;
- actor/MainActor isolation;
- async/await/try missing;
- Sendable issue;
- iOS availability;
- missing SPM module/product;
- target membership.

Return:
1. First real error
2. Why it happens
3. Minimal code fix
4. Whether other errors are cascading
5. Exact patch
6. How to verify with xcodebuild
