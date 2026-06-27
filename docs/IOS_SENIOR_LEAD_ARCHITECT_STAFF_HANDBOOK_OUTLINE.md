# Senior / Lead / Architect / Staff iOS Handbook — мастер-план

## Назначение
Этот документ — мастер-план глубокого учебника/справочника по современной iOS-разработке уровня Senior, Lead, Architect и Staff.

Он намеренно объединяет:
- практическую iOS-инженерию;
- теорию языка Swift;
- подкапотное поведение runtime;
- production-архитектуру;
- экспертизу в debugging и performance;
- security, privacy, release, observability и operations;
- leadership, техническую стратегию и staff-level decision making.

## Целевая аудитория
- Middle iOS engineers, растущие до Senior-уровня.
- Senior iOS engineers, растущие до Lead / Staff-ролей.
- Tech Leads, отвечающие за iOS delivery и architecture.
- Mobile architects, задающие стандарты между командами.
- Staff engineers, создающие platform-level leverage.
- Кандидаты, готовящиеся к Senior+ iOS-интервью.
- Engineering managers с сильным iOS-техническим контекстом.

## Уровни изучения, используемые в каждой главе
Каждую главу дальше нужно раскрывать через четыре уровня:

### Уровень 1 — Практический
#### Ожидаемая глубина объяснения
#### Признаки, что читатель освоил этот уровень
#### Типичные ошибки на этом уровне
#### Упражнения и проверочные вопросы
- Как правильно применять концепцию.
- Типовое использование API.
- Простые примеры.
- Базовые ошибки.

### Уровень 2 — Senior
#### Ожидаемая глубина объяснения
#### Признаки, что читатель освоил этот уровень
#### Типичные ошибки на этом уровне
#### Упражнения и проверочные вопросы
- Правила ownership.
- Поведение при сбоях.
- Performance-последствия.
- Тестируемость.
- Production-ограничения.

### Уровень 3 — Lead
#### Ожидаемая глубина объяснения
#### Признаки, что читатель освоил этот уровень
#### Типичные ошибки на этом уровне
#### Упражнения и проверочные вопросы
- Стратегия миграции.
- Границы ответственности команд.
- Процесс review.
- Delivery-риски.
- Cross-feature consistency.

### Уровень 4 — Staff / Architect
#### Ожидаемая глубина объяснения
#### Признаки, что читатель освоил этот уровень
#### Типичные ошибки на этом уровне
#### Упражнения и проверочные вопросы
- Матрица tradeoff-ов.
- Долгосрочная эволюция.
- Platform strategy.
- Governance.
- Организационное влияние.
- Стоимость изменений.

## Стандартный шаблон главы
Каждая будущая глава должна следовать этой структуре там, где это применимо:

1. **Назначение**
2. **Mental model**
3. **Базовая теория**
4. **Под капотом**
5. **Production-правила**
6. **Ownership и границы**
7. **Performance-последствия**
8. **Security/privacy-последствия**
9. **Стратегия тестирования**
10. **Debugging-сценарии**
11. **Типичные ошибки**
12. **Антипаттерны**
13. **Senior-level вопросы**
14. **Staff-level tradeoff-ы**
15. **Примеры кода для добавления**
16. **Чеклисты**
17. **Упражнения**
18. **Дополнительное чтение / источники**


## Политика дискретного расширения
Используй этот outline как granular content backlog, а не только как оглавление. При раскрытии глав сохраняй каждую существующую часть, главу и секцию, затем заполняй самый точный подраздел, соответствующий материалу. Лучше добавить новый подраздел более низкого уровня, чем смешивать несвязанную теорию, runtime-поведение, production-правила, примеры, упражнения и review-вопросы в одном блоке.

---

# Часть I. Платформа iOS как инженерная среда

## 1. Экосистема Apple и платформенные ограничения
### 1.1. iOS как constrained runtime
#### План наполнения темы
Эта тема задаёт платформенную mental model, которая должна влиять на все последующие главы. Это не вводный раздел «что такое iOS». Это базовая рамка senior-level инженерного мышления: iOS-приложение работает в среде, где финальное право на память, scheduling, background time, energy, thermal pressure, privacy boundaries, lifetime процесса и пользовательское внимание принадлежит системе, а не приложению.

Тему нужно раскрывать в таком порядке:
1. определить, что означает **constrained runtime** применительно к iOS;
2. связать ограничения платформы с конкретными инженерными решениями;
3. объяснить lifecycle и process model, из-за которых эти ограничения становятся реальными;
4. разобрать подкапотные аспекты memory, scheduling, energy и termination;
5. превратить mental model в production-правила, примеры и review-вопросы.

#### Определение и mental model
iOS-приложение — это **guest process** в user-first, battery-powered, privacy-controlled операционной системе. Приложение может запрашивать ресурсы; система решает, доступны ли они, как долго они доступны и с каким приоритетом. Неправильная mental model: «моё приложение работает, пока само не завершится». Правильная mental model: **система постоянно арбитрирует foreground priority, background eligibility, memory pressure, CPU scheduling, I/O, network access, thermal pressure и privacy permission surfaces между всеми приложениями и системными сервисами**.

Практическое следствие: production iOS-код нужно проектировать так, будто interruption — нормальное состояние, а не исключение. Senior iOS engineer предполагает, что:
- launch может быть cold, warm, after jetsam, after crash, после обновления, после изменения permissions или после восстановления scene state;
- foreground execution привилегирован и user-visible, но всё равно ограничен frame deadlines, memory, energy и thermal pressure;
- background execution является исключением, ограничено политиками платформы и должно иметь явную причину;
- suspension может произойти, когда пользователь ушёл из приложения и у приложения нет одобренной причины продолжать выполнение;
- termination может произойти без финального callback;
- memory warnings и diagnostics — сигнал уменьшать footprint, а не «опциональная нотификация»;
- CPU, disk, network, location, Bluetooth, camera, audio и GPU имеют energy и thermal cost;
- privacy prompts, entitlements, background modes и sandboxing — часть runtime design, а не release paperwork.

Короткая senior-формула: **iOS поощряет приложения, которые interruptible, resumable, lazy, incremental, cancellable, observable и честны насчёт background work**. iOS наказывает приложения, которые предполагают непрерывное выполнение, небрежно владеют global mutable state, блокируют launch, eager-decode большие assets, часто пишут на диск, poll-ят в фоне, держат sensors активными без ясной ценности или прячут side effects внутри «безобидного» UI-кода.

#### Категории ограничений
Runtime-ограничения проще анализировать через владельца решения.

| Ограничение | Владелец решения | Что контролирует приложение | Типичная senior-ошибка |
| --- | --- | --- | --- |
| Process lifetime | iOS scheduler и memory manager | state restoration, persistence, cancellation, idempotency | предполагать, что `applicationWillTerminate` или `scenePhase` transition всегда придут перед смертью процесса |
| Foreground responsiveness | main run loop, display pipeline, UIKit/SwiftUI rendering | main-thread work, view invalidation, task priorities, layout complexity | считать «работает на simulator» доказательством, что UI work дешёвый |
| Memory footprint | kernel, jetsam, memory compressor | allocations, image decoding, caches, data lifetimes, object graphs | измерять object count вместо dirty/resident memory и decoded buffers |
| Background time | UIKit lifecycle, BackgroundTasks, declared modes | background eligibility, task expiration handling, batching, persistence checkpoints | строить продуктовую логику на ненадёжных или user-hostile background assumptions |
| Energy и thermal behavior | power management, thermal management | CPU/GPU/network/I/O/sensor intensity, QoS, batching, Low Power Mode adaptation | оптимизировать latency ценой wakeups, polling и частых writes |
| Privacy и sandboxing | TCC, entitlements, App Sandbox, App Review policy | permission timing, data minimization, local storage, logging, explainability | считать permission grant постоянным или считать logs «безопасными по умолчанию» |
| Distribution/runtime policy | App Store, provisioning, OS version, device class | feature gating, availability checks, rollout, observability | тестировать один device/iOS version и считать поведение платформы единообразным |

#### Lifecycle states и process states
Нельзя сводить app lifecycle, scene lifecycle и process lifetime к одной концепции.

На верхнем уровне:
- **Process lifetime** отвечает на вопрос, существует ли app process в памяти.
- **Application lifecycle** описывает launch, active, inactive, backgrounded, suspended и terminated состояния приложения.
- **Scene lifecycle** описывает, подключена ли конкретная UI scene, находится ли она foreground/background или discarded.
- **Task lifecycle** описывает, активна ли async-работа, suspended, cancelled, expired или orphaned.
- **Data lifecycle** описывает, достаточно ли user-visible state durable, чтобы пережить потерю процесса.

Senior-level ошибка: хранить критичное product state только в памяти, потому что SwiftUI `@State`, `@Observable`, singleton, actor, cache, coordinator или store «сейчас это содержит». In-memory state — удобство для rendering и coordination; это не durability. Если пользователь разумно ожидает, что состояние переживёт relaunch, interruption или background eviction, нужна явная persistence или restoration policy.

Практические lifecycle-правила:
- Рассматривай foreground activation как шанс reconcile state, а не как доказательство, что предыдущая in-memory работа завершилась.
- Рассматривай background transition как checkpoint opportunity, а не как окно для долгого выполнения.
- Рассматривай suspension как невидимую заморозку: пока приложение suspended, код не выполняется.
- Рассматривай termination как non-cooperative: финальные cleanup callbacks не являются durable persistence mechanism.
- Рассматривай scene disconnection как норму для iPadOS и multi-window-capable приложений.
- Рассматривай force quit как user intent signal, который может влиять на background behavior.
- Рассматривай expiration handlers для background tasks как обязательные correctness paths, а не best-effort logging hooks.

#### Foreground execution constraints
Foreground-приложение получает максимум возможностей для выполнения, но всё равно ограничено пользовательским восприятием и rendering deadlines. Дисплей 60 Hz даёт примерно 16.67 ms на кадр; устройства 120 Hz уменьшают бюджет примерно до 8.33 ms. SwiftUI diffing, layout, image decoding, JSON mapping, persistence fetches, logging, analytics и network callbacks могут конкурировать с rendering, если попадают на main actor в неподходящий момент.

Важное различие:
- **MainActor correctness** предотвращает UI data races.
- **MainActor performance** требует не держать expensive work на main actor.

Код может быть корректным и одновременно давать плохой UX, если монополизирует main actor. Senior review должен спрашивать:
- Вычисляет ли view derived collections во время `body` evaluation?
- Декодирует ли screen images, парсит JSON, форматирует много дат или делает persistence fetches на main actor?
- Инвалидирует ли observation boundary большое view tree ради маленького state change?
- Возвращается ли async task на main actor с тяжёлым post-processing?
- Показывает ли UI partial progress и cancellation, или блокируется на all-or-nothing operation?

SwiftUI-specific вывод: `body` — это описание UI, а не work queue. Любая операция, которая выглядела бы подозрительно внутри `tableView(_:cellForRowAt:)`, так же подозрительна в SwiftUI `body`, computed view properties, formatter allocation per row или broad observable state, вызывающем full-list invalidation.

#### Background execution constraints
Background execution в iOS permissioned и purpose-based. Система может перевести приложение в background, когда пользователь ушёл, а затем suspend-нуть его, если приложение не завершает limited task и не использует разрешённую background capability. `BackgroundTasks` может планировать refresh или processing work, но не превращает приложение в произвольный daemon. Timing контролируется системой и зависит от power, usage patterns, device conditions, user settings и policy.

Design implications:
- Background refresh подходит для opportunistic freshness, а не для contractual deadlines.
- Long-running background work должен иметь declared platform reason и expiration path.
- Background tasks должны быть idempotent, потому что они могут быть retried, skipped, interrupted или запущены после partial previous work.
- Любая background task, которая мутирует local state, должна checkpoint-ить progress маленькими recoverable units.
- UI должен показывать freshness и last-success state, а не притворяться, что background refresh всегда произошёл.
- Network sync должен учитывать conflicts; «last write wins» часто является data-loss bug, замаскированным под simplicity.

Плохое product requirement: «sync каждые 5 минут в background». Хорошее requirement: «когда система даст background time, выполнить idempotent sync; durable сохранить local mutations; показать stale state; retry с backoff; никогда не блокировать foreground usage на background success».

#### Memory model на уровне приложения
На уровне приложения memory — это не только «сколько объектов существует». iOS memory pressure зависит от resident pages, dirty pages, compressed memory, decoded image buffers, mapped files, frameworks, caches, autorelease pools и retained object graphs. Apple memory materials различают clean memory, которую система может discard/reload, и dirty memory, записанную процессом и более дорогую для reclaim. WWDC memory guidance также подчёркивает, что images часто имеют decoded footprint значительно больше compressed file size.

Senior-level memory rules:
- Измеряй memory footprint через Instruments/Xcode tools, а не интуицией.
- Рассматривай decoded images, video frames, большие JSON payloads, ML models, PDF pages и attributed text layouts как first-class memory risks.
- Используй downsampling до создания UI images, если display size сильно меньше source asset.
- Предпочитай bounded caches с eviction и memory-pressure handling вместо global dictionaries.
- Не удерживай целые DTO payloads, если screen нуждается только в mapped domain/view state.
- Остерегайся task closures, которые захватывают view models, controllers, coordinators или большие graphs дольше, чем нужно.
- Подозревай «temporary» arrays в hot paths: temporary peak memory может вызвать jetsam, даже если steady-state memory выглядит нормально.

Senior engineer различает:
- **leak**: память должна быть освобождена, но остаётся strongly referenced;
- **growth**: память растёт, потому что product state растёт без границ;
- **peak**: временный memory spike во время decoding/parsing/rendering;
- **fragmentation/allocator overhead**: форма памяти неэффективна, даже если lifetimes корректны;
- **cache pressure**: память удерживается намеренно, но не ограничена user value;
- **dirty memory inflation**: pages становятся дорогими, потому что app code пишет в них без необходимости.

#### CPU, QoS, scheduling и energy
CPU work не бесплатен даже вне main actor. CPU time расходует battery и может повышать thermal pressure. QoS — scheduling hint, а не magic performance switch. Чрезмерное использование high-priority queues может starve-ить lower-priority work, увеличивать contention и тратить energy. Недостаточный priority может задерживать user-visible work. Senior-level решение — выровнять QoS с user value.

Практическая mapping:
- user input и immediate visual response: высокий priority, короткая работа, cancellable;
- screen data preparation: user-initiated или utility в зависимости от visibility и latency expectations;
- prefetching: utility, cancellable, bounded;
- analytics upload: utility/background, batched;
- cleanup, indexing, compaction: background, deferrable, expiration-aware;
- speculative work: только если измеренная ценность выше battery, memory и complexity cost.

Energy cost часто приходит от **wakeups и повторяющейся мелкой работы**, а не только от одного дорогого алгоритма. Timers, polling loops, frequent disk writes, chatty networking, small location updates, repeated Bluetooth scans и excessive logging могут мешать системе оставаться idle. Apple energy guidance подчёркивает сокращение и приоритизацию работы, минимизацию background activity, batching I/O и deferring networking when possible.

#### Thermal constraints
Thermal pressure — runtime input. `ProcessInfo.thermalState` даёт состояния вроде `nominal`, `fair`, `serious`, `critical`. При повышенном thermal state приложение должно снижать resource usage: останавливать nonessential prefetching, снижать rendering intensity, уменьшать качество camera/video processing там, где продуктово допустимо, останавливать speculative indexing, уменьшать polling и не запускать heavy background processing.

Senior-level thermal design — это не «показать alert, когда устройство горячее». Это adaptive work shedding:
- определить, какая работа essential for correctness;
- определить, какая работа user-visible, но degradable;
- определить speculative work, которую нужно остановить первой;
- сделать work cancellable, чтобы thermal adaptation быстро вступала в силу;
- собирать telemetry, связывающую thermal state с hangs, dropped frames, battery и session abandonment.

#### I/O и file-system constraints
Disk I/O может ухудшать latency, energy и data integrity. Частые маленькие writes особенно дороги, потому что будят storage и плохо сочетаются с lifecycle transitions. File writes должны быть batched там, где это безопасно, atomic там, где важна correctness, и выполняться вне main actor. Structured mutable data, растущая дальше trivial size, обычно должна жить в SQLite/Core Data/SwiftData или другом database layer, а не в repeated whole-file rewrites.

Правила:
- Не делай avoidable file I/O на main actor во время launch или scrolling.
- Используй atomic writes для user-critical documents/configuration, где partial write испортит состояние.
- Persist checkpoints до того, как рассчитывать на continuation background work.
- Не пиши analytics/log files с высокой частотой; batch и bound их.
- Не изобретай cache, который борется с OS file cache, если у продукта нет измеренного reuse pattern.
- Координируй app group/shared container writes, если задействованы extensions/widgets.

#### Network constraints
Network access переменный, energy-expensive, privacy-sensitive и часто недоступен ровно в момент, когда product code хочет его использовать. Mobile networking включает radio wakeup costs, captive portals, Low Data Mode, constrained networks, metered plans, packet loss, server throttling, authentication expiry и app suspension boundaries.

Senior network behavior:
- явно моделируй request cancellation, когда screens disappear или tasks становятся obsolete;
- делай mutations idempotent через client-generated keys, если возможна duplicate delivery;
- не привязывай UI correctness к immediate server acknowledgement, если требуется offline support или optimistic UI;
- разделяй transport errors, decoding errors, domain conflicts, auth failures и user-safe display messages;
- retry делай только там, где retry safe и useful; никогда не делай blind retry non-idempotent mutations;
- batch low-priority network work и уважай system/user constraints;
- сохраняй local user intent до попытки background sync.

#### Privacy, permission и sandbox constraints
iOS sandbox — product feature, а не препятствие. Permissions — user-mediated access grants к sensitive capabilities. Production app должна предполагать, что permissions могут быть denied, revoked, restricted, unavailable на некоторых devices или изменены, пока приложение не запущено.

Senior-level rules:
- Запрашивай permission в момент понятной пользователю ценности, а не на cold launch по привычке.
- Проектируй denied/restricted states как first-class UI states.
- Не логируй raw PII, tokens, precise location, contacts, health data, clipboard contents или sensitive file names.
- Храни secrets в Keychain с явным accessibility class; не клади token-like values в plain user defaults, logs, crash metadata или analytics properties.
- Рассматривай pasteboard, URL schemes, universal links, document imports, push payloads и app groups как external input boundaries.
- Минимизируй data retention: данные, которые никогда не сохранены, не могут утечь, устареть или потребовать migration.

#### Runtime interruptions и failure modes
Constrained runtime создаёт failure modes, которые не видны в happy-path simulator testing:
- app killed между записью local state и remote sync acknowledgement;
- background task expires, пока database transaction открыт;
- scene disconnected во время pending navigation transition;
- async task resumes после исчезновения view;
- memory pressure kills app во время image-heavy scrolling;
- network retry дублирует mutation;
- permission revoked после onboarding;
- thermal pressure замедляет processing и вскрывает timing assumptions;
- Low Power Mode делает polling или prefetching неприемлемым;
- process restarts со stale in-memory cache assumptions;
- crash report показывает memory termination, а не Swift exception.

Senior engineer проектирует state machines вокруг этих failures. Junior implementation часто добавляет `if isLoading { return }` и считает проблему решённой. Senior version определяет ownership, cancellation, durability, idempotency и recovery.

#### Подкапотные детали, меняющие инженерные решения
Важные internal mechanics, которые должны влиять на design:
- **Run loop и main actor — bottlenecks**: UI event handling, layout, drawing coordination и многие framework callbacks сходятся на main thread/main actor. Перенести work off-main необходимо, но недостаточно; post-processing при возврате всё ещё может вызвать hitch.
- **Suspension замораживает execution**: timers не продолжают работать только потому, что Swift object существует. Любой design, зависящий от in-process timers во время suspension, неверен без approved background mechanism.
- **Jetsam — не Swift crash**: memory termination может не дать обычный exception path. Нужно исследовать memory reports, organizer metrics и device logs, а не только crash stack traces.
- **Decoded media доминирует memory**: compressed image file может развернуться в большой pixel buffer. Display size, scale, color format и intermediate processing buffers имеют значение.
- **Clean vs dirty memory matters**: memory-mapped read-only resources системе проще reclaim-ить, чем app-written heap pages. Runtime modification, unnecessary mutation и large writable buffers увеличивают pressure.
- **QoS imperfectly propagates through abstraction layers**: async/await, operation queues, dispatch queues, URLSession callbacks, actors и third-party SDKs могут скрывать priority. Review должен смотреть end-to-end path.
- **Background execution expiration-driven**: каждая meaningful background operation требует плана для expiration handler и partial progress.
- **OS policy evolves**: поведение меняется между iOS versions. Production code должен опираться на documented guarantees и observable fallback behavior, а не folklore одного release.

#### Senior/staff design heuristics
Используй эти heuristics при review features:
1. **Может ли app быть killed на каждом `await`?** Не буквально всегда, но user-visible operation может быть interrupted между steps; design должен учитывать persistence/recovery.
2. **Какой smallest durable fact?** Persist user intent и irreversible decisions до large derived state.
3. **Какой bounded resource?** Для каждой feature определи реальный лимит: memory, CPU, network, disk, battery, privacy, user attention, server quota или team comprehension.
4. **Какую work можно cancel?** Work, которая больше не user-visible, обычно должна быть cancellable, если она не сохраняет data integrity.
5. **Какую work можно defer?** Всё, что не нужно для следующего user-visible state, должно быть lazy, incremental или scheduled.
6. **Какое degraded behavior?** Определи поведение при offline, denied permission, Low Power Mode, thermal pressure, memory pressure и stale server state.
7. **Что докажет, что это работает в production?** Заранее реши, какие metrics, logs, diagnostics и support signals показывают health после release.

#### Production checklist
Feature не production-ready в constrained runtime, пока на эти вопросы нет защищаемых ответов:
- Что переживает process death?
- Что происходит, если app suspended mid-operation?
- Что отменяется, когда screen disappears?
- Что persist-ится до network acknowledgement?
- Что retry-ится, с каким idempotency key и каким backoff?
- Какой maximum memory footprint для largest realistic input?
- Какая main-actor work происходит во время launch, navigation и scrolling?
- Что происходит в Low Power Mode или serious/critical thermal state?
- Что происходит, когда permissions denied, revoked или restricted?
- Что происходит, когда disk full или file protection delays access?
- Что логируется, и может ли log line утечь sensitive data?
- Как после release будут обнаружены hangs, launch regressions, memory terminations, disk writes и high energy usage?

#### Практические Swift-примеры
Пример: screen-owned work должна быть cancellable и не должна предполагать, что task переживёт view.

```swift
@MainActor
@Observable
final class ArticleListModel {
    private let repository: ArticleRepository
    private var loadTask: Task<Void, Never>?

    private(set) var articles: [ArticleSummary] = []
    private(set) var isLoading = false
    private(set) var userMessage: String?

    init(repository: ArticleRepository) {
        self.repository = repository
    }

    func appeared() {
        loadTask?.cancel()
        loadTask = Task { [repository] in
            isLoading = true
            defer { isLoading = false }

            do {
                // Fetch выполняется off-main внутри repository; здесь назначается только финальное UI-состояние.
                let loadedArticles = try await repository.fetchVisibleArticles()
                try Task.checkCancellation()
                articles = loadedArticles
            } catch is CancellationError {
                // Cancellation ожидаема, когда view исчезла или новый load заменил старый.
            } catch {
                userMessage = "Не удалось загрузить статьи. Проверьте подключение и повторите попытку."
            }
        }
    }

    func disappeared() {
        loadTask?.cancel()
        loadTask = nil
    }
}
```

Пример: persist user intent до попытки network mutation.

```swift
struct FavoriteMutation: Codable, Equatable {
    let idempotencyKey: UUID
    let articleID: Article.ID
    let isFavorite: Bool
    let createdAt: Date
}

actor FavoriteMutationQueue {
    private var pending: [FavoriteMutation] = []

    func enqueueFavoriteChange(articleID: Article.ID, isFavorite: Bool) async throws {
        let mutation = FavoriteMutation(
            idempotencyKey: UUID(),
            articleID: articleID,
            isFavorite: isFavorite,
            createdAt: Date()
        )

        // В production эта запись должна быть durable до того, как UI/server path начнёт от неё зависеть.
        pending.removeAll { $0.articleID == articleID }
        pending.append(mutation)
        try await persistPendingMutations(pending)
    }

    private func persistPendingMutations(_ mutations: [FavoriteMutation]) async throws {
        // Используй SwiftData/Core Data/SQLite/file storage, подходящий продукту.
        // Главное правило — durability до best-effort server delivery.
    }
}
```

Пример: optional work должна адаптироваться к thermal state.

```swift
import Foundation

struct OptionalWorkPolicy {
    func allowsImagePrefetch(thermalState: ProcessInfo.ThermalState, isLowPowerModeEnabled: Bool) -> Bool {
        guard !isLowPowerModeEnabled else { return false }

        switch thermalState {
        case .nominal, .fair:
            return true
        case .serious, .critical:
            return false
        @unknown default:
            return false
        }
    }
}
```

Пример: избегай repeated expensive work в SwiftUI hot path.

```swift
struct ArticleRowViewState: Equatable, Identifiable {
    let id: Article.ID
    let title: String
    let subtitle: String
    let formattedDate: String
}

struct ArticleRowView: View {
    let state: ArticleRowViewState

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(state.title)
                .font(.headline)
            Text(state.subtitle)
                .font(.subheadline)
            Text(state.formattedDate)
                .font(.caption)
        }
    }
}
```

Senior-point не в маленькой структуре как таковой. Суть в том, что date formatting, localization decisions и DTO mapping должны выполняться один раз на state-building boundary, а не повторяться во время `body` evaluation при каждой invalidation.

#### Debugging и verification workflow
Используй layered workflow:
1. **Static review**: найти main-actor heavy work, unbounded caches, eager decoding, polling, missing cancellation, non-idempotent retries и persistence gaps.
2. **Local measurement**: использовать Instruments/Xcode memory, time profiler, hangs, energy и network tools, по возможности на real devices.
3. **Lifecycle testing**: проверить cold launch, background/foreground transitions, task cancellation, permission changes, offline mode, Low Power Mode и relaunch after termination.
4. **Stress inputs**: использовать large images, long lists, slow network, server errors, disk pressure, denied permissions и interrupted sync.
5. **Release telemetry**: использовать MetricKit/Xcode Organizer/App Store diagnostics для launch time, hangs, memory, disk writes, energy и crashes.
6. **Regression gates**: добавлять unit/performance tests для deterministic hot paths; real-device profiling оставлять для поведения, которое нельзя доказать unit tests.

#### Common anti-patterns
- Считать simulator representative для memory, thermal, radio, camera и background behavior.
- Запускать network requests в view bodies или broad lifecycle hooks без cancellation ownership.
- Использовать global singletons как hidden durability или hidden lifecycle owners.
- Обновлять UI только после full success, когда partial progress сохранил бы user trust.
- Считать background refresh scheduler-ом с deadlines.
- Retry-ить любую ошибку одной политикой.
- Декодировать full-size images для thumbnail UI.
- Перезаписывать весь JSON-файл на каждое малое изменение состояния.
- Логировать raw request/response bodies в production diagnostics.
- Игнорировать Low Power Mode, потому что «feature важная».
- Добавлять cache без cost limit, eviction policy или memory-pressure response.
- Путать `@MainActor` safety с performance safety.
- Рисовать architecture diagrams, где отсутствуют cancellation, persistence и background expiration paths.

#### Senior interview и review questions
Эти вопросы отделяют поверхностное знание от production judgment:
1. Почему iOS app не может предполагать, что получит final termination callback?
2. Чем отличаются scene lifecycle, process lifetime и task lifetime?
3. Как feature остаётся корректной, если app killed между local mutation и server acknowledgement?
4. Почему compressed 200 KB image может создать multi-megabyte memory pressure?
5. Что должно происходить с image prefetching в Low Power Mode или serious thermal state?
6. Как решить, безопасен ли retry для failed network request?
7. Что делает background task idempotent?
8. Что memory termination report показывает такого, чего может не быть в Swift stack trace?
9. Почему broad `@Observable` model рискован для больших SwiftUI lists?
10. Как доказать после release, что launch optimization улучшила real user experience?
11. Что нужно persist до long-running sync?
12. Какие constraints являются product constraints, а не только technical constraints?

#### Источники для дальнейшего раскрытия главы
Используй эти официальные Apple references при расширении темы в полноценную главу:
- [Managing your app's life cycle](https://developer.apple.com/documentation/uikit/managing-your-app-s-life-cycle)
- [Background Tasks](https://developer.apple.com/documentation/backgroundtasks)
- [Reducing your app's memory use](https://developer.apple.com/documentation/xcode/reducing-your-app-s-memory-use)
- [Making changes to reduce memory use](https://developer.apple.com/documentation/xcode/making-changes-to-reduce-memory-use)
- [iOS Memory Deep Dive — WWDC18](https://developer.apple.com/videos/play/wwdc2018/416/)
- [Improving Battery Life and Performance — WWDC19](https://developer.apple.com/videos/play/wwdc2019/417/)
- [Energy Efficiency Guide for iOS Apps: Work Less in the Background](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/EnergyGuide-iOS/WorkLessInTheBackground.html)
- [Energy Efficiency Guide for iOS Apps: Minimize I/O](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/EnergyGuide-iOS/MinimizeIO.html)
- [ProcessInfo.ThermalState](https://developer.apple.com/documentation/foundation/processinfo/thermalstate-swift.enum)
- [MetricKit](https://developer.apple.com/documentation/metrickit)

### 1.2. Ограничения memory, battery, thermal и network
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 1.3. App sandbox и границы file-system
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 1.4. Privacy gates и модель permissions
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 1.5. Entitlements и системные capabilities
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 1.6. Цикл платформенных релизов и эволюция, driven by WWDC
#### Operational goal и ownership
#### Build, signing и environment constraints
#### Telemetry, logging и alerting signals
#### Rollout, rollback и incident workflow
#### Compliance и support handoff checklist
#### Runbook-примеры для добавления
### 1.7. Стратегия deployment target
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review questions и calibration rubric
#### Case studies и упражнения для добавления
### 1.8. Backward compatibility и обработка deprecation
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 1.9. Скрытая стоимость поддержки старых версий iOS
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 1.10. Стратегия platform adoption уровня Staff
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review questions и calibration rubric
#### Case studies и упражнения для добавления

## 2. App lifecycle и поведение процесса
### 2.1. Cold запуск
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы
### 2.2. Warm запуск
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы
### 2.3. Foreground activation
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 2.4. Background transition
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 2.5. Suspension and termination
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 2.6. Scene lifecycle
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 2.7. Поведение multi-window
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 2.8. Восстановление состояния
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 2.9. Стоимость dependency graph во время запуска
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 2.10. Под капотом: dyld, загрузка Swift metadata, static initializers
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 2.11. Под капотом: main run loop и путь запуска приложения
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 2.12. Чеклист production-ready запуска
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы

## 3. Системные интеграции
### 3.1. Push notifications
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 3.2. Ограничения silent push
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 3.3. Deep links
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 3.4. Universal links
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 3.5. Widgets
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 3.6. App Intents
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 3.7. Live Activities
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 3.8. Background tasks
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 3.9. Share extensions
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 3.10. Siri / Shortcuts
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 3.11. App Groups
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 3.12. Governance интеграций уровня Staff
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review questions и calibration rubric
#### Case studies и упражнения для добавления

---

# Часть II. Глубокий разбор языка Swift

## 4. Основы Swift на уровне Senior+
### 4.1. Value semantics
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 4.2. Reference semantics
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 4.3. Identity vs equality
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 4.4. Контроль mutability
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 4.5. Контроль доступа и дизайн API surface
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 4.6. Обработка ошибок с `throws`
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 4.7. Optionals beyond basics
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 4.8. Pattern matching
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 4.9. Правила инициализации
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 4.10. Deinitialization и lifetime
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 4.11. Языковые возможности, которые выглядят простыми, но формируют архитектуру
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления

## 5. Memory model Swift
### 5.1. Stack vs heap в практическом Swift
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 5.2. Value witness tables
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 5.3. Операции copy / destroy / move
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 5.4. Внутренности copy-on-write
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 5.5. `isKnownUniquelyReferenced`
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 5.6. Скрытые копии в hot paths
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 5.7. Подводные камни больших value types
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 5.8. Structs, которые не должны быть слишком большими
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 5.9. ARC retain/release traffic
#### Operational goal и ownership
#### Build, signing и environment constraints
#### Telemetry, logging и alerting signals
#### Rollout, rollback и incident workflow
#### Compliance и support handoff checklist
#### Runbook-примеры для добавления
### 5.10. Weak reference tables
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 5.11. `unowned` crash semantics
#### Operational goal и ownership
#### Build, signing и environment constraints
#### Telemetry, logging и alerting signals
#### Rollout, rollback и incident workflow
#### Compliance и support handoff checklist
#### Runbook-примеры для добавления
### 5.12. Autorelease pools in mixed Swift/UIKit code
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 5.13. Чеклист ревью memory ownership
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления

## 6. Protocols, existentials и generics
### 6.1. Protocols как контракты поведения
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 6.2. Protocols как архитектурные границы
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 6.3. Чрезмерное использование protocols и декоративные абстракции
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 6.4. Associated types
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 6.5. Existentials: `any Protocol`
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 6.6. Existential containers под капотом
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 6.7. Inline existential buffer
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 6.8. Witness tables
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 6.9. Opaque types: `some Protocol`
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 6.10. Generic constraints
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 6.11. Generic specialization
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 6.12. Conditional conformances
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 6.13. Type erasure
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 6.14. Phantom types
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 6.15. Compile-time vs runtime polymorphism
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 6.16. Дизайн API с generics на уровне Staff
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления

## 7. Dispatch, metadata и dynamic behavior
### 7.1. Static dispatch
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 7.2. Dynamic dispatch
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 7.3. Witness table dispatch
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 7.4. Objective-C message dispatch
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 7.5. `final` and devirtualization
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 7.6. `@objc`, `dynamic`, KVO, and bridging cost
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 7.7. Runtime metadata
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 7.8. Ограничения reflection
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 7.9. Стабильность ABI
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 7.10. Стабильность модулей
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 7.11. Режим library evolution
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 8. Продвинутые инструменты языка Swift
### 8.1. Property wrappers
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 8.2. Result builders
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 8.3. Macros
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 8.4. Key paths
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 8.5. Dynamic member lookup
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 8.6. Пользовательские операторы и почему большинства из них стоит избегать
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 8.7. Внутренности Codable и кастомизация
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 8.8. Аннотации Sendability на уровне языка
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 8.9. Поведение языка в Debug vs Release
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 8.10. Когда языковая изобретательность вредит maintainability
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления

---

# Часть III. Swift Concurrency и runtime-correctness

## 9. Основы async/await
### 9.1. Structured concurrency
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 9.2. Отношения parent-child между tasks
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 9.3. Task groups
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 9.4. Async let
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 9.5. Приоритет task
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 9.6. Наследование приоритета
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 9.7. Точки suspension
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 9.8. Почему `await` не означает background thread
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist

## 10. Task runtime под капотом
### 10.1. Дерево tasks
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 10.2. Кооперативный scheduling
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 10.3. Распространение cancellation
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 10.4. Task locals
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 10.5. Unstructured `Task {}`
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 10.6. `Task.detached`
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 10.7. Tasks, принадлежащие lifecycle
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 10.8. Риски fire-and-forget
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 10.9. Чеклист ownership для production tasks
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления

## 11. Actors и executors
### 11.1. Actor isolation
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 11.2. Actor reentrancy
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 11.3. Actor invariants
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 11.4. Nonisolated APIs
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 11.5. MainActor
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 11.6. Переходы между actors
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 11.7. Default executor
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 11.8. Custom executors на концептуальном уровне
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 11.9. Actor vs lock
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 11.10. Антипаттерны actors
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления

## 12. Sendable и готовность к Swift 6
### 12.1. `Sendable`
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 12.2. `@unchecked Sendable`
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 12.3. Предотвращение data races
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 12.4. Sendability closures
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 12.5. Общее mutable state
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 12.6. Миграция к strict concurrency
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 12.7. Ограничения compiler
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 12.8. План миграции concurrency уровня Staff
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist

## 13. Cancellation и защита от stale responses
### 13.1. Cancellation — это не interruption
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 13.2. `Task.isCancelled`
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 13.3. `Task.checkCancellation()`
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 13.4. Repositories, безопасные для cancellation
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 13.5. Отмена network-операций
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 13.6. Отмена UI-операций
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 13.7. Защита от stale responses
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 13.8. Счётчики поколений
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 13.9. Тестирование cancellation
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist

## 14. AsyncSequence и streams
### 14.1. Mental model для AsyncSequence
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 14.2. Buffering
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 14.3. Backpressure
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 14.4. Мосты к delegate APIs
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 14.5. Потоки notifications
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 14.6. Отмена streams
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 14.7. Утечки памяти в streams
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы
### 14.8. Тестирование streams
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления

---

# Часть IV. SwiftUI, UIKit и UI runtime

## 15. Mental model SwiftUI
### 15.1. Декларативный rendering
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 15.2. View values vs render tree
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 15.3. Инвалидация body
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 15.4. Структурная identity
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 15.5. Явная identity
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 15.6. `.id()` pitfalls
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 15.7. Mental model для diffing
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 15.8. Почему view structs дешёвые, а работа в body — нет
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 15.9. Подход к debugging в SwiftUI
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления

## 16. Ownership состояния в SwiftUI
### 16.1. `@State`
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 16.2. `@Binding`
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 16.3. `@Observable`
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 16.4. `@Bindable`
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 16.5. `@Environment`
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 16.6. `@EnvironmentObject`
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 16.7. Legacy `ObservableObject`
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 16.8. State на неверном уровне
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 16.9. Source of truth vs derived state
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 16.10. Широкая инвалидация
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 16.11. Review state ownership уровня Staff
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления

## 17. Layout и rendering internals в SwiftUI
### 17.1. Layout proposal / size / placement
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 17.2. Custom Layout
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 17.3. GeometryReader myths
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 17.4. Preference keys
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 17.5. Ловушки измерения в ScrollView
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 17.6. Transactions
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 17.7. Анимационные transactions
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 17.8. Распространение environment
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 17.9. Core Animation bridge
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 17.10. Основы render server
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 18. SwiftUI performance
### 18.1. Форматирование в `body`
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 18.2. Повторное создание formatters
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 18.3. Декодирование изображений в rows
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 18.4. `AnyView` и стоимость type erasure
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 18.5. Overusing `.id()`
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 18.6. Большие observable objects
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 18.7. Lazy containers
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 18.8. Подвисания при navigation transitions
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 18.9. Чеклист hot path для row
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 19. UIKit и legacy interoperability
### 19.1. Lifecycle view controller
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 19.2. Responder chain
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 19.3. Hit testing
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 19.4. Gesture recognizers
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 19.5. Режимы run loop
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 19.6. Layout pass
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 19.7. Display pass
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 19.8. Core Анимационные transactions
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 19.9. `UIHostingController`
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 19.10. `UIViewRepresentable`
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 19.11. Паттерн Coordinator в representables
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 19.12. Legacy-миграция с UIKit на SwiftUI
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления

---

# Часть V. Основы архитектурного мышления

## 20. Архитектурное мышление
### 20.1. Что такое architecture и чем она не является
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 20.2. Архитектурные решения
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 20.3. Reversibility
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 20.4. Стоимость изменений
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 20.5. Локальный optimum vs глобальный optimum
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 20.6. Architecture как управление рисками
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 20.7. Architecture как средство коммуникации
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation

## 21. Boundaries и coupling
### 21.1. Граница UI
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 21.2. Domain-граница
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 21.3. Data-граница
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 21.4. Infrastructure-граница
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 21.5. Feature-граница
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 21.6. Граница модуля
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 21.7. Compile-time coupling
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 21.8. Runtime coupling
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 21.9. Data coupling
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 21.10. Temporal coupling
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 21.11. Semantic coupling
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 21.12. Организационное coupling
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 22. Ownership состояния и side effects
### 22.1. Source of truth
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 22.2. Derived state
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 22.3. Render state
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 22.4. Cache state
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 22.5. Persistent state
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 22.6. Server state
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 22.7. Optimistic state
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 22.8. UI side effects
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 22.9. Navigation side effects
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 22.10. Network side effects
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 22.11. Persistence side effects
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 22.12. Analytics/logging side effects
#### Operational goal и ownership
#### Build, signing и environment constraints
#### Telemetry, logging и alerting signals
#### Rollout, rollback и incident workflow
#### Compliance и support handoff checklist
#### Runbook-примеры для добавления

## 23. Architecture decay и governance
### 23.1. Деградация границ
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 23.2. Нормализация shortcuts
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 23.3. Architecture fitness functions
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 23.4. Процесс exceptions
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 23.5. Путь миграции
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 23.6. Правила sunset
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 23.7. Governance без бюрократии
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review questions и calibration rubric
#### Case studies и упражнения для добавления

---

# Часть VI. Архитектурные стили iOS

## 24. MVVM с explicit intents
### 24.1. Ответственности ViewModel
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 24.2. Явный intent API
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 24.3. ViewState builders
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 24.4. Lifecycle async tasks
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 24.5. User-safe mapping ошибок
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 24.6. Ownership navigation
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 24.7. Тестирование ViewModels
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 24.8. Антипаттерн generic `send(_:)`
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления

## 25. SwiftUI Native State / MV
### 25.1. Когда ViewModels не нужны
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 25.2. State, принадлежащее View
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 25.3. Lifecycle-модели
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 25.4. Local state vs domain state
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 25.5. Когда MV становится переименованным MVVM
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation

## 26. Coordinator / Flow
### 26.1. Ответственности Coordinator
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 26.2. Router vs Coordinator
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 26.3. Flow state
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 26.4. Deep links
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 26.5. Разделение lifecycle приложения и session
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 26.6. Антипаттерн side effect в Coordinator
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation

## 27. Clean / Layered architecture
### 27.1. Слой presentation
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 27.2. Domain-слой
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 27.3. Data-слой
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 27.4. Infrastructure-слой
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 27.5. Boundary-контракты
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 27.6. Clean без церемонии use cases
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation

## 28. Modular / Feature-Sliced architecture
### 28.1. Feature slices
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 28.2. Каркас приложения
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 28.3. Правила Shared/Core
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 28.4. Направление dependencies
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 28.5. Cross-feature communication
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review questions и calibration rubric
#### Case studies и упражнения для добавления
### 28.6. Стратегия выделения модулей
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review questions и calibration rubric
#### Case studies и упражнения для добавления
### 28.7. Последствия для build time
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 29. Hexagonal / Ports & Adapters
### 29.1. Ports
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 29.2. Driving adapters
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 29.3. Driven adapters
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 29.4. Чистота domain
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 29.5. DTO/error mapping на границах
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 29.6. Как избежать взрыва количества protocols
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления

## 30. Redux / Elm / UDF
### 30.1. State
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 30.2. Actions
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 30.3. Mutations
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 30.4. Reducers
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 30.5. Effects
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 30.6. Store scope
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 30.7. Traceable feature state
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления

## 31. TCA-style architecture
### 31.1. Mental model для TCA
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 31.2. Полное state-machine state
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 31.3. Композиция reducers
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 31.4. Effects и cancellation
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 31.5. Dependencies
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 31.6. Navigation в TCA
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 31.7. Сторонняя TCA vs облегчённый стиль TCA
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation

## 32. Reactor-style architecture
### 32.1. Ответственности Reactor
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 32.2. Action / Mutation / State
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 32.3. `mutate`
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 32.4. `reduce`
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 32.5. Rx vs async/await variants
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 32.6. Интеграция со SwiftUI
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления

## 33. MVC migration architecture
### 33.1. Реальность legacy MVC
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 33.2. Ограниченные controllers
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 33.3. Риски Massive ViewController
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 33.4. Точки для миграции
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 33.5. Когда MVC допустим
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation

## 34. MVP Passive View
### 34.1. Принцип passive view
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 34.2. Ownership Presenter
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 34.3. Адаптация passive view для SwiftUI
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 34.4. Как избегать декоративных view protocols
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления

## 35. VIP / Clean Swift
### 35.1. View
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 35.2. Interactor
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 35.3. Presenter
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 35.4. Router
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 35.5. Worker
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 35.6. Роли Request / Response / ViewModel
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 35.7. Scene builders
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 36. VIPER
### 36.1. View
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 36.2. Interactor
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 36.3. Presenter
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 36.4. Entity
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 36.5. Router
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 36.6. Builder
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 36.7. VIPER в SwiftUI
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 36.8. Антипаттерн с перегруженным Presenter
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления

## 37. RIBs
### 37.1. Router
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 37.2. Interactor
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 37.3. Builder
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 37.4. Component
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 37.5. Lifecycle attach/detach
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 37.6. Распространение dependencies
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 37.7. SwiftUI в стиле RIBs
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления

---

# Часть VII. Modularization, packages и scaling

## 38. Масштабирование codebase
### 38.1. Монолит vs модульное приложение
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 38.2. Границы пакетов
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 38.3. Структура Xcode-проекта
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 38.4. Управление build-time
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 38.5. Командный ownership
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 38.6. Контроль public API
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 38.7. Внутренние platform-модули
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review questions и calibration rubric
#### Case studies и упражнения для добавления

## 39. Dependency management
### 39.1. SwiftPM
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 39.2. Binary dependencies
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 39.3. Риски third-party dependencies
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 39.4. Политика обновлений
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 39.5. Security ревью
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 39.6. Изоляция dependencies
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation

## 40. Design systems
### 40.1. Tokens
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 40.2. Components
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 40.3. Theming
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 40.4. Accessibility по умолчанию
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 40.5. Поддержка localization
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 40.6. Governance design system
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review questions и calibration rubric
#### Case studies и упражнения для добавления

---

# Часть VIII. Networking и API contracts

## 41. Основы networking
### 41.1. URLSession
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 41.2. Моделирование requests
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 41.3. Валидация responses
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 41.4. Decoding
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 41.5. Cancellation
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 41.6. Timeouts
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 41.7. Retries
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 42. URLSession под капотом
### 42.1. DNS
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 42.2. TCP/TLS
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 42.3. HTTP/2 multiplexing
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 42.4. Connection reuse
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 42.5. URL cache
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 42.6. Default / ephemeral / background sessions
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 42.7. Семантика timeout
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 42.8. Дорогие и constrained сети
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics

## 43. Проектирование API contract
### 43.1. DTOs
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 43.2. Domain mapping
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 43.3. Pagination
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 43.4. Сортировка и фильтрация
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 43.5. Idempotency
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 43.6. Частичный успех
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 43.7. Versioning
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 43.8. Backward-compatible mobile APIs
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics

## 44. Auth и sessions
### 44.1. Login flows
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 44.2. Хранение token
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 44.3. Refresh tokens
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 44.4. Expiration
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 44.5. Logout
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 44.6. Восстановление session
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 44.7. Поддержка нескольких аккаунтов
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 45. Network resilience
### 45.1. Поведение offline
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 45.2. Retryable vs non-retryable failures
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 45.3. Backoff и jitter
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 45.4. Circuit breakers
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 45.5. Herd effects
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 45.6. User feedback
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

---

# Часть IX. Persistence, local data и sync

## 46. Варианты persistence
### 46.1. UserDefaults
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 46.2. Keychain
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 46.3. Files
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 46.4. SQLite
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 46.5. Core Data
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 46.6. SwiftData
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 46.7. App Groups
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 47. Глубокий разбор SwiftData / Core Data
### 47.1. Object graph
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 47.2. Identity
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 47.3. Faulting
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 47.4. Ownership context
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 47.5. Отслеживание изменений
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 47.6. Concurrency context
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 47.7. Политики merge
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 47.8. Migrations
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 47.9. Производительность запросов
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы
### 47.10. Индексация и ограничения fetch
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 48. Offline-first и sync
### 48.1. Локальный source of truth
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 48.2. Ожидающие mutations
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 48.3. Ключи idempotency
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 48.4. Разрешение конфликтов
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 48.5. Tombstones
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 48.6. Local IDs vs server IDs
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 48.7. Риски last-write-wins
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 48.8. Обзор CRDT
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 48.9. Политика replay
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 48.10. Наблюдаемость sync
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления

## 49. Data safety
### 49.1. Secrets vs non-secrets
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 49.2. Защита файлов
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 49.3. Разрушающие миграции
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 49.4. Поведение backup
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 49.5. Удаление данных
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 49.6. Требования в стиле GDPR/CCPA
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления

---

# Часть X. Security и privacy

## 50. Security model iOS
### 50.1. Sandbox
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 50.2. Keychain
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 50.3. Entitlements
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 50.4. App Groups
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 50.5. Secure Enclave
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 50.6. Biometrics
#### Operational goal и ownership
#### Build, signing и environment constraints
#### Telemetry, logging и alerting signals
#### Rollout, rollback и incident workflow
#### Compliance и support handoff checklist
#### Runbook-примеры для добавления

## 51. Threat modeling для iOS
### 51.1. Случайный атакующий
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 51.2. Устройство с jailbreak
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 51.3. Сетевой атакующий
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 51.4. Злонамеренная dependency
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 51.5. Insider/log access
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 51.6. Границы доверия к server
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 52. Secure coding
### 52.1. Lifecycle секретов
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 52.2. Хранение token
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 52.3. Редакция logs
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 52.4. TLS and ATS
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 52.5. Tradeoff-ы certificate pinning
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 52.6. Валидация ввода
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 52.7. Ограничения reverse engineering
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 53. Privacy engineering
### 53.1. Минимизация данных
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 53.2. Permission prompts
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 53.3. Privacy manifests
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 53.4. Privacy labels App Store
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 53.5. Privacy analytics
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 53.6. Privacy crash reports
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления

---

# Часть XI. Performance и profiling

## 54. Performance mindset
### 54.1. Что ощущают пользователи
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 54.2. Frame budgets
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 54.3. Бюджет main thread
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 54.4. Измерения vs статически очевидные исправления
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 54.5. Предотвращение regressions
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 55. Launch performance
### 55.1. Cold запуск
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы
### 55.2. Работа на main thread во время запуска
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 55.3. Запуск dependency graph
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 55.4. Lazy loading
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 55.5. Метрики запуска
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы
### 55.6. dyld and library loading
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 56. CPU profiling
### 56.1. Time Profiler
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы
### 56.2. Self weight vs total weight
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 56.3. Интерпретация stack trace
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 56.4. Symbolication
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 56.5. Алгоритмическая сложность в UI
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 56.6. Сортировка/фильтрация в hot paths
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 57. Memory performance
### 57.1. Рост heap
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 57.2. Retain cycles
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 57.3. Дизайн cache
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 57.4. Память изображений
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы
### 57.5. Data blobs
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 57.6. Memory pressure
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы
### 57.7. Jetsam
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 58. Image pipeline performance
### 58.1. Compressed vs decoded image
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 58.2. Downsampling
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 58.3. Decompression
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 58.4. Стоимость cache
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 58.5. Отмена scrolling-задач
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 58.6. Обработка memory pressure
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы

## 59. Rendering и scrolling performance
### 59.1. Дерево слоёв Core Animation
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 59.2. Render server
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 59.3. Offscreen rendering
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 59.4. Blending
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 59.5. Shadows and masks
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 59.6. Подвисания scrolling
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы
### 59.7. Backpressure пагинации
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics

## 60. Profiling tools
### 60.1. Обзор Instruments
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 60.2. Time Profiler
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы
### 60.3. Allocations
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 60.4. Leaks
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 60.5. Hangs
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 60.6. Network-инструменты
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 60.7. Points of Interest
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 60.8. MetricKit
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

---

# Часть XII. Accessibility, localization и inclusive UX

## 61. Accessibility
### 61.1. VoiceOver
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 61.2. Labels, hints, traits
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 61.3. Dynamic Type
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 61.4. Порядок focus
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 61.5. Tap targets
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 61.6. Reduce Motion
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 61.7. Contrast
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 61.8. Тестирование accessibility
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 61.9. Accessibility как архитектурное ограничение
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления

## 62. Localization
### 62.1. `.xcstrings`
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 62.2. Plurals
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 62.3. Dates and numbers
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 62.4. RTL
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 62.5. String interpolation
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 62.6. Pseudolocalization
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 62.7. QA локализации
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 62.8. Подводные камни производительности localization
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы

---

# Часть XIII. Testing и quality strategy

## 63. Testing pyramid для iOS
### 63.1. Unit-тесты
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 63.2. Тесты интеграционного типа
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 63.3. Snapshot-тесты
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 63.4. UI-тесты
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 63.5. Ручной QA
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 63.6. Исследовательское тестирование
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления

## 64. XCTest и Swift Testing
### 64.1. Основы XCTest
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 64.2. Основы Swift Testing
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 64.3. Async-тесты
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 64.4. Test traits/tags
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 64.5. Test data builders
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 64.6. Determinism
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 64.7. Диагностика flakiness
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 65. Architecture testing
### 65.1. Тесты ViewModel
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 65.2. Тесты store/reducer
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 65.3. Тесты interactor
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 65.4. Тесты presenter
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 65.5. Тесты coordinator/router
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 65.6. Тесты repository
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 65.7. Тесты persistence
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 65.8. Тесты boundary-контрактов
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation

## 66. UI и accessibility testing
### 66.1. XCUITest
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 66.2. Accessibility identifiers
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 66.3. Smoke-тесты
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 66.4. Архитектура UI-тестов
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 66.5. Матрица simulator
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 66.6. Result bundles
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

---

# Часть XIV. CI/CD и release engineering

## 67. Build system
### 67.1. Xcode build pipeline
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 67.2. Schemes
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 67.3. Configurations
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 67.4. DerivedData
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 67.5. Module cache
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 67.6. Инкрементальная компиляция
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 67.7. Анализ build logs
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 68. Swift compiler и binary behavior
### 68.1. Производительность type-checker
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы
### 68.2. Взрывы compile-time из-за result builders
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 68.3. Generic constraints и compile time
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 68.4. Dead stripping
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 68.5. Видимость символов
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 68.6. Размер binary
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 68.7. Производительность Debug vs Release
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы

## 69. CI pipelines
### 69.1. GitHub Actions / Bitrise / Xcode Cloud
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 69.2. Статические gates
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 69.3. Линии unit-тестов
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 69.4. Линии UI-тестов
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 69.5. Artifacts
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 69.6. Триаж failures
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 69.7. Стратегия cache
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics

## 70. Signing и provisioning
### 70.1. Certificates
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 70.2. Provisioning profiles
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы
### 70.3. Entitlements
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 70.4. App Groups
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 70.5. Подпись в CI
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 70.6. Реакция на signing-инциденты
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления

## 71. App Store release
### 71.1. Archives
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 71.2. TestFlight
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 71.3. Поэтапный rollout
#### Operational goal и ownership
#### Build, signing и environment constraints
#### Telemetry, logging и alerting signals
#### Rollout, rollback и incident workflow
#### Compliance и support handoff checklist
#### Runbook-примеры для добавления
### 71.4. App Review
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 71.5. Стратегия rollback
#### Operational goal и ownership
#### Build, signing и environment constraints
#### Telemetry, logging и alerting signals
#### Rollout, rollback и incident workflow
#### Compliance и support handoff checklist
#### Runbook-примеры для добавления
### 71.6. Release notes
#### Operational goal и ownership
#### Build, signing и environment constraints
#### Telemetry, logging и alerting signals
#### Rollout, rollback и incident workflow
#### Compliance и support handoff checklist
#### Runbook-примеры для добавления
### 71.7. Чеклист production readiness
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

---

# Часть XV. Observability и operations

## 72. Logging
### 72.1. OSLog
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 72.2. Redaction
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 72.3. Log levels
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 72.4. Структурированные logs
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 72.5. Correlation IDs
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 72.6. Supportability
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления

## 73. Analytics
### 73.1. Таксономия событий
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 73.2. Privacy-safe analytics
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 73.3. Product metrics
#### Operational goal и ownership
#### Build, signing и environment constraints
#### Telemetry, logging и alerting signals
#### Rollout, rollback и incident workflow
#### Compliance и support handoff checklist
#### Runbook-примеры для добавления
### 73.4. Funnel analysis
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 73.5. Эксперименты
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 74. Crash reporting
### 74.1. Символикация crash reports
#### Operational goal и ownership
#### Build, signing и environment constraints
#### Telemetry, logging и alerting signals
#### Rollout, rollback и incident workflow
#### Compliance и support handoff checklist
#### Runbook-примеры для добавления
### 74.2. Загрузка dSYM
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 74.3. Триаж crash reports
#### Operational goal и ownership
#### Build, signing и environment constraints
#### Telemetry, logging и alerting signals
#### Rollout, rollback и incident workflow
#### Compliance и support handoff checklist
#### Runbook-примеры для добавления
### 74.4. Non-fatal errors
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 74.5. Обнаружение regressions
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 75. Runtime monitoring и incidents
### 75.1. MetricKit
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 75.2. Дашборды производительности
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы
### 75.3. Network-метрики
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 75.4. Ограничения mobile-инцидентов
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 75.5. Kill switches
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 75.6. Postmortems
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

---

# Часть XVI. Engineering leadership

## 76. Execution уровня Senior engineer
### 76.1. Ownership
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 76.2. Выявление рисков
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 76.3. Техническое планирование
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 76.4. Communication
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review questions и calibration rubric
#### Case studies и упражнения для добавления
### 76.5. Estimation
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 76.6. Контроль scope
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 77. Навыки Tech Lead
### 77.1. Декомпозиция работы
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 77.2. Delegation
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 77.3. Качество ревью
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 77.4. Mentorship
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 77.5. Cross-functional работа
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 77.6. Delivery без heroics
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 78. Навыки Staff engineer
### 78.1. Влияние без формальной authority
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 78.2. Техническая стратегия
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review questions и calibration rubric
#### Case studies и упражнения для добавления
### 78.3. Engineering leverage
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 78.4. Standards и governance
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review questions и calibration rubric
#### Case studies и упражнения для добавления
### 78.5. RFC и ADR
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review questions и calibration rubric
#### Case studies и упражнения для добавления
### 78.6. Долгосрочная maintainability
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 78.7. Когда нужно сказать нет
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 79. Technical debt и strategy
### 79.1. Осознанный debt
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 79.2. Случайный debt
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 79.3. Bit rot
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 79.4. Эрозия архитектуры
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 79.5. Knowledge debt
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 79.6. Стратегия погашения debt
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review questions и calibration rubric
#### Case studies и упражнения для добавления

---

# Часть XVII. Code review, documentation и knowledge sharing

## 80. Code review
### 80.1. Correctness
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 80.2. Architecture
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 80.3. Security
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 80.4. Performance
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы
### 80.5. Accessibility
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 80.6. Testing
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 80.7. Стиль ревью-комментариев
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления

## 81. Code documentation
### 81.1. Что документировать
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 81.2. Что не документировать
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 81.3. Комментарии об ownership
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 81.4. Комментарии о side effects
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 81.5. API contracts
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 81.6. Комментарии о временных workaround
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 81.7. Устаревание документации
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 82. Project documentation
### 82.1. README
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 82.2. Документация по архитектуре
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 82.3. Инструкции по тестированию
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 82.4. Release-документация
#### Operational goal и ownership
#### Build, signing и environment constraints
#### Telemetry, logging и alerting signals
#### Rollout, rollback и incident workflow
#### Compliance и support handoff checklist
#### Runbook-примеры для добавления
### 82.5. Runbooks
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 82.6. Onboarding-документация
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

---

# Часть XVIII. Product engineering и requirements

## 83. Product requirements
### 83.1. Критерии приёмки
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 83.2. Non-goals
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 83.3. Пограничные случаи
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 83.4. Разрешение неоднозначностей
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 83.5. Product tradeoff-ы
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 84. Feature planning
### 84.1. Нарезка scope
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 84.2. Вертикальные slices
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 84.3. Технические milestones
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 84.4. Rollout flags
#### Operational goal и ownership
#### Build, signing и environment constraints
#### Telemetry, logging и alerting signals
#### Rollout, rollback и incident workflow
#### Compliance и support handoff checklist
#### Runbook-примеры для добавления
### 84.5. План telemetry
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 85. Experimentation
### 85.1. Feature flags
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 85.2. A/B-тесты
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 85.3. Remote config
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 85.4. Kill switches
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 85.5. Этичные эксперименты
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

---

# Часть XIX. Debugging mastery

## 86. Debugging mental models
### 86.1. Reproduction
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 86.2. Минимальный repro
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 86.3. Determinism
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 86.4. Захват состояния
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 86.5. Восстановление timeline
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 87. LLDB
### 87.1. Breakpoints
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 87.2. Условные breakpoints
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 87.3. Watchpoints
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 87.4. Вычисление expressions
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 87.5. Инспекция threads
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 87.6. Отладка Swift concurrency
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления

## 88. Log-driven debugging
### 88.1. Correlation IDs
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 88.2. Redacted context
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 88.3. Breadcrumbs
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 88.4. Support logs
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 88.5. Debugging без утечки пользовательских данных
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

---

# Часть XX. Практические case studies

## 89. Case study news/feed app
### 89.1. Требования
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 89.2. Реализация MVVM
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 89.3. Реализация UDF
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 89.4. Реализация Clean
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 89.5. Реализация VIPER
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 89.6. Сравнение tradeoff-ов
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 90. Case study auth/session
### 90.1. Login
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 90.2. Хранение token
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 90.3. Refresh
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 90.4. Logout
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 90.5. Восстановление session
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 90.6. Security ревью
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления

## 91. Case study offline sync
### 91.1. Состояние local-first
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 91.2. Ожидающие mutations
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 91.3. Разрешение конфликтов
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 91.4. Retry/backoff
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 91.5. UI feedback
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 92. Case study modularization большого приложения
### 92.1. Исходный монолит
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 92.2. Выявление границ
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 92.3. Выделение пакетов
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 92.4. Производительность сборки
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы
### 92.5. Командный ownership
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления

---

# Часть XXI. Interview и calibration materials

## 93. Темы Senior iOS interview
### 93.1. Swift
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 93.2. Concurrency
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 93.3. SwiftUI
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 93.4. Architecture
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 93.5. Networking
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 93.6. Persistence
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 93.7. Testing
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 93.8. Performance
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы

## 94. Темы Lead / Staff interview
### 94.1. System design
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 94.2. Architecture ревью
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 94.3. Техническая стратегия
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review questions и calibration rubric
#### Case studies и упражнения для добавления
### 94.4. Обработка инцидентов
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 94.5. Mentorship
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 94.6. Влияние между командами
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review questions и calibration rubric
#### Case studies и упражнения для добавления

## 95. Банк вопросов
### 95.1. Теоретические вопросы
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 95.2. Практические вопросы по коду
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 95.3. Сценарии debugging
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 95.4. Сценарии архитектуры
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 95.5. Поведенческие вопросы
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

## 96. Рубрики оценки ответов
### 96.1. Ответ Junior
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 96.2. Ответ Middle
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 96.3. Ответ Senior
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 96.4. Ответ Staff
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review questions и calibration rubric
#### Case studies и упражнения для добавления
### 96.5. Red flags
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts

---

# Часть XXII. Приложения

## 97. Чеклисты
### 97.1. Чеклист готовности feature
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 97.2. Чеклист PR
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 97.3. Чеклист релиза
#### Operational goal и ownership
#### Build, signing и environment constraints
#### Telemetry, logging и alerting signals
#### Rollout, rollback и incident workflow
#### Compliance и support handoff checklist
#### Runbook-примеры для добавления
### 97.4. Чеклист architecture ревью
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 97.5. Чеклист security
#### Threat model и защищаемые assets
#### Platform mechanism и entitlement surface
#### Data lifecycle, retention и deletion behavior
#### Logging, analytics и crash-reporting ограничения
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 97.6. Чеклист performance
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы
### 97.7. Чеклист accessibility
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления

## 98. Шаблоны
### 98.1. Шаблон ADR
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review questions и calibration rubric
#### Case studies и упражнения для добавления
### 98.2. Шаблон RFC
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A prompts
### 98.3. Шаблон incident report
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 98.4. Шаблон release plan
#### Operational goal и ownership
#### Build, signing и environment constraints
#### Telemetry, logging и alerting signals
#### Rollout, rollback и incident workflow
#### Compliance и support handoff checklist
#### Runbook-примеры для добавления
### 98.5. Шаблон test plan
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 98.6. Шаблон architecture ревью
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления

## 99. Глоссарий
### 99.1. Термины Swift
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 99.2. Термины платформы iOS
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review questions и calibration rubric
#### Case studies и упражнения для добавления
### 99.3. Архитектурные термины
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 99.4. Термины networking
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 99.5. Термины release
#### Operational goal и ownership
#### Build, signing и environment constraints
#### Telemetry, logging и alerting signals
#### Rollout, rollback и incident workflow
#### Compliance и support handoff checklist
#### Runbook-примеры для добавления

## 100. Упражнения
### 100.1. Рефакторинг ViewModel
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review-вопросы
#### Примеры и упражнения для добавления
### 100.2. Спроектировать offline sync
#### Contract и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 100.3. Профилировать scrolling list
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview и incident-review вопросы
### 100.4. Построить модульную feature
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 100.5. Написать ADR
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review questions и calibration rubric
#### Case studies и упражнения для добавления
### 100.6. Разобрать production-инцидент
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления

---

# Expansion Backlog For Future Writing

## Блоки теории для добавления в каждую главу
- Mental model diagrams.
- Runtime diagrams.
- Tradeoff tables.
- Senior pitfalls.
- Staff-level decision criteria.
- Production incident examples.

## Q&A-блоки для добавления в каждую главу
- Basic comprehension questions.
- Senior interview questions.
- Staff architecture questions.
- Debugging questions.
- Red-flag answers.

## Примеры кода для добавления в каждую главу
- Minimal example.
- Production-shaped example.
- Anti-pattern example.
- Refactoring example.
- Test example.

## Review assets для добавления в каждую главу
- PR checklist.
- Architecture review checklist.
- Performance review checklist.
- Security/privacy review checklist.
- Release-readiness checklist.
