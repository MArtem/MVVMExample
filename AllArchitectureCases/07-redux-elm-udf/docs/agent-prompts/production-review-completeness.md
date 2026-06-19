# Production Review Completeness Prompt

Use this prompt when the user says **ревью**, **review**, **code review**, **аудит**, or asks whether a feature/fix is production-ready.

```markdown
Проведи production-grade review без узкого фокуса.

Обязательные условия:
- не ограничивайся текущим багом;
- проверь UI structure, lazy rendering, hot path, state invalidation, data identity, persistence, networking/sync, concurrency, memory/cache/media, navigation side effects, security/privacy, failure states, and verification gaps;
- отдельно проверь, нет ли opaque wrapper между lazy container и repeated rows;
- отдельно проверь, нет ли sync media/file/db/network work в SwiftUI body или repeated row render path;
- для каждого вывода укажи affected files и почему это проблема;
- если говоришь “всё ок”, покажи checklist, по которому это проверено;
- если не можешь доказать, что всё ок, напиши remaining risk;
- не делай предположений — если не уверен, задай вопрос пользователю;
- не исправляй код во время review, если пользователь попросил только read-only review;
- классифицируй findings как P0/P1/P2/P3;
- для каждого finding укажи evidence, target state, remediation order, и required verification.
```

## Required Inputs
Before review, read:

1. `./docs/README.md`
2. `./docs/CURRENT_USER_OVERRIDES.md`
3. `./docs/AGENT_RULES.md`
4. `./docs/PRODUCTION_REVIEW_COMPLETENESS_GATE.md`
5. `./docs/PRODUCTION_CODE_REVIEW_CHECKLIST.md`
6. `./docs/PRODUCTION_QUALITY_GATES.md`
7. Relevant task/skill docs for the touched area.

## Output Contract
Return:

1. Scope and exclusions.
2. Checklist coverage table.
3. Findings P0-P3.
4. Remediation plan.
5. Verification plan.
6. Remaining risks, or `no known remaining risks after checked gates`.
