# iOS Data Migration Review Prompt

```markdown
Проведи iOS data migration/backward compatibility review.

Проверь:
- SwiftData/CoreData/UserDefaults/files/app-group schema changes;
- source-of-truth vs cache data;
- decode compatibility;
- destructive migration risk;
- old data fixtures/relaunch checks;
- logout/delete/reset behavior;
- rollback risk.

Вывод: P0-P3 findings, affected files, data risk, target state, migration/verification plan.
```
