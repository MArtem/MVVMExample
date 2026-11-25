# iOS Security And Privacy Review Prompt

Use for a scoped security/privacy review or a whole-project audit. Keep this task prompt
separate from always-loaded `AGENTS.md`. The security gate and secret-intake standard
remain authoritative; this prompt does not grant access to secrets, external systems,
builds, tests, agents, or project mutation.

```markdown
Проведи read-only iOS security/privacy review в согласованной области. Не исправляй
код, не запускай сборки/тесты и не меняй Git без отдельного разрешения. Применяй
проектные правила, IOS_SECURITY_PRIVACY_GATE и
SECRET_HANDLING_AND_SECURITY_INTAKE_STANDARD. Не открывай реальные секреты или
секретные каталоги в обычном аудите; при подозрении сообщи путь/тип и запроси
отдельный security intake. Никогда не выводи значение секрета.

Сначала определи фактические targets, extensions, границы доверия, активные
конфигурации и атакуемые входы. Для каждого релевантного пути проследи источник
недоверенного ввода или чувствительных данных → проверки/владельца → хранение,
передачу, логирование и удаление → достижимый вред. По применимости проверь
auth и авторизацию, Keychain/файлы/App Groups/backup, network/TLS, криптографию,
WebView/JS bridge, URL/deeplink/notifications/imports/pasteboard, concurrency и
lifecycle, release/debug различия, SDK/entitlements/privacy manifests.

Не считай MD5/SHA-1, force unwrap/cast или debug-only код уязвимостью по одному
совпадению текста: выясни назначение, reachability и production-конфигурацию.
Не придумывай CVE, эксплуатацию или проверку, которой не было. Объединяй
дубли по корневой причине и отделяй подтверждённое кодом от предположений.

Для каждой находки укажи: severity P0–P3 по `IOS_PRODUCTION_AUDIT_MATRIX.md`
с учётом фактического воздействия и экспозиции; если внешний инструмент использует
другую шкалу, сохрани её отдельно и явно обоснуй сопоставление без автоматического
приравнивания. Укажи confidence
(CONFIRMED/LIKELY/POTENTIAL), файл и строку, путь атаки и необходимые условия,
контроль атакующего, факт/предположение, воздействие, безопасное исправление
и способ проверки. Отдельно перечисли охват, исключения и непроверенные места.
Сделай второй адресный проход по auth, секретам, внешним входам, ложным
срабатываниям, завышенной severity и дубликатам; не повторяй весь корпус без
причины. Если фактов недостаточно — пометь UNKNOWN, а не PASS.
```
