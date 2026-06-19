# iOS Code Documentation Review Prompt

Use this when reviewing or standardizing inline Swift/iOS documentation comments.

## Prompt
Проведи production-grade review документации кода.

Проверь:
- документируются ли контракты, а не очевидный код;
- указаны ли Purpose/Responsibilities там, где это важно;
- указан ли runtime owner / created-by для сущностей с lifecycle;
- указан ли External usage / call context для методов, используемых вне сущности;
- не перечислены ли хрупкие callers, которые быстро устареют;
- описаны ли side effects, concurrency, cancellation, errors, invariants, rationale;
- не обещает ли комментарий больше, чем гарантирует код;
- есть ли reason + revisit condition у temporary workaround comments.

Для каждого finding укажи severity, affected files, evidence, target state, remediation order, and verification.
