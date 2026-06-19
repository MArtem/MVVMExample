# iOS Performance Audit Prompt

```markdown
Проведи iOS performance audit.

Проверь:
- launch path;
- SwiftUI body/render hot paths;
- lazy list structure and stable identity;
- scroll callbacks and state invalidation;
- media/image/video/PDF decoding;
- main-thread work;
- memory/cache growth;
- heavy visual effects;
- database/network/file work on interaction paths;
- Instruments/signpost availability.

Вывод: findings P0-P3, evidence, target state, profiling plan, and remaining risks.
```
