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
#### Упражнения, проверочные вопросы и эталонные ответы
- Как правильно применять концепцию.
- Типовое использование API.
- Простые примеры.
- Базовые ошибки.

### Уровень 2 — Senior
#### Ожидаемая глубина объяснения
#### Признаки, что читатель освоил этот уровень
#### Типичные ошибки на этом уровне
#### Упражнения, проверочные вопросы и эталонные ответы
- Правила ownership.
- Поведение при сбоях.
- Performance-последствия.
- Тестируемость.
- Production-ограничения.

### Уровень 3 — Lead
#### Ожидаемая глубина объяснения
#### Признаки, что читатель освоил этот уровень
#### Типичные ошибки на этом уровне
#### Упражнения, проверочные вопросы и эталонные ответы
- Стратегия миграции.
- Границы ответственности команд.
- Процесс review.
- Delivery-риски.
- Cross-feature consistency.

### Уровень 4 — Staff / Architect
#### Ожидаемая глубина объяснения
#### Признаки, что читатель освоил этот уровень
#### Типичные ошибки на этом уровне
#### Упражнения, проверочные вопросы и эталонные ответы
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
13. **Senior-level Q&A с ответами**
14. **Staff-level tradeoff-ы**
15. **Примеры кода для добавления**
16. **Чеклисты**
17. **Упражнения с критериями проверки / ответами**
18. **Дополнительное чтение / источники**


## Политика дискретного расширения
Используй этот outline как granular content backlog, а не только как оглавление. При раскрытии глав сохраняй каждую существующую часть, главу и секцию, затем заполняй самый точный подраздел, соответствующий материалу. Лучше добавить новый подраздел более низкого уровня, чем смешивать несвязанную теорию, runtime-поведение, production-правила, примеры, упражнения и review Q&A в одном блоке.

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
5. превратить mental model в production-правила, примеры и review Q&A с ответами.

#### Определение и mental model
iOS-приложение — это **guest process** в user-first, battery-powered, privacy-controlled операционной системе. Приложение может запрашивать ресурсы; система решает, доступны ли они, как долго они доступны и с каким приоритетом. Неправильная mental model: «моё приложение работает, пока само не завершится». Правильная ментальная модель: **система постоянно арбитрирует foreground priority, background eligibility, memory pressure, CPU scheduling, I/O, network access, thermal pressure и privacy permission surfaces между всеми приложениями и системными сервисами**.

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

Код может быть корректным и одновременно давать плохой UX, если монополизирует main actor. Senior review должен фиксировать не вопросы без ответа, а конкретные проверки с ожидаемым решением:
- **Derived collections в `body`:** если view вычисляет большие derived collections во время `body` evaluation, вынеси computation в model/preprocessing layer или memoized state с явной invalidation boundary.
- **Heavy work на main actor:** image decoding, JSON parsing, массовое date formatting и persistence fetches не должны выполняться на main actor во время launch, navigation или scrolling.
- **Broad invalidation:** если small state change invalidates большое view tree, сузь observation boundary, выдели row/input subviews или раздели state ownership.
- **Async post-processing:** если async task возвращается на main actor с тяжёлой обработкой, перенеси post-processing off-main и назначай на main actor только финальное UI state.
- **Partial progress и cancellation:** long operation должна показывать progress/cancel/retry там, где это повышает trust; all-or-nothing blocking допустим только для короткой bounded работы.

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
Используй эти heuristics при review features. Каждая проверка включает ожидаемое правило, а не оставляет вопрос без ответа:
1. **Проверка interruption:** app может быть killed между meaningful steps. **Правило:** user-visible operation проектируется с persistence/recovery на границах `await`, navigation и background transition.
2. **Проверка smallest durable fact:** сначала сохраняется минимальный факт, который нельзя потерять. **Правило:** persist user intent и irreversible decisions до large derived state.
3. **Проверка bounded resource:** у каждой feature есть реальный лимит. **Правило:** явно назвать memory, CPU, network, disk, battery, privacy, user attention, server quota или team comprehension budget.
4. **Проверка cancellation:** работа, потерявшая user value, не должна продолжаться бесконечно. **Правило:** cancellable всё, что больше не user-visible и не сохраняет data integrity.
5. **Проверка deferral:** не вся полезная работа должна выполняться сейчас. **Правило:** всё, что не нужно для следующего user-visible state, делается lazy, incremental или scheduled.
6. **Проверка degradation:** constrained runtime требует заранее заданного degraded behavior. **Правило:** определить поведение при offline, denied permission, Low Power Mode, thermal pressure, memory pressure и stale server state.
7. **Проверка production evidence:** release считается успешным только при observable proof. **Правило:** заранее определить metrics, logs, diagnostics и support signals, показывающие health после release.

#### Production checklist с ожидаемыми ответами
Feature не production-ready в constrained runtime, пока каждый пункт не имеет защищаемого ответа:
- **Process death:** durable остаются user intent, critical persisted state, idempotency keys и recovery metadata; transient UI/cache можно восстановить.
- **Suspension mid-operation:** операция имеет checkpoint или безопасно повторяется; background continuation не считается guaranteed.
- **Screen disappears:** screen-owned fetch/prefetch/rendering work отменяется; critical mutation переходит под durable owner.
- **Before network acknowledgement:** persist-ятся local mutation, operation id, affected entity, desired value, timestamp и sync status.
- **Retry policy:** retry выполняется только для safe/idempotent operations, с idempotency key, bounded backoff и cancellation/relevance checks.
- **Memory footprint:** определён largest realistic input, steady-state footprint и peak во время buffering/decoding/mapping/rendering.
- **Main-actor work:** launch, navigation и scrolling не выполняют avoidable decoding, parsing, persistence fetches, heavy formatting или broad invalidation.
- **Low Power Mode / thermal:** speculative work снижается или отменяется; correctness-critical work остаётся bounded и observable.
- **Permissions denied/revoked/restricted:** UI имеет first-class states, альтернативы или честное explanation; app reconciles state после изменений.
- **Disk full / file protection:** writes имеют failure handling, atomicity/transactional strategy и user-safe recovery; до unlock app не ломает launch.
- **Logging:** logs/analytics/crash metadata redacted; raw PII, tokens, payloads, precise location и sensitive filenames не попадают наружу.
- **Production detection:** после release отслеживаются hangs, launch regressions, memory terminations, disk writes, high energy usage и user-visible failures.

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

#### Senior interview и review Q&A
Эти Q&A отделяют поверхностное знание от production judgment.

1. **Почему iOS app не может предполагать, что получит final termination callback?**
   **Ответ:** iOS может завершить процесс non-cooperatively: из-за jetsam, crash, force quit, reboot, update или system policy. `applicationWillTerminate` и lifecycle callbacks не являются durable persistence mechanism. Всё пользовательски значимое состояние нужно сохранять до рискованного перехода, а cleanup callbacks рассматривать только как best-effort opportunity.

2. **Чем отличаются scene lifecycle, process lifetime и task lifetime?**
   **Ответ:** process lifetime отвечает за существование app process в памяти; scene lifecycle — за конкретное UI-окно/scene и её foreground/background состояние; task lifetime — за async work, её cancellation, suspension, ownership и expiration. Ошибка — привязать critical work к scene или view, если product contract требует пережить исчезновение UI.

3. **Как feature остаётся корректной, если app killed между local mutation и server acknowledgement?**
   **Ответ:** feature должна сначала durable сохранить user intent с idempotency key и sync status, а потом выполнять best-effort delivery. После relaunch она reconciles local pending state с server state: повторяет безопасно, помечает conflict или показывает recoverable error. In-memory optimistic UI не считается durability.

4. **Почему compressed 200 KB image может создать multi-megabyte memory pressure?**
   **Ответ:** compressed file size не равен decoded pixel buffer. После decoding memory зависит от dimensions, scale, pixel format, intermediate buffers и caching. Thumbnail UI должен downsample image до display size до создания UI image, иначе малый файл может создать большой resident/dirty footprint.

5. **Что должно происходить с image prefetching в Low Power Mode или serious thermal state?**
   **Ответ:** prefetching обычно speculative, поэтому его нужно снижать, отменять или откладывать. В Low Power Mode приоритет — меньше wakeups, network и decoding; при serious/critical thermal state — быстрое load shedding: остановить prefetch, уменьшить concurrency и не начинать тяжёлую обработку.

6. **Как решить, безопасен ли retry для failed network request?**
   **Ответ:** retry безопасен, если operation idempotent или имеет idempotency key, failure transient, user intent всё ещё актуален, retry bounded и используется backoff. Blind retry non-idempotent mutation может создать duplicate side effects, battery drain, server load и inconsistent UI.

7. **Что делает background task idempotent?**
   **Ответ:** task может быть запущена повторно, пропущена или прервана без нарушения данных. Для этого нужны durable checkpoints, stable operation ids, safe retry, no duplicate side effects и recovery после partial completion. Background timing нельзя считать contractual scheduler-ом.

8. **Что memory termination report показывает такого, чего может не быть в Swift stack trace?**
   **Ответ:** jetsam/memory termination часто не даёт обычный Swift exception stack. Reports и organizer metrics показывают pressure context, footprint, termination reason и affected device/OS pattern. Это помогает отличить leak, peak decoding, cache pressure и dirty memory growth от обычного crash.

9. **Почему broad `@Observable` model рискован для больших SwiftUI lists?**
   **Ответ:** широкая observation boundary может invalidating большой view tree при малом state change. В списках это превращает точечные изменения в массовую recomputation/layout работу. Нужны узкие state slices, stable identity, row-level inputs и перенос expensive derived work вне `body`.

10. **Как доказать после release, что launch optimization улучшила real user experience?**
    **Ответ:** нужны production metrics: cold/warm launch distribution, time-to-interactive, hang rate, crash/jetsam rate, device/iOS segmentation и regression guardrails. Simulator или локальный single-device замер не доказывает улучшение real user experience.

11. **Что нужно persist до long-running sync?**
    **Ответ:** smallest durable facts: user intent, operation/idempotency key, affected entity, desired value, local timestamp, retry metadata, progress checkpoint и sync status. Derived server response или temporary UI state можно восстановить; user intent потерять нельзя.

12. **Какие constraints являются product constraints, а не только technical constraints?**
    **Ответ:** offline behavior, stale state, permission denial, battery use, background timing, data retention, privacy disclosure, conflict resolution и recovery UX — это product constraints. Они определяют обещание пользователю, support burden и App Review/compliance risk, а не только implementation details.

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

### 1.2. Ограничения памяти, батареи, теплового режима и сети
#### Назначение раздела
Эта секция раскрывает четыре ограничения, которые чаще всего превращают корректный в simulator код в нестабильное production-приложение: **память**, **батарея**, **тепловой режим** и **сеть**. Их нельзя рассматривать как отдельные оптимизации в конце проекта. Они формируют contract фичи с платформой: сколько данных можно держать, когда можно работать, как долго можно ждать network, что делать при partial failure и какие promises UI имеет право давать пользователю.

Ключевая мысль: iOS-приложение не владеет ресурсами безусловно. Оно временно получает memory pages, CPU time, radio access, background opportunities и thermal headroom. Система может в любой момент изменить доступность этих ресурсов, а пользователь всё равно ожидает, что продукт не потеряет данные, не зависнет, не израсходует батарею и честно покажет состояние.

#### Ментальная модель
Ограничения ресурсов лучше мыслить как **runtime budget**, а не как набор случайных edge cases.

- **Память** ограничивает объём resident/dirty pages, decoded media, object graphs, caches и temporary peaks.
- **Батарея** ограничивает частоту wakeups, network radio usage, sensor usage, CPU/GPU intensity, background work и logging.
- **Тепловой режим** ограничивает длительную resource-intensive работу и требует graceful degradation.
- **Сеть** ограничивает latency expectations, delivery guarantees, freshness, retry strategy, offline behavior и server consistency.

Senior-level design не ограничивается проверкой «помещается ли это в память сейчас» или «работает ли запрос на Wi‑Fi». Он фиксирует конкретные параметры:
1. какой worst realistic input;
2. какой peak footprint во время decoding/mapping/rendering;
3. какая работа user-visible, а какая speculative;
4. что можно cancel, defer, batch или downsample;
5. что должно быть durable до network acknowledgement;
6. какое degraded поведение показывается пользователю;
7. какие diagnostics докажут состояние в production.

В `### 1.1. iOS как constrained runtime` была platform-level mental model: система владеет ресурсами и lifecycle. Здесь уровень ниже и практичнее: **feature-level contract under constraints**. Раздел отвечает не только «какие ограничения существуют», а «как конкретная фича должна проектировать данные, work, retries, cache, diagnostics и degradation, если эти ограничения сработают одновременно».

#### Четыре бюджета фичи
Чтобы не сваливать memory, battery, thermal и network в одну общую «производительность», полезно проверять feature по четырём отдельным бюджетам.

| Бюджет | Что реально ограничено | Типичный failure mode | Production decision rule | Что измерять |
| --- | --- | --- | --- | --- |
| Память | resident/dirty pages, decoded buffers, object graphs, temporary peaks | jetsam, hitches из-за decoding, cache pressure | держать bounded state, downsample media, избегать whole-graph retention | peak/resident memory, memory terminations, cache size, decoded image footprint |
| Батарея / energy | wakeups, radio use, CPU/GPU time, sensor lifetime, disk writes | быстрый battery drain, excessive background activity, throttling доверия пользователя | batch, defer, cancel speculative work, снижать polling и использовать system scheduling | wakeups, background time, upload frequency, sensor duration, energy diagnostics |
| Тепловой режим | текущая способность устройства продолжать тяжёлую работу | serious/critical thermal state, sustained hangs, FPS drop | load shedding: отключать prefetch, снижать качество обработки, переносить nonessential work | thermal state, dropped frames, hangs, task duration, abandonment |
| Сеть | reachability, latency, bandwidth, radio tail, server quotas, auth/session lifetime | stale UI, duplicate mutations, timeout storms, conflict/data loss | idempotency, backoff, local intent durability, explicit stale/conflict UI | error taxonomy, latency buckets, retry count, stale duration, conflict rate |

Battery и thermal связаны, но не одинаковы. **Battery** — это стоимость работы во времени: частые timers, polling, мелкие uploads, repeated disk writes, sensor sessions и radio wakeups могут быть вредны даже при нормальной температуре. **Thermal** — это runtime feedback, что устройство уже находится под давлением; реакция должна быть быстрее и жёстче: остановить speculative work, снизить concurrency, отменить prefetch, уменьшить качество обработки там, где это допустимо, и не начинать тяжёлые background jobs.

Staff-level tradeoff обычно выглядит так:

| Цель | Соблазнительная оптимизация | Скрытая цена | Предпочтительное правило |
| --- | --- | --- | --- |
| Максимальная свежесть | refresh/poll чаще | battery drain, radio tail, server load | freshness SLA через opportunistic refresh, push, backoff и visible stale state |
| Быстрый список | aggressive prefetch всех изображений | decoded memory peak, network waste, thermal pressure | bounded prefetch только для likely-visible content, cancellation on scroll-away |
| Мгновенный save | optimistic UI без durable intent | data loss после kill/offline | сначала persist smallest user intent, затем best-effort delivery |
| Меньше network latency | retry aggressively | duplicate mutations, battery/server load | retry только safe/idempotent operations с backoff и observability |
| Богатая диагностика | логировать payload и context | PII/token leakage, compliance risk | redacted structured diagnostics и correlation ids |

#### Контракт и ownership данных
Feature contract должен явно отвечать, какие данные являются **source of truth**, какие являются derived/cache state, а какие существуют только как transient rendering state.

Практическое правило ownership:
- **user intent** принадлежит продуктовой feature и должен быть durable до попытки unreliable delivery;
- **remote response** принадлежит backend contract, но app обязана валидировать mapping и compatibility;
- **cache** принадлежит performance layer и не должен становиться единственным источником пользовательски значимого состояния;
- **decoded media** принадлежит UI/runtime budget и должна иметь bounded lifetime;
- **in-memory model** принадлежит rendering/coordination, но не durability;
- **background work** принадлежит lifecycle policy и не имеет права быть единственным способом завершить critical state transition.

Если пользователь поставил лайк, отправил форму, сохранил черновик, изменил настройку или начал upload, приложение должно сначала определить smallest durable fact. Обычно это не весь response DTO и не весь экранный state, а минимальная запись вида: intent id, affected entity id, desired value, idempotency key, timestamp, retry metadata и текущий sync status.

Антипаттерн: считать, что локальная optimistic mutation безопасна, потому что network request «почти всегда успешен». Правильный contract: UI может быть optimistic, но underlying user intent должен пережить app suspension, process death, network loss и retry.

#### Request/response и правила mapping
Network payload нельзя напрямую превращать в unlimited app state. Mapping должен быть местом, где feature защищает memory, battery и correctness.

Production mapping rules:
- не храни whole DTO graph, если экрану нужны только несколько domain fields;
- валидируй payload size до expensive decoding, где это возможно;
- отделяй transport success от domain success: HTTP 200 с конфликтным business state не является полноценным успехом;
- делай mapping streaming/incremental для больших ответов, если whole-array decoding создаёт peak memory risk;
- нормализуй identity до попадания данных в UI state;
- не запускай expensive formatting, image decoding или layout preparation внутри SwiftUI `body`;
- не смешивай freshness metadata с domain truth: `lastUpdatedAt`, `isStale`, `syncStatus` и server version должны быть явными.

Request contract должен включать cancellation. Screen-owned request отменяется, когда screen disappears или query устарела. Mutation request может быть отменён transport-level, но user intent не должен исчезать, если продукт обещал сохранить действие.

Пример различия:
- поиск по тексту можно отменить и забыть, если пользователь ввёл новый query;
- сохранение профиля нельзя просто забыть, если UI уже показал, что изменение принято;
- image prefetch можно отменить при scroll-away;
- upload должен иметь durable progress/cleanup policy.

#### Failure, retry, cancellation и idempotency behavior
Failure taxonomy должна быть частью design, а не catch-all строкой для alert.

Минимальная taxonomy:
- **transport failure**: offline, timeout, DNS, TLS, connection reset;
- **server failure**: 5xx, throttling, maintenance;
- **client contract failure**: invalid request, auth expiry, permission mismatch;
- **decoding/mapping failure**: backend response не соответствует app contract;
- **domain conflict**: version conflict, duplicate mutation, stale state;
- **resource failure**: memory pressure, disk full, background expiration, Low Power Mode constraints.

Retry policy должна быть безопасной:
- retry read-запросов обычно допустим с backoff и cancellation;
- retry non-idempotent mutations без idempotency key может создать duplicate side effects;
- retry в background не должен предполагать точное расписание;
- retry не должен держать high-priority work бесконечно;
- retry должен прекращаться, если пользовательский intent отменён или заменён.

Idempotency — это не только backend feature. iOS client должен сохранять client-generated idempotency key рядом с durable intent. Если app killed после отправки request, но до обработки response, следующий launch должен уметь reconcile: проверить server state, повторить безопасно или показать conflict state.

Cancellation не является failure. Это нормальный outcome lifecycle-aware работы. Ошибка senior-level implementation — превращать cancellation в пользовательский error message или retry storm.

#### Offline, cache и persistence-последствия
Offline support начинается не с красивого empty state, а с явного правила: **какое состояние пользователь имеет право считать сохранённым**.

Уровни offline-поведения:
1. **Read-only stale cache**: пользователь может читать старые данные, но UI явно показывает freshness.
2. **Optimistic local mutation**: пользовательские изменения видны сразу и синхронизируются позже.
3. **Local-first model**: локальное состояние является primary UX source, а server — sync peer.
4. **Conflict-aware sync**: app умеет обнаруживать и разрешать server/client divergence.

Cache rules:
- cache должен быть bounded по memory и disk;
- cache eviction не должен удалять unsynced user intent;
- cache key должен учитывать user/account/environment/security scope;
- image cache должен учитывать decoded footprint, а не только compressed file size;
- persistence schema должна поддерживать migration и cleanup;
- stale data должна быть видимой для product logic, а не спрятанной в repository.

Persistence rules:
- сохраняй critical intent до network delivery;
- сохраняй checkpoints до long-running background work;
- не используй UserDefaults как произвольную database для растущих структур;
- не делай repeated whole-file rewrites для часто меняющегося structured state;
- учитывай file protection, disk full, app group coordination и migration failure.

#### Security, privacy и logging-ограничения
Resource constraints не отменяют privacy/security; наоборот, under-pressure paths часто создают утечки.

Недопустимые практики:
- логировать raw request/response payloads с PII;
- писать tokens, authorization headers, precise location, contacts, health data или sensitive filenames в logs/crash metadata;
- хранить token-like значения в plain cache или UserDefaults;
- использовать общий cache между users/accounts без scope separation;
- оставлять temporary files после failed upload/import;
- отправлять analytics events с user-entered text для диагностики failures.

Privacy-safe diagnostics должны отвечать на engineering-вопрос без раскрытия sensitive data. Вместо payload логируются: redacted endpoint category, error class, retry count, idempotency key hash, payload size bucket, network type category, cache hit/miss, thermal state, Low Power Mode flag, duration bucket и correlation id.

Security tradeoff: иногда хочется сохранить больше данных для offline/debug support. Staff-level решение требует data minimization: если данные не нужны для user value, recovery или compliance, они не должны сохраняться «на всякий случай».

#### Test matrix и production diagnostics
Полноценная проверка этой темы не ограничивается happy-path unit test.

Минимальная test matrix для feature, чувствительной к памяти/батарее/сети:
- cold launch после pending mutation;
- app killed между local persistence и server acknowledgement;
- offline при первом запросе и offline после stale cache;
- timeout и retry с backoff;
- duplicate mutation с тем же idempotency key;
- cancellation при уходе со screen;
- large response и large image set;
- memory warning / high memory footprint scenario;
- Low Power Mode;
- serious/critical thermal state, если feature запускает heavy work;
- disk full или persistence write failure;
- auth expiry во время retry;
- account switch и cache isolation;
- background expiration во время sync/upload.

Production diagnostics должны заранее отвечать, как команда увидит проблему после release:
- memory termination rate by screen/flow;
- launch time и time-to-interactive;
- request latency/error taxonomy;
- retry counts и retry exhaustion;
- offline duration и stale data exposure;
- cache hit ratio и eviction rate;
- background task expiration rate;
- battery/energy regressions через available system metrics;
- thermal-state correlation с hangs/dropped frames;
- redacted support logs с correlation ids.

#### Типичные ошибки
- Считать network success частью UI correctness без durable local intent.
- Хранить весь response DTO вместо минимального domain/view state.
- Декодировать большие изображения в размере source asset, а не display target.
- Делать retry любой ошибки без idempotency и backoff.
- Прятать stale state внутри repository и показывать UI как будто данные свежие.
- Делать cache unbounded, потому что «iOS сама освободит память».
- Писать detailed diagnostics в logs с PII.
- Использовать background refresh как contractual scheduler.
- Путать cancellation с failure.
- Не иметь метрик, которые отличают server issue от client resource issue.

#### Senior / Lead / Staff проверочные Q&A
1. **Какой maximum realistic memory footprint у feature на worst input?**
   **Ответ:** его считают по worst realistic dataset: количество элементов, размер payload, decoded media, temporary buffers, cache и view/rendering overhead. Важно оценивать не только steady-state, но и peak во время fetch → decode → map → render.

2. **Где возникает peak memory: network buffering, decoding, mapping, rendering или image decompression?**
   **Ответ:** peak ищут по pipeline, а не по итоговому model size. Частые источники — whole-response buffering, full-array decoding, intermediate DTO/domain arrays, image decompression, attributed text/layout caches и simultaneous prefetch.

3. **Что является smallest durable user intent?**
   **Ответ:** минимальная запись, которая доказывает намерение пользователя и позволяет восстановить operation: entity id, desired change, operation/idempotency key, timestamp, account scope и sync status. UI state и server response — вторичны.

4. **Какие requests можно отменить без product loss, а какие требуют recovery?**
   **Ответ:** search, prefetch, preview loading и obsolete screen fetch обычно можно отменять без recovery. Mutations, uploads, payments, saves и user-confirmed actions требуют durable intent, retry/reconcile и user-visible status.

5. **Какие mutations idempotent, и где хранится idempotency key?**
   **Ответ:** mutation idempotent, если повторная delivery с тем же key не создаёт второй side effect. Key должен храниться рядом с durable pending operation, переживать process death и использоваться при retry/reconcile.

6. **Что пользователь увидит при stale cache, offline и retry exhaustion?**
   **Ответ:** UI должен честно показывать freshness, offline status, pending changes и recoverable action. Нельзя скрывать stale data как свежие или превращать retry exhaustion в silent failure.

7. **Какие данные нельзя логировать даже при production incident?**
   **Ответ:** tokens, auth headers, raw payloads, PII, precise location, document contents, private filenames, contact data, health/financial data и user-generated private text. Диагностика должна использовать redacted categories, buckets и correlation ids.

8. **Как cache разделён между accounts/environments/security scopes?**
   **Ответ:** cache key и storage должны включать user/account, environment и data sensitivity. Account switch/logout не должен показывать stale private data другого пользователя; shared cache допустим только для truly public/regenerable content.

9. **Как feature деградирует в Low Power Mode или serious thermal state?**
   **Ответ:** она отменяет speculative work, снижает prefetch/concurrency, batch-ит network/disk, уменьшает качество expensive processing и сохраняет correctness-critical work. Thermal response должен быть быстрее, чем обычная energy optimization.

10. **Какие metrics докажут, что release не ухудшил memory, battery и network behavior?**
    **Ответ:** memory terminations, peak/resident memory, hang/dropped-frame rate, request latency/error taxonomy, retry counts, cache hit/eviction rate, background expiration, energy diagnostics, thermal correlations и segmented rollout comparisons.

#### Чеклист production-readiness
Feature, зависящая от памяти, батареи, теплового режима или сети, не готова к production, пока нет ответов:
- определён source of truth и durable user intent;
- request cancellation не ломает product correctness;
- retry policy безопасна и bounded;
- mutations используют idempotency там, где возможна duplicate delivery;
- cache bounded и scoped;
- large payload/media не создают uncontrolled peak memory;
- Low Power Mode и thermal state имеют degradation policy;
- offline/stale/conflict states отражены в UI;
- logs/analytics/crash metadata redacted;
- persistence failures имеют recoverable behavior;
- diagnostics позволяют отличить memory, network, server, auth и mapping failures.

### 1.3. App sandbox и границы файловой системы
#### Назначение раздела
App sandbox — это не только security-механизм, который «не даёт приложению читать чужие файлы». Для senior-level iOS engineering это архитектурная граница владения данными, жизненного цикла данных, политики резервного копирования, privacy exposure, взаимодействия с extensions и incident response. Sandbox определяет, какие файлы приложение может создать, какие внешние ресурсы может временно открыть, какие данные переживают reinstall, backup и logout, какие shared containers доступны extensions и где легко случайно нарушить ожидания пользователя.

Правильная ментальная модель: приложение работает в собственном контейнере, но даже внутри контейнера данные имеют разные уровни доверия и разные жизненные циклы. `Documents`, `Library/Application Support`, `Library/Caches`, temporary directories, bundle resources, Keychain, App Group container и security-scoped external files нельзя смешивать как «просто пути на диске». Каждый storage location несёт product contract: видимость пользователю, backup behavior, ожидания cleanup, file protection, sensitivity и recoverability.

#### Модель угроз и защищаемые assets
Модель угроз начинается с инвентаризации assets. Без неё команда не понимает, что именно защищает sandbox и какие дополнительные меры нужны поверх sandbox.

Типовые защищаемые assets:
- **credentials и tokens**: access/refresh tokens, session identifiers, API keys, OAuth state, device-bound secrets;
- **user-generated content**: документы, фото, аудио, PDF, черновики, импортированные файлы, attachments;
- **personal data**: имя, email, phone, contacts-derived data, location, health-like data, financial data, private messages;
- **product state**: pending mutations, drafts, offline queue, local database, feature flags, entitlement state;
- **diagnostic data**: logs, crash breadcrumbs, metrics, support bundles, correlation ids;
- **derived/cache data**: thumbnails, decoded media, search indexes, temporary exports, downloaded previews.

Sandbox снижает blast radius между apps, но не делает данные автоматически безопасными внутри app boundary. Если sensitive data попадает в неправильный directory, backup, log file, crash report, shared container или temporary export, sandbox уже не решает проблему. Senior review должен рассматривать классы атакующих:
1. пользователь с доступом к device backup или shared Mac;
2. другой app, который пытается получить данные через extension, pasteboard, URL scheme, document picker или share sheet;
3. malicious/compromised SDK внутри того же process;
4. support/analytics/crash pipeline, куда утекли некорректно redacted данные;
5. команда разработки, случайно добавившая secret fixture или verbose logging.

#### Механизмы платформы и entitlement surface
iOS app container обычно включает несколько разных областей с разной семантикой:

| Область | Типичное назначение | Production-правило | Риск |
| --- | --- | --- | --- |
| App bundle | read-only ресурсы приложения | не хранить runtime data | попытка мутировать bundle или хранить config как runtime state |
| `Documents` | пользовательские документы, видимые как durable content | класть только user-owned data, которое должно быть backup-eligible | unintended backup sensitive/cache data |
| `Library/Application Support` | durable app-managed data | подходит для databases, queues, configuration, но требует protection/retention policy | данные переживают дольше, чем ожидает пользователь |
| `Library/Caches` | regenerable data | cache должен быть recreatable и bounded | потеря cache не должна ломать correctness |
| temporary directory | краткоживущие промежуточные файлы | cleanup обязателен после success/failure/cancel | temporary sensitive data остаётся на диске |
| App Group container | shared state между app/extensions/widgets | нужен явный ownership, locking/coordination и cleanup | runtime coupling, privacy leak между targets |
| Keychain | secrets и credentials | выбирать accessibility class и logout/revocation behavior | tokens сохраняются после logout/reinstall без осознанного contract |

Entitlements расширяют sandbox surface: App Groups, Keychain Sharing, iCloud, Associated Domains, Push, Background Modes, HealthKit, Photos, Camera, Bluetooth и другие capabilities. Staff-level правило: entitlement — это не «checkbox в Xcode», а изменение trust boundary и review surface. Каждый entitlement должен иметь owner, rationale, data flow, denial behavior, logging policy и release verification.

Особенно опасны shared containers. Widget, share extension и main app могут читать одну область, но это не значит, что они должны видеть все данные друг друга. Нужны минимальные shared records, versioned schema, atomic writes, file coordination там, где есть concurrent access, и cleanup при logout/account switch.

#### Жизненный цикл данных, retention и deletion behavior
Файловая граница должна проектироваться вместе с lifecycle данных. Для каждого типа данных нужно определить:
- где он хранится;
- sensitive ли он;
- должен ли попадать в backup;
- должен ли переживать logout;
- должен ли переживать account switch;
- можно ли его восстановить с server;
- кто отвечает за deletion;
- как работает migration;
- что происходит при disk full, file protection lock и partial write.

Матрица жизненного цикла данных:

| Тип данных | Где хранить | Backup | Logout/account switch | Delete behavior |
| --- | --- | --- | --- | --- |
| Access/refresh token | Keychain | зависит от accessibility class: migratable classes могут участвовать в backup/restore, `ThisDeviceOnly` привязан к устройству | удалить или revoke по session policy; помнить, что Keychain item может пережить reinstall | clear credentials, revoke где нужно и invalidate in-memory state |
| Offline mutation queue | Application Support / database | зависит от product promise | сохранить только если user/account совпадает | удалить после successful sync или explicit account deletion |
| User-created document | Documents или document provider location | обычно да, если user-owned | не удалять silently без product requirement | удалить только по user action/account deletion policy |
| Image thumbnails/cache | Caches | нет | очистить при account switch, если содержит private content | regenerable cleanup |
| Temporary export/import | temporary directory | нет | очистить независимо от account | cleanup on success/failure/cancel |
| Support diagnostic bundle | temporary или controlled support area | обычно нет | не переносить между accounts | auto-expire и redact |

File protection важен для данных, которые не должны быть доступны до unlock. Но protection class — это не замена product policy. Например, база может быть защищена, но если из неё пишутся breadcrumbs с PII в crash metadata, защита файла уже не помогает. Аналогично, cache может быть regenerable, но если он содержит private thumbnails, он всё равно sensitive.

Decision rules для file protection:
- `NSFileProtectionComplete` подходит для highly sensitive user data, к которому app не должна обращаться до unlock; риск — сломать launch/background paths, если код не готов к unavailable files.
- `NSFileProtectionCompleteUntilFirstUserAuthentication` часто подходит для databases/queues, которые должны быть доступны после первого unlock и переживать background work, но всё ещё защищены до unlock после reboot.
- Less restrictive protection нельзя выбирать ради удобства без documented product reason и security review.
- File protection decision должен проверяться вместе с lifecycle: cold launch after reboot, background task, widget/extension access, migration и support export.
- Если данные дублируются в cache, thumbnails, logs или App Group, protection class primary file уже не покрывает весь риск.

Keychain требует отдельной политики. Некоторые Keychain items могут переживать reinstall, а backup/restore поведение зависит от accessibility class и выбора migratable vs `ThisDeviceOnly`. Поэтому logout/account deletion должны явно удалять relevant Keychain entries, а не полагаться на uninstall как cleanup mechanism.

Retention должен быть минимальным. Данные, которые не нужны для user value, recovery, legal requirement или диагностики, не должны сохраняться. Staff-level governance требует явного retention owner: кто решает срок хранения, кто меняет policy, как policy проверяется в release и как пользователь может запросить удаление.

#### Границы внешних файлов и imported content
Document picker, Photos picker, share extension, URL schemes, Universal Links, pasteboard и drag-and-drop — это внешние input boundaries. Нельзя считать файл безопасным только потому, что его выбрал пользователь или передал system UI.

Правила:
- проверяй type, size, extension, MIME/UTType и фактическое содержимое, где возможно;
- не доверяй filename: он может содержать sensitive text, path-like strings или control characters;
- не сохраняй security-scoped URL как обычный durable path без bookmark/access policy;
- копируй импортированный файл в controlled app storage, если feature должна владеть им долговременно;
- отличай временную capability доступа от ownership: security-scoped access даёт право открыть внешний ресурс, но не делает его durable app-owned file;
- очищай temporary copies после failed parsing/upload/share;
- не открывай arbitrary URL/file без allowlist и validation;
- не выполняй preview/rendering больших файлов на main actor;
- рассматривай malformed PDF/image/archive как потенциальный memory, performance и security input.

Граница внешнего файла — это одновременно security- и reliability-тема. Большой PDF может не быть malicious, но всё равно вызвать memory spike. Неверный file protection timing может сломать cold launch до unlock. Share extension может записать partial state, который main app увидит после crash extension. Поэтому validation, atomic writes и versioned handoff обязательны.

#### Ограничения logging, analytics и crash reporting
Sandbox не защищает данные, если приложение само отправило их в logs, analytics или crash pipeline. Production diagnostics должны быть redacted by design.

Запрещено логировать:
- tokens, authorization headers, cookies, session ids;
- raw file paths, если path содержит user/account/document names;
- precise location, contacts, private messages, document text, health/financial data;
- импортированные filenames без redaction;
- raw request/response bodies;
- screenshots или attachments с private content без explicit user-controlled support flow.

Допустимая диагностика:
- storage category вместо full path: `documents`, `cache`, `appGroup`, `temporary`;
- file size bucket вместо точного filename/content;
- error class вместо payload;
- account/user hash только если policy разрешает и hash не reversible;
- correlation id;
- operation id, retry count, cleanup result, file protection state category;
- redacted entitlement/capability state.

Crash breadcrumbs особенно опасны: они часто добавляются в спешке для incident debugging и потом годами отправляют sensitive context. Senior review должен спрашивать не «поможет ли log debug-у», а «можно ли безопасно хранить и передавать эту строку для всех users, accounts, locales и jurisdictions».

Storage и export decisions также влияют на privacy manifest и declared data use. Если app сохраняет diagnostics, импортированные documents, thumbnails, identifiers или shared App Group data, это должно соответствовать фактическому data flow, SDK usage и privacy disclosures. Privacy manifest не должен описывать желаемую архитектуру; он должен отражать реальное поведение runtime и third-party SDKs.

#### Review checklist и incident response
Security/privacy review sandbox-sensitive feature должен включать минимум:
- составлен sensitive data inventory;
- для каждого data type выбран storage location и backup policy;
- tokens/secrets не попадают в UserDefaults, files, logs, analytics или crash metadata;
- выбран Keychain accessibility class и описан logout/revocation behavior;
- App Group data минимизирована, versioned и имеет owner;
- external input проходит type/size/content validation;
- temporary files очищаются на success, failure и cancellation;
- writes для critical data atomic или transactional;
- disk full и file protection unavailable имеют user-safe behavior;
- account switch не смешивает данные разных users;
- deletion/retention policy реализована и проверяема;
- diagnostics redacted и bounded;
- entitlements имеют documented rationale;
- privacy manifest и permission strings соответствуют реальным data flows.

Incident response должен быть заранее понятен. Если обнаружена утечка через file storage или diagnostics, команда должна уметь быстро ответить:
1. какие versions затронуты;
2. какие data categories могли попасть наружу;
3. через какой channel произошла утечка: backup, logs, crash, analytics, shared container, support export;
4. можно ли remote-disable problematic logging/export;
5. нужна ли token revocation, cache purge, migration или user notification;
6. какие tests/gates предотвращают повтор.

P0/P1 findings по умолчанию: insecure token persistence, PII/secret logging, unintended backup sensitive data, unvalidated external file execution path, shared container leak между accounts/targets, missing privacy explanation для shipped capability.

#### Senior / Lead / Staff проверочные Q&A
1. **Какие assets защищает sandbox в этой feature, а какие остаются exposed через logs, backups или shared containers?**
   **Ответ:** sandbox защищает app container от других apps, но не защищает от собственных logs, analytics, crash metadata, backups, support exports и App Group sharing. Review должен перечислить credentials, user content, derived data, diagnostics и cache surfaces отдельно.

2. **Почему выбран именно этот storage location, а не `Caches`, `Documents`, Application Support, Keychain или App Group?**
   **Ответ:** выбор должен следовать semantics: user-owned durable documents — в `Documents`; app-managed durable state — в Application Support/database; regenerable data — в `Caches`; secrets — в Keychain; cross-target minimum state — в App Group. Если reason нельзя объяснить, storage location выбран случайно.

3. **Что происходит с данными при logout, account switch, uninstall/reinstall, restore from backup и account deletion?**
   **Ответ:** для каждого data type нужна policy: что удаляется, что сохраняется, что re-scoped, что может пережить reinstall через Keychain, что возвращается через backup/restore и что удаляется при account deletion. Silent carryover private data между accounts — security/privacy bug.

4. **Какие файлы должны быть excluded from backup и почему?**
   **Ответ:** regenerable caches, thumbnails, temporary exports, downloaded previews и sensitive diagnostic bundles обычно не должны попадать в backup. User-owned documents и durable user data могут быть backup-eligible, если это соответствует product promise и privacy policy.

5. **Какой file protection class нужен для sensitive data, и что делает app до first unlock?**
   **Ответ:** highly sensitive files часто требуют `NSFileProtectionComplete`; databases/queues, нужные после первого unlock, часто используют `NSFileProtectionCompleteUntilFirstUserAuthentication`. App должна иметь behavior для unavailable files до unlock и не ломать cold launch/background paths.

6. **Может ли extension увидеть больше данных, чем ей нужно?**
   **Ответ:** не должна. App Group должен содержать минимальный shared subset, versioned schema и explicit ownership. Extension не должна читать full database/main-app private cache, если ей нужен один widget snapshot или pending handoff.

7. **Что произойдёт, если external file malformed, huge, encrypted, partially available или protected до unlock?**
   **Ответ:** app должна валидировать type/size/content, обрабатывать parse failures, не выполнять heavy preview на main actor, сохранять controlled copy только при принятом ownership и показывать user-safe error. External file всегда untrusted input.

8. **Какие log/crash/analytics fields доказывают проблему без раскрытия sensitive content?**
   **Ответ:** storage category, file size bucket, operation id, redacted error class, cleanup result, protection state category, account-scope hash по policy и correlation id. Raw paths, filenames, payloads и document contents недопустимы.

9. **Есть ли способ быстро отключить risky export/logging path после release?**
   **Ответ:** для sensitive diagnostics/export paths нужен kill switch, remote config или release rollback plan. Incident response должен включать containment, revocation, log deletion/redaction и user/support messaging.

10. **Как reviewer докажет, что temporary sensitive files удаляются на всех paths: success, failure, cancellation и crash recovery?**
    **Ответ:** через code path review, cleanup ownership, tests/manual scenarios для success/failure/cancel, launch-time cleanup of orphaned temp files и bounded retention policy. `defer` полезен, но недостаточен для crash/process death.

#### Чеклист production-readiness
Feature, работающая с file system или sandbox boundaries, не готова к production, пока:
- есть documented sensitive data inventory;
- storage location выбран по user ownership, sensitivity, backup и retention semantics;
- secrets живут в Keychain или approved secure storage;
- App Group и extension boundaries минимизированы;
- external files/URLs валидируются как untrusted input;
- temporary data cleanup покрывает failure/cancellation paths;
- backup exclusions настроены для regenerable/sensitive cache;
- logout/account deletion очищают нужные local data;
- diagnostics не содержат PII/secrets/raw paths/raw payloads;
- incident response описывает containment, revocation, cleanup и regression tests.

### 1.4. Privacy-гейты и модель разрешений
#### Назначение раздела
Privacy-гейт в iOS — это не только системный permission prompt. Это точка, где продукт, платформа и пользовательский контроль сходятся в один контракт: зачем приложению нужен sensitive capability, какие данные будут получены, как долго они живут, что произойдёт при отказе, как пользователь может изменить решение и какие disclosures должны быть правдивы в App Store, privacy manifest, onboarding и runtime UI.

Senior-level ошибка — думать о permissions как о release checklist: добавить `NSCameraUsageDescription`, вызвать API, обработать `.authorized`. Staff-level ментальная модель шире: privacy-гейт — это **trust boundary**. Он защищает не framework API, а user agency. Пользователь должен понимать value exchange до запроса, иметь достойный denied/restricted path после отказа и не получать наказание за privacy-preserving choice.

Эта секция продолжает `1.3`: sandbox отвечает на вопрос «где могут жить данные и кто имеет доступ», а privacy-гейты отвечают на вопрос «почему приложение вообще имеет право получить эти данные или capability».

#### Ментальная модель permissions
Permission — это не property приложения, а revocable grant от пользователя и системы. Grant может быть:
- **not determined**: app ещё не получила решение;
- **authorized**: доступ разрешён в текущем объёме;
- **limited**: доступ частичный, например выбранные Photos assets;
- **denied**: пользователь отказал;
- **restricted**: доступ запрещён policy/device/parental/MDM constraints;
- **unavailable**: capability отсутствует на устройстве, OS version или текущей конфигурации;
- **ephemeral / session-scoped**: доступ существует только в рамках текущего выбора или системного UI flow.

Правило проектирования: permission state должен быть частью product state machine, а не `if` перед вызовом API. UI, analytics, retry, settings navigation, support guidance и feature availability должны различать denied, restricted, limited и unavailable. Смешивание этих состояний в одну ошибку «нет доступа» создаёт плохой UX и неверную поддержку.

#### Threat model и защищаемые assets
Privacy threat model начинается не с attacker, а с определения **user-controlled boundary**, который пересекает feature.

Типовые boundaries:
- **Camera/Microphone**: live capture private environment, faces, voices, documents, screens;
- **Photos/Media Library**: historical personal media, metadata, location, social context;
- **Location**: movement patterns, home/work inference, safety-sensitive context;
- **Contacts/Calendars/Reminders**: third-party personal data, не только данные текущего пользователя;
- **Bluetooth/Local Network**: nearby devices, home topology, workplace environment;
- **Health/fitness-like data**: high-sensitivity behavioral/biometric context;
- **Notifications**: attention channel, lock screen exposure, behavioral nudging;
- **Tracking/advertising identifiers**: cross-app identity and profiling;
- **Pasteboard/Documents/Share flows**: user-generated private content and filenames.

Защищаемые assets включают не только raw data. Часто более опасны derived signals: «пользователь был в клинике», «у пользователя есть дети», «у пользователя определённый документ», «пользователь находится дома», «пользователь отказал в tracking». Такие выводы нельзя бездумно отправлять в analytics, logs или personalization pipeline.

#### Timing и value exchange
Самый важный product decision — когда запрашивать permission. Cold launch prompt почти всегда слабее, чем contextual prompt рядом с понятной user value.

Правила:
- запрашивай доступ в момент, когда пользователь понимает задачу;
- перед системным prompt дай короткий, честный pre-prompt только если он помогает понять value, а не манипулирует;
- не обещай больше, чем реально делает feature;
- не блокируй весь app, если permission нужен только одной feature;
- не повторяй давление после denial; показывай settings path только там, где это действительно помогает;
- не используй dark patterns: guilt wording, fake urgency, misleading buttons, скрытие альтернатив.

Хороший privacy copy отвечает на три вопроса:
1. **зачем** нужен доступ именно сейчас;
2. **что** будет использовано и в каком объёме;
3. **что произойдёт**, если пользователь откажет.

Плохой copy звучит как внутреннее требование приложения: «Разрешите доступ для продолжения». Хороший copy звучит как user-centered объяснение: «Чтобы прикрепить фото к обращению, выберите снимок. Можно выбрать отдельные фото без доступа ко всей медиатеке».

#### Platform mechanism и entitlement surface
Privacy-гейты существуют на нескольких уровнях:

| Уровень | Примеры | Что проверять |
| --- | --- | --- |
| Info.plist usage descriptions | Camera, Microphone, Location, Photos, Contacts | строка соответствует реальному purpose и не является generic boilerplate |
| Runtime authorization API | `AVCaptureDevice`, `CLLocationManager`, Photos, Notifications | все states обработаны, запрос выполняется в правильный момент |
| Entitlements/capabilities | HealthKit, App Groups, Push, Associated Domains, iCloud | здесь проверяется только privacy impact; детальный ownership capabilities раскрывается в `1.5` |
| Privacy manifest | required reason APIs, declared data use, linked SDK privacy practices | manifest отражает фактическое runtime behavior, SDK usage и причины использования privacy-sensitive APIs |
| App Store privacy labels | public product-page disclosure о collection, tracking, linked data | ответы в App Store Connect совпадают с продуктом, analytics и SDK configuration |
| System settings | revocation, limited access changes, notification settings | app корректно reconciles state после возврата из Settings |

Нельзя рассматривать Info.plist строки как деталь copywriting. Неверная строка может означать, что команда не понимает actual data flow. Если feature просит Photos «для выбора аватара», но SDK сканирует library metadata для personalization, это privacy bug, а не copy issue.

#### Denied, restricted, limited и unavailable states
Production app должна иметь first-class UX для каждого non-happy-path permission state.

Матрица решений:

| State | Что означает | UX правило | Engineering правило |
| --- | --- | --- | --- |
| Not determined | пользователь ещё не выбирал | contextual request после объяснения ценности | не делать speculative API access |
| Denied | пользователь отказал | показать альтернативу или путь в Settings без давления | не делать prompt loop; не логировать denial как failure |
| Restricted | system/policy запрет | объяснить недоступность без обвинения пользователя | не показывать Settings как решение, если оно не поможет |
| Limited | доступ частичный | поддержать выбранный subset и возможность изменить selection | не предполагать full library; обрабатывать изменения |
| Unavailable | capability отсутствует | скрыть/заменить feature | feature gating по device/OS/config |
| Revoked after grant | доступ изменён позже | reconcile при foreground/activation | очистить stale assumptions и sensitive derived state |

Limited Photos access — хороший пример senior-level ловушки. App не должна считать `.authorized` и `.limited` одинаковыми. Если пользователь выбрал только часть фото, UI должен уважать этот выбор, не ломать flows и не подталкивать к full access без необходимости.

#### iOS-specific permission nuances
Некоторые privacy-гейты имеют дополнительные состояния, которые нельзя сводить к простому allow/deny.

- **Location**: различай When In Use и Always authorization, precise и reduced accuracy, temporary full accuracy и background location expectations. Запрос Always без сильной user value и background rationale — privacy и App Review риск.
- **Photos**: различай full library access, limited library access и picker-based/session-scoped access. `PHPickerViewController`/PhotosPicker может дать выбор конкретных assets без broad library grant, и это часто предпочтительнее.
- **Notifications**: учитывай provisional authorization, ephemeral authorization, time-sensitive/critical alert policy и lock-screen privacy. Разрешение на notifications — это доступ к attention channel, а не просто transport capability.
- **Tracking / ATT**: App Tracking Transparency — отдельный consent flow для tracking across apps/websites. Его нельзя заменить web-consent, общим onboarding consent или privacy policy ссылкой.
- **Microphone/Camera**: live capture требует visible user intent, clear active state и немедленную остановку capture, когда user-visible задача завершена.
- **Local Network / Bluetooth**: эти permissions могут раскрывать окружение пользователя: домашние устройства, рабочую инфраструктуру, nearby hardware и косвенные behavioral signals.

Picker-based access и permissioned access — разные privacy модели. Если user выбирает конкретный файл, фото или документ через системный picker, app получает scoped доступ к выбранному объекту. Это не равно праву сканировать всю библиотеку, строить hidden index или сохранять unrelated metadata.

#### Data lifecycle, retention и deletion behavior
Permission grant не даёт бессрочное моральное право хранить полученные данные. Для каждого permission-backed data flow нужно определить lifecycle:
- какие raw data попадают в память;
- какие derived data создаются;
- что persist-ится;
- где хранится;
- как долго живёт;
- что удаляется при logout/account deletion;
- что происходит при permission revocation;
- что попадает в backup, cache, logs, analytics и crash reports.

Особенно важны derived artifacts:
- thumbnails из Photos;
- transcribed microphone text;
- geohash/region derived from precise location;
- contact matching results;
- notification engagement history;
- local network device fingerprints.

Если user revoked permission, app не всегда обязана удалить все ранее созданные user-owned artifacts: например, пользователь мог импортировать фото в документ. Но app должна различать **user-owned imported copy** и **permission-derived cache/index**. Первое может жить по product contract; второе обычно должно иметь retention/deletion policy, связанную с permission scope.

#### Logging, analytics и crash-reporting ограничения
Privacy-гейты особенно часто ломаются через diagnostics. Команда обрабатывает permission state, но потом отправляет sensitive context в analytics.

Запрещённые или risky signals:
- precise location, raw coordinates, Wi‑Fi/Bluetooth identifiers;
- contact names, emails, phone numbers;
- photo filenames, metadata, EXIF location;
- microphone transcripts или audio-derived text;
- health-like values;
- pasteboard/document contents;
- user denial reason в форме shame/guilt analytics;
- raw notification payloads с private content;
- tracking state, связанный с identity без policy.

Безопаснее логировать абстрактные состояния: `permission_state=denied`, `scope=limited`, `source=photos_picker`, `error=restricted`, `settings_returned=true`, `selected_count_bucket=1_5`, `location_accuracy=reduced`, `diagnostic_id=<redacted>`. Даже эти поля должны проходить privacy review, потому что некоторые комбинации могут деанонимизировать поведение.

#### Review checklist и incident response
Permission/privacy review должен проверять не только код вызова API, но и весь data flow:
- есть sensitive data inventory;
- permission запрашивается только при понятной user value;
- Info.plist usage description точная и user-facing;
- denied/restricted/limited/unavailable states имеют UX;
- settings deep link не используется как pressure tactic;
- raw и derived data имеют retention/deletion policy;
- permission revocation reconciles local state;
- analytics/logs/crash metadata redacted;
- privacy manifest отражает SDK/API usage;
- App Store privacy labels совпадают с фактическим collection/tracking behavior;
- third-party SDKs не расширяют data collection за пределами заявленного;
- QA покрывает first launch, denial, limited access, revocation, device without capability и managed/restricted device.

Incident response для privacy-gate failure должен быть быстрым, потому что ошибка может затрагивать доверие пользователя и compliance:
1. определить data category и affected capability;
2. выяснить, была ли collection, persistence, transmission или disclosure;
3. оценить affected versions, cohorts и jurisdictions;
4. отключить risky path через kill switch/config, если возможно;
5. удалить/редактировать logs, diagnostics или cached derived data, если policy требует;
6. обновить permission copy, privacy manifest, labels и support messaging;
7. добавить regression tests и release gate.

P0/P1 findings по умолчанию: misleading permission purpose, missing denied path для critical flow, secret/PII logging from permission-backed data, undeclared SDK data collection, tracking без корректного consent, permission prompt на cold launch без product necessity, collection beyond user-visible purpose.

#### Senior / Lead / Staff проверочные Q&A
1. **Какую user value получает пользователь в момент запроса permission?**
   **Ответ:** пользователь должен видеть конкретную пользу прямо сейчас: сделать фото, выбрать файл, включить маршрут, получить уведомления по важному событию. Абстрактное «улучшить опыт» не является достаточным purpose для sensitive permission.

2. **Что app делает, если permission denied, restricted, limited, revoked или unavailable?**
   **Ответ:** denied получает альтернативный flow или ненавязчивый путь в Settings; restricted объясняется как policy/device limitation; limited поддерживается как нормальный режим; revoked reconciles state при activation; unavailable скрывает или заменяет feature.

3. **Какие raw и derived data создаются после grant?**
   **Ответ:** нужно учитывать raw capture/library/contact/location data и derived artifacts: thumbnails, transcripts, geohashes, contact matches, local network fingerprints, notification engagement. Derived data часто не менее sensitive, чем source data.

4. **Какие данные persist-ятся, попадают в backup/cache/logs/analytics/crash reports?**
   **Ответ:** каждый permission-backed data flow должен иметь storage/retention/deletion policy. Raw sensitive data обычно не должна уходить в logs/analytics/crash reports; caches и backups должны соответствовать user ownership и privacy disclosures.

5. **Какие third-party SDKs получают доступ к permission-backed data или derived signals?**
   **Ответ:** SDK access нужно считать частью data flow. Если analytics, ads, crash, support или ML SDK видит permission-backed data, это должно быть justified, minimized, disclosed и отражено в privacy manifest/App Store labels where applicable.

6. **Синхронизированы ли Info.plist strings, privacy manifest, App Store labels и реальный runtime behavior?**
   **Ответ:** да только если usage descriptions описывают actual purpose, privacy manifest отражает SDK/API/data-use behavior, App Store labels отражают collection/tracking, а runtime не делает скрытых дополнительных сборов.

7. **Может ли пользователь выполнить core flow без full access?**
   **Ответ:** если full access не обязателен, app должна поддерживать limited/picker-based/session-scoped access. Например, выбор одного фото не требует права сканировать всю медиатеку.

8. **Не превращает ли UI settings path в давление после отказа?**
   **Ответ:** Settings path допустим, когда пользователь пытается выполнить действие, невозможное без доступа. Он не должен быть guilt wording, modal loop, fake urgency или блокировкой unrelated app functionality.

9. **Что произойдёт после изменения permission в Settings во время suspended app state?**
   **Ответ:** при foreground activation app должна re-read authorization state, очистить stale assumptions, обновить UI, остановить запрещённые tasks и пересчитать derived/cache policy при необходимости.

10. **Какие telemetry докажут, что пользователи не застревают в denied/restricted flows?**
    **Ответ:** нужны redacted metrics: prompt impression, state distribution, denial/limited rates, alternative-flow completion, settings return, feature abandonment, support events и error taxonomy без raw sensitive data.

#### Чеклист production-readiness
Feature с privacy-гейтом не готова к production, пока:
- permission purpose понятен пользователю и соответствует реальному data flow;
- request timing contextual, а не механический cold-launch prompt;
- все authorization states смоделированы как product states;
- limited/reduced access поддержан там, где платформа его предоставляет;
- denied/restricted paths полезны и не манипулятивны;
- raw и derived data имеют storage, retention и deletion policy;
- revocation очищает stale assumptions;
- logs/analytics/crash metadata не содержат sensitive values;
- privacy manifest и App Store labels соответствуют runtime behavior;
- third-party SDK behavior проверен;
- QA matrix включает denial, limited access, revocation, unavailable capability и managed/restricted devices.

### 1.5. Entitlements и системные возможности
#### Назначение раздела
Entitlements — это signed contract между приложением, Apple platform services, provisioning profile и runtime policy. Они описывают, какие privileged capabilities приложение имеет право использовать: App Groups, Keychain Sharing, Push Notifications, Associated Domains, iCloud, HealthKit, Background Modes, Apple Pay, Sign in with Apple и другие системные поверхности. В senior-level iOS engineering entitlement нельзя воспринимать как checkbox в Xcode. Это изменение trust boundary, release process, privacy surface, testing matrix и incident risk.

Простая mental model: **permission спрашивает пользователя**, а **entitlement разрешает app binary использовать capability на уровне платформы и signing identity**. Иногда feature требует оба слоя. Например, Camera требует usage description и runtime permission, а Associated Domains требует entitlement и корректный server-side association file, но не системный prompt. Push требует entitlement/provisioning/APNs environment и отдельно user authorization для notifications.

Не каждая системная возможность является entitlement-backed. Camera, Microphone, Photos и Location обычно управляются через Info.plist usage descriptions, runtime authorization и privacy UX; entitlement может вообще не участвовать. Напротив, App Groups, Associated Domains, Keychain Sharing, iCloud containers и APNs environment зависят от signing/provisioning configuration. Senior review должен сначала классифицировать capability: **permission-only**, **entitlement-backed**, **server-configured**, или **multi-layer**.

#### Определение и ментальная модель
Entitlement включается в signed app binary и проверяется системой при доступе к protected service. Provisioning profile должен разрешать тот же capability для App ID. Если binary, profile, App ID, environment или server-side configuration не согласованы, feature может работать в Debug и ломаться в TestFlight/Release, либо работать на одном target и ломаться в extension.

Staff-level правило: каждый entitlement должен иметь owner и lifecycle. Для него нужны:
- product rationale: зачем capability нужна пользователю;
- data flow: какие данные проходят через capability;
- privacy/security review: какие новые trust boundaries открываются;
- release verification: как проверить Debug, TestFlight и App Store builds;
- rollback plan: как отключить feature, если capability misconfigured или создаёт incident;
- documentation: где описаны required profile, identifiers, domains, containers и server dependencies.

Entitlement не должен появляться «на будущее». Лишний capability увеличивает attack surface, App Review surface, privacy disclosure burden и operational complexity.

#### Синтаксис и API surface
Технически entitlements обычно живут в `.entitlements` plist и управляются через Xcode Signing & Capabilities, Apple Developer portal, App ID capabilities и provisioning profiles. Но фактический runtime contract шире, чем один файл.

Практическая цепочка:
1. **App ID / Developer portal:** capability должен быть включён для конкретного bundle identifier.
2. **Provisioning profile:** profile должен содержать entitlement, разрешённый App ID.
3. **Target `.entitlements`:** app/extension target должен запрашивать нужное значение.
4. **Code signing:** signed binary получает entitlement в embedded signature.
5. **Runtime/API usage:** framework проверяет entitlement и additional configuration.
6. **Server-side dependency:** Associated Domains, APNs, iCloud, Sign in with Apple и Apple Pay требуют внешнюю configuration consistency.

Распространённые примеры:

| Capability | Entitlement surface | Дополнительная зависимость | Типичная ошибка |
| --- | --- | --- | --- |
| App Groups | group identifier | shared container schema/locking | extension читает больше данных, чем нужно |
| Keychain Sharing | access group | Keychain item accessibility/account policy | token доступен не тому target или переживает logout |
| Push Notifications | APS environment | APNs auth, notification permission, backend routing | dev/prod environment mismatch |
| Associated Domains | domains/services | `apple-app-site-association`, HTTPS, paths | Universal Links работают локально, но не после release |
| iCloud / CloudKit | container identifiers | container setup, schema, account state | production container не совпадает с debug assumptions |
| Background Modes | mode declarations | lifecycle/expiration handling | app ведёт себя как daemon и теряет data under expiration |
| HealthKit / Apple Pay | capability + merchant/container config | review policy, user authorization, server contracts | capability есть, но privacy/payment flow не готов |

#### Compiler, signing и runtime-механика
Compiler обычно не доказывает корректность entitlement configuration. Код может компилироваться, даже если capability отсутствует в profile или production environment настроен неверно. Ошибка проявится на signing, install, launch, API call, server callback или App Review stage.

Runtime failure patterns:
- API возвращает authorization/availability error;
- container URL для App Group возвращает nil;
- Keychain item не виден между targets из-за access group mismatch;
- Universal Link открывается в Safari вместо app;
- push token выдаётся для wrong APNs environment;
- background mode запускается, но work expires без completion;
- iCloud/CloudKit работает в development container, но не в production;
- extension и app подписаны разными profiles и не разделяют expected capability.

Senior-level verification должен проверять не только code path, но и signed artifact. Для release-critical capabilities полезны проверки:
- inspect entitlements у built app/extension;
- сверить bundle identifiers, App Groups, Keychain access groups и Associated Domains;
- проверить provisioning profile и configuration environment;
- выполнить TestFlight-like build verification, а не только Debug run;
- иметь diagnostic screen/logs, которые показывают redacted capability state без secrets, private URLs, payload bodies, auth headers и private user content.

#### Trust boundaries и ownership
Entitlement часто создаёт новый trust boundary между app и системой, app и extension, app и backend, app и website, app и Apple service. Ownership должен быть явным.

Примеры ownership:
- **App Groups:** data owner отвечает за schema, migration, locking, cleanup, privacy scope и account separation.
- **Associated Domains:** mobile и web/platform teams совместно владеют domain association file, path policy, fallback behavior и incident response.
- **Push:** backend, mobile и product владеют token lifecycle, user authorization, payload privacy, topic routing и opt-out behavior.
- **Keychain Sharing:** security owner определяет access groups, accessibility class, logout/revocation и cross-target visibility.
- **Background Modes:** feature owner доказывает user value, bounded work, expiration handling и observability.

Staff-level anti-pattern — включить capability в app target, потому что одной feature «так проще», без owner для cleanup, migration, privacy manifest, support runbook и release verification.

#### Edge cases и неочевидное поведение
Entitlement-related bugs часто появляются не в happy path, а на границах environment, target и distribution.

Неочевидные cases:
- Debug profile содержит capability, а Release/TestFlight profile — нет.
- App target имеет App Group, а widget/share extension — другой group или другой Team ID prefix.
- Keychain access group изменился после bundle/team migration, и старые tokens стали невидимы.
- Associated Domains cached системой; исправление server file не всегда мгновенно видно на device.
- APNs development token отправляется в production endpoint или наоборот.
- Background mode разрешён, но system policy всё равно ограничивает timing и duration.
- iCloud account disabled/restricted; entitlement есть, но service unavailable.
- Managed device/MDM запрещает capability независимо от app configuration.
- Capability есть в app, но отсутствует в extension, которая фактически выполняет работу.
- Удаление entitlement из новой версии оставляет local data, Keychain items или server registrations от старого behavior.

Правило: entitlement migration должна иметь backward compatibility plan. Если capability добавляется, меняется или удаляется, нужно описать effect на existing installs, stored data, tokens, server state, support docs и rollback.

#### Security, privacy и compliance последствия
Entitlements расширяют не только технические возможности, но и обязанности.

Security/privacy checks:
- capability не должен давать broader data access, чем feature реально использует;
- shared containers не должны становиться dump ground для private state;
- push payloads не должны содержать private content, видимый на lock screen или в logs;
- Associated Domains не должны открывать unsafe deep link routing;
- Keychain Sharing не должен раскрывать credentials лишним targets;
- Background Modes не должны использоваться для hidden tracking, polling или user-hostile behavior;
- iCloud/CloudKit data flow должен иметь retention, deletion и account-state behavior;
- third-party SDK, требующий capability, должен пройти privacy/security review.

Compliance implication: включённая capability может требовать Info.plist usage description, App Privacy labels, App Review notes, export compliance/payment review или policy-specific UI. Privacy manifest обновляется там, где это реально следует из SDK/API usage, required reason APIs или declared data use. Если capability не отражена в docs/release checklist, команда рискует получить App Review rejection или privacy incident.

#### Production-ловушки и Q&A с ответами
1. **Почему entitlement нельзя добавлять “на всякий случай”?**
   **Ответ:** он расширяет attack surface, signing/release complexity, App Review scope и privacy obligations. Неиспользуемый capability создаёт risk без user value и должен удаляться или быть explicitly justified.

2. **Почему feature может работать в Debug, но ломаться в TestFlight?**
   **Ответ:** Debug и Release/TestFlight могут использовать разные provisioning profiles, APNs environments, iCloud containers, associated domains и signing identities. Нужно проверять signed artifact и production-like configuration.

3. **Как отличить permission bug от entitlement bug?**
   **Ответ:** permission bug связан с user/system authorization state; entitlement bug — с тем, что signed binary/profile/App ID не имеет права использовать capability. Feature может иметь entitlement, но получить denied permission; или иметь permission UI, но runtime API fail из-за missing entitlement.

4. **Что доказывает корректность App Group setup?**
   **Ответ:** app и extension подписаны profiles с одним group id, видят один shared container, используют versioned schema, atomic/ coordinated writes, account-scoped data и cleanup при logout/account deletion.

5. **Что должно быть в release checklist для Associated Domains?**
   **Ответ:** entitlement values, server `apple-app-site-association`, HTTPS validity, path matching, fallback behavior, universal link tests на installed TestFlight build, web/mobile owner и incident rollback path.

6. **Как безопасно удалить capability из существующего app?**
   **Ответ:** сначала оценить persisted data, server registrations, tokens, user flows и extensions, затем выполнить migration/cleanup, обновить disclosures, отключить backend paths и проверить rollback. Простое удаление entitlement может оставить orphaned data или сломать recovery.

#### Review checklist с ожидаемыми ответами
Feature с entitlement/system capability не готова к production, пока:
- **Rationale:** documented user value и owner capability существуют; capability не добавлена speculative.
- **Signing consistency:** App ID, provisioning profile, `.entitlements`, app target и extension targets согласованы.
- **Environment consistency:** Debug/TestFlight/App Store paths проверены для APNs, iCloud, Associated Domains и backend dependencies.
- **Data flow:** sensitive data inventory и privacy/security review покрывают capability.
- **Runtime states:** unavailable/restricted/misconfigured states имеют diagnostics и user-safe behavior.
- **Shared state:** App Groups/Keychain Sharing имеют минимальный scope, migration, cleanup и account separation.
- **Release docs:** privacy manifest, App Store labels, review notes и support docs обновлены там, где применимо.
- **Incident response:** есть rollback/kill switch/migration plan для misconfiguration или privacy issue.

#### Практическое упражнение с эталонным разбором
**Задание:** команда хочет добавить App Groups, чтобы widget показывал последние private user documents.

**Эталонный разбор:** безопасный design не кладёт всю database в shared container. Main app создаёт минимальный widget snapshot: document id, redacted title или user-approved display title, timestamp, account scope, schema version и expiration. Запись atomic, с file protection, backup exclusion для regenerable snapshot, bounded retention/expiration, cleanup при logout/account switch и fallback UI, если snapshot недоступен. Widget перед render валидирует schema version, account scope и expiration. Widget не получает access к tokens, full document contents, pending mutations или unrelated cache. Review проверяет App Group id в app и widget targets, signed entitlements, privacy/logging policy, backup behavior, retention policy и migration path.

### 1.6. Цикл платформенных релизов и эволюция через WWDC
#### Назначение раздела
Цикл платформенных релизов Apple — это не ежегодное событие для просмотра keynote, а production input для iOS engineering strategy. Каждый WWDC открывает период, когда меняются SDK, Xcode, Swift, SwiftUI/UIKit APIs, privacy requirements, App Store policy, device behavior, runtime diagnostics, design language и пользовательские ожидания. Senior/Lead/Staff engineer должен превращать этот поток изменений в управляемый engineering process: triage, adoption plan, compatibility strategy, release gates, telemetry и rollback.

Правильная mental model: WWDC создаёт **platform change backlog**, но не каждое изменение сразу становится product work. Команда должна отделять:
- mandatory changes: policy, privacy, signing, App Store, deprecations, crash/build blockers;
- strategic opportunities: APIs, design capabilities, performance tools, Swift language improvements;
- optional experiments: визуальные новинки, non-critical convenience APIs, developer productivity improvements;
- watchlist items: beta bugs, ambiguous documentation, SDK behavior, который может стабилизироваться позже.

#### Operational goal и ownership
Цель release-cycle process — не «успеть переписать app под новый iOS», а сохранить production reliability во время эволюции вместе с платформой. Ownership должен быть распределён явно:

| Роль | Ответственность | Ожидаемый результат |
| --- | --- | --- |
| Platform/Staff owner | triage WWDC changes, risk matrix, adoption strategy | documented platform roadmap и decision log |
| Release owner | signing, build numbers, TestFlight/App Store gates | release checklist, archive validation, rollback plan |
| Feature owners | impact analysis для своих screens/flows | compatibility notes, migration tasks, test scope |
| QA owner | device/iOS matrix, smoke/regression strategy | beta/GM/release candidate test plan |
| Security/privacy owner | privacy manifests, permissions, SDK policy changes | updated disclosures и blocked-risk list |
| Support/product owner | user-facing changes, support scripts, rollout comms | release notes, known issues, support FAQ |

Staff-level правило: adoption без owner превращается в набор случайных PR. Каждый platform change должен иметь один из статусов: **adopt now**, **prepare**, **observe**, **defer**, **reject with reason**.

#### Release calendar как engineering system
Платформенный год удобно мыслить как несколько phases:

1. **WWDC / early beta:** собрать изменения, выделить risks/opportunities, не строить long-term architecture на unstable beta behavior.
2. **Beta stabilization:** проверять build compatibility, critical flows, privacy/signing changes, deprecations и performance regressions.
3. **GM / Release Candidate:** закрыть release blockers, обновить test matrix, проверить archive, TestFlight, dSYM, crash reporting и support notes.
4. **Public OS rollout:** мониторить metrics by OS version, feature flags, crash/hang rates, permission behavior, App Review feedback.
5. **Post-release learning:** обновить standards, удалить устаревшие workarounds, зафиксировать ADRs и tech debt.

Это не waterfall. Некоторые urgent policy/security изменения могут идти сразу в текущий release, а визуальные/API migrations — через staged adoption.

#### Beta toolchain vs production lane
Главное release-engineering правило сезона WWDC: **beta exploration lane и production release lane должны быть изолированы**. Ранний переход всей команды, CI или release branch на beta Xcode/SDK создаёт риск, который сложно откатить.

Практическая модель:
- **Production lane** остаётся на stable Xcode/toolchain, пока команда выпускает текущие App Store/TestFlight builds.
- **Exploration lane** использует beta Xcode/SDK для compatibility checks, spikes, warnings, early adoption experiments и bug filing.
- **CI isolation** не позволяет beta toolchain случайно стать default для release branches.
- **Cutover criteria** фиксируются заранее: GM/RC toolchain, green archive, critical smoke, signing/provisioning validation, dependency compatibility и no open P0/P1 regressions.
- **Freeze window** перед public OS release защищает app от late unreviewed migrations.

Исключения возможны только для mandatory policy/build blockers, и даже тогда нужен explicit release owner, rollback plan и separate validation.

#### Build, signing и environment constraints
Новый Xcode/SDK может менять не только API availability, но и build behavior, Swift diagnostics, signing requirements, linker warnings, privacy manifests, simulator/device differences и App Store validation.

Release-cycle gate проверяет эти surfaces именно как release-time verification. Механика sandbox, privacy и entitlements раскрыта в `1.3–1.5`; здесь важно доказать, что они согласованы в archive/TestFlight/App Store lane. Gate должен проверять:
- clean archive на supported Xcode version;
- bundle IDs, entitlements, App Groups и provisioning profiles;
- version/build number policy;
- Debug/TestFlight/App Store environment separation;
- dSYM generation/upload и crash symbolication;
- privacy manifests, Info.plist usage descriptions и App Privacy labels;
- dependency compatibility с новым SDK и server contract compatibility для OS-season changes;
- CI images/toolchains consistency;
- simulator, physical device, extensions/widgets/App Clips/watch targets smoke для release-critical flows там, где такие surfaces есть;
- backward compatibility для minimum deployment target.

Важная ловушка: build success на новом SDK не доказывает runtime readiness. App может компилироваться, но получить changed lifecycle behavior, altered permission prompt, SwiftUI layout regression, keyboard/safe-area difference, new privacy validation или background policy change.

#### API adoption и compatibility strategy
Adoption strategy должна отвечать не только на «можем ли использовать новый API», но и на «какую стоимость создаёт conditional behavior».

Матрица решений:

| Решение | Когда подходит | Риск | Правило |
| --- | --- | --- | --- |
| Adopt immediately | mandatory policy/security/build blocker или явная product value | beta instability, regressions | feature flag, availability checks, rollback |
| Wrap behind availability | новый API полезен, но deployment target ниже | divergent behavior | единый abstraction только если реально снижает duplication |
| Defer | API не критичен или docs/behavior unstable | missed opportunity | revisit date и owner |
| Reject | API усложняет architecture или нарушает product goals | future regret | documented rationale |
| Prepare only | нужно изменить architecture перед adoption | planning debt | RFC/ADR и migration milestones |

Compatibility code должен быть explicit. `if #available` не должен расползаться случайно по UI. Staff-level approach: определить feature boundary, fallback behavior, test matrix и removal plan для старых branches после повышения deployment target.

#### Multi-year compatibility и deprecation lifecycle
Платформенная эволюция длится несколько лет, поэтому временный compatibility code должен иметь срок жизни. Иначе codebase накапливает `if #available`, shims, legacy visual fallbacks, duplicated behavior и test matrix cost.

Staff-level policy должна включать:
- критерии повышения minimum deployment target: user share, business constraints, device support, QA cost, security/privacy requirements, App Store policy и dependency support;
- owner для каждого temporary workaround или compatibility shim;
- removal date или revisit trigger;
- tests, которые доказывают fallback behavior до удаления;
- migration plan для persisted data и user-visible behavior;
- ADR/RFC, если deployment target change влияет на product reach или team roadmap.

Правило: каждый workaround после WWDC должен быть либо promoted в stable architecture, либо удалён, либо явно оставлен с cost/owner. Вечный temporary compatibility layer — это architecture debt.

#### Telemetry, logging и alerting signals
Платформенные изменения должны иметь production feedback loop. Без telemetry команда не знает, улучшила ли adoption продукт или создала тихую regression.

Минимальные signals:
- crash-free sessions by OS version/device class;
- hang rate, launch time, memory terminations, energy regressions;
- permission authorization distributions after OS update;
- SwiftUI layout/interaction support tickets;
- network/background task failures by OS version;
- App Store/TestFlight feedback themes;
- feature flag exposure и rollback events;
- dSYM upload/symbolication health;
- adoption-specific events, redacted and bounded.

Alerting должен быть связан с action. Если metric ухудшился, команда должна знать owner, rollback path, kill switch или next diagnostic step. Dashboard без ownership — это декоративная observability без operational value.

#### Rollout, rollback и incident workflow
Platform adoption должен идти staged, если change может затронуть large user base. Rollout strategy зависит от риска:
- internal dogfood для beta OS и new SDK builds;
- TestFlight cohorts для compatibility и support feedback;
- feature flags для risky runtime behavior;
- phased release для App Store rollout там, где подходит;
- kill switch для server-driven features;
- rollback plan для app release, backend config и feature flag defaults.

Rollback в iOS имеет ограничения: установленный app binary нельзя мгновенно отозвать у всех пользователей. Поэтому безопасный design делает risky behavior отключаемым удалённо, server contracts backward-compatible, а diagnostics достаточными для triage. Data migrations должны быть reversible там, где это реально; если migration one-way, она должна быть versioned, gated, recoverable и не должна зависеть от предположения, что emergency rollback вернёт старый local state.

Incident workflow:
1. classify: build/signing, runtime crash, data loss, privacy, App Review, performance, support regression;
2. identify affected OS/device/app versions;
3. disable risky path if possible;
4. prepare hotfix/TestFlight validation;
5. update support messaging;
6. preserve evidence: logs, dSYMs, metrics, timeline;
7. write postmortem and update release gate.

#### Compliance и support handoff checklist
Платформенный release часто меняет не только code, но и compliance/support obligations.

Release handoff должен включать:
- обновлённые privacy manifests и App Privacy labels там, где применимо;
- изменения permission copy и screenshots там, где релевантно;
- export compliance/payment capability notes, если релевантно;
- App Review notes for new capabilities, background modes, account deletion, login, health/payment/location behavior;
- support FAQ for changed permissions, OS-specific behavior, known issues;
- rollback/kill switch instructions;
- diagnostics instructions: где найти build number, OS version, device class, correlation id;
- known limitations и expected degraded behavior.

Support handoff не должен раскрывать internal secrets или debug-only steps. Его цель — дать support/product/QA общий язык для user-facing incidents.

#### Production-ловушки и Q&A с ответами
1. **Почему WWDC adoption нельзя начинать с массового refactor?**
   **Ответ:** ранние beta APIs и behavior могут измениться, а массовый refactor смешивает learning, migration и product changes. Надёжнее начать с triage, spikes, compatibility checks, risk matrix и небольших reversible adoption slices.

2. **Почему `if #available` сам по себе не является compatibility strategy?**
   **Ответ:** availability check только предотвращает вызов API на старой OS. Он не определяет fallback UX, test coverage, ownership, removal plan и consistency между OS versions.

3. **Как понять, что новый SDK создал production regression?**
   **Ответ:** сравниваются metrics по app version, OS version, device class и rollout cohort: crash-free sessions, hangs, launch, memory, permission flows, support tickets и feature-specific events. Локальная проверка build success недостаточна.

4. **Почему rollback для iOS сложнее, чем для backend?**
   **Ответ:** app binary уже установлен на устройствах, App Store rollout не мгновенный, review/hotfix занимает время, а migrated local data может быть несовместима со старым behavior. Поэтому нужны feature flags, backward-compatible migrations и server-side safety.

5. **Что делает WWDC adoption staff-level задачей?**
   **Ответ:** она затрагивает не один API, а roadmap, team ownership, release gates, compatibility, privacy, QA, support, incident response и long-term platform strategy.

#### Review checklist с ожидаемыми ответами
Platform release/adoption work не готово, пока:
- **Triage:** каждое platform change classified как adopt now / prepare / observe / defer / reject.
- **Ownership:** у risky changes есть owner, review path и decision log.
- **Build/signing:** clean archive, profiles, entitlements, dSYM и App Store validation проверены.
- **Compatibility:** fallback behavior и availability strategy описаны для supported OS versions.
- **Telemetry:** metrics/alerts привязаны к owner и action.
- **Rollout:** TestFlight/phased release/feature flag strategy выбрана по risk level.
- **Rollback:** risky behavior можно отключить или безопасно заменить; migrations forward-compatible.
- **Compliance:** privacy manifests, App Privacy labels, usage descriptions и review notes обновлены там, где применимо; это release-time verification surface для механик из `1.3–1.5`.
- **Support:** support FAQ, known issues и diagnostic instructions готовы.
- **Learning:** после release обновлены docs, ADRs, tech debt и removal plan для temporary workarounds.

#### Практический runbook с эталонным разбором
**Сценарий:** после перехода на новый Xcode и SDK приложение стало чаще падать на iOS beta/новом major release.

**Эталонный разбор:** release owner сначала сегментирует crash-free sessions по OS version, device class, app build и rollout cohort. Затем проверяет dSYM/symbolication health, known SDK release notes, recent API adoption и feature flags. Если crash связан с new API path, risky behavior отключается remote flag, готовится hotfix branch, QA прогоняет critical smoke на affected OS/device, support получает known issue note. После hotfix команда пишет postmortem: какой gate пропустил regression, какие beta/RC checks добавить, какой workaround временный и когда его удалить.

### 1.7. Стратегия deployment target
#### Назначение раздела
Deployment target — это не только значение в Xcode project settings. Это продуктово-инженерное решение о том, какие пользователи, устройства, OS capabilities, QA matrix, support obligations и architecture tradeoffs команда готова поддерживать. Слишком низкий deployment target увеличивает стоимость compatibility code, тестирования и workaround-ов. Слишком высокий target может отрезать пользователей, enterprise cohorts, старые devices или markets, где обновление OS происходит медленнее.

Staff-level mental model: deployment target — это **contract of support**. Он определяет minimum runtime guarantees, доступные APIs, required fallback behavior, CI/device matrix, release policy и срок жизни compatibility layers. Решение нельзя принимать только из желания использовать новый API или уменьшить количество `if #available`.

#### Decision context и stakeholders
Решение о deployment target должно учитывать несколько владельцев, потому что стоимость и benefit распределены неравномерно.

| Stakeholder | Что защищает | Какие данные нужны |
| --- | --- | --- |
| Product | reach, market coverage, user value | active users by OS/device, revenue/usage segments, feature demand |
| Engineering | maintainability, API adoption, build/test cost | compatibility code inventory, crash/hang metrics, dependency constraints |
| QA | test matrix realism | supported OS/device matrix, critical flow coverage, automation cost |
| Support | user communication и known issues | support ticket volume by OS/device, upgrade guidance |
| Security/privacy | minimum OS security baseline, privacy APIs | OS-level protections, policy requirements, SDK privacy behavior |
| Release owner | App Store/TestFlight readiness | archive/build constraints, dependency minimums, rollout risk |
| Leadership/Staff | long-term platform strategy | cost model, migration roadmap, opportunity cost |

Правило: deployment target нельзя менять без user impact analysis и engineering cost analysis. Для consumer app и enterprise app критерии могут различаться: consumer продукт смотрит на active usage/revenue cohorts, enterprise продукт — на managed device fleets, MDM policy, contractual support и upgrade windows.

#### Data inputs и decision model
Минимальный набор evidence:
- active users by iOS version and device class;
- revenue/critical workflow usage by OS version;
- crash/hang/performance metrics by OS version;
- support tickets and known issues by OS version;
- QA cost for old OS/device combinations;
- compatibility code hotspots and workaround count;
- dependency minimum requirements;
- Apple policy/App Store/toolchain constraints;
- security/privacy benefit of newer OS baseline;
- feature roadmap requiring newer APIs.

Decision не должен опираться на global OS adoption numbers alone. Команде нужны собственные analytics, потому что user base конкретного продукта может отличаться от публичной статистики. Если таких данных нет, это риск, а не разрешение принимать решение на интуиции.

#### Technical tradeoffs и organizational impact
Deployment target change должен быть синхронизирован не только в app target. Release owner проверяет все связанные targets и artifacts: app, extensions, widgets, App Clips, watch targets, test hosts, Swift packages, third-party SDK minimums, CI schemes, archive settings, TestFlight installability и App Store validation. Несогласованный target между app и extension может пройти локальный build, но сломать archive, installability или runtime handoff.

Повышение deployment target обычно даёт:
- меньше availability branches;
- меньше fallback UI и workaround-ов;
- доступ к новым APIs/framework behavior;
- меньшую QA matrix;
- возможность удалить legacy dependencies;
- упрощение onboarding новых engineers;
- иногда лучшую security/privacy baseline.

Но оно также создаёт cost:
- потеря части пользователей или enterprise customers;
- support burden для users, которые не могут обновиться;
- migration communication;
- App Store review/support questions;
- необходимость coordination с backend/product/legal/support;
- риск скрытых regressions на devices, которые остаются supported.

Staff-level decision — это не «новый API стоит потери N% пользователей». Это tradeoff между **user reach**, **engineering leverage**, **risk reduction**, **product roadmap** и **organizational capacity**. Иногда правильное решение — поднять target резко. Иногда — оставить старый target, но выделить budget на compatibility debt и назначить removal milestone.

#### Compatibility code lifecycle
Каждый старый OS branch должен иметь owner и срок жизни. Если `if #available` остаётся без удаления, codebase постепенно превращается в набор параллельных реализаций.

Правила:
- каждый fallback имеет owner, reason и removal trigger;
- fallback behavior тестируется так же, как основной path;
- workaround должен ссылаться на OS bug/API limitation или product requirement;
- при повышении target нужно удалять dead branches, а не только менять setting;
- compatibility removal должен включать cleanup tests, docs и screenshots/previews, если UI меняется;
- persisted data migrations должны учитывать пользователей, которые обновятся app после долгого времени на старой OS.

Deployment target strategy тесно связана с `1.8` и `1.9`: обратная совместимость и скрытая стоимость старых iOS versions раскрываются глубже там. В этой секции focus — decision governance и release impact.

#### Governance artifact или process to produce
Решение о deployment target должно оставлять durable artifact: ADR, RFC или release decision note.

Минимальная структура ADR:
- current target и proposed target;
- decision date и intended release window;
- affected users/devices/markets/cohorts;
- product impact и support messaging;
- engineering benefits;
- removed compatibility code и remaining compatibility debt;
- QA matrix до/после;
- dependencies/toolchain constraints;
- risks, mitigations и rollback limits;
- approval owners: product, engineering, QA, support, security/privacy;
- follow-up tasks: delete branches, update docs, update CI matrix, update release notes.

Rollback reality важна: если app release поднял deployment target, пользователи на старой OS обычно остаются на последней совместимой версии. Это не togglable feature flag. Команда должна заранее решить, будет ли эта версия получать critical-fix support, security hotfixes или будет frozen. Поэтому decision должен быть принят до release branch cut и сопровождаться communication/support plan.

#### Escalation, alignment и communication risks
Deployment target change требует escalation, если:
- affected cohort materially large или revenue-critical;
- enterprise/regulated customers зависят от старой OS;
- feature roadmap требует нового OS baseline, но product не готов терять reach;
- dependency/vendor прекращает поддержку старого OS;
- security/privacy requirement требует newer baseline;
- QA не может честно покрывать старую matrix;
- release уже близко, а migration/support messaging не готов.

Communication risk: команда может продать решение как «техническую чистку», хотя для пользователя это loss of updates. Правильная коммуникация говорит честно: какие devices/OS остаются supported, какая последняя app version доступна старым users, какие security/support implications существуют и где получить help.

#### Review Q&A с ответами и calibration rubric
Threshold thinking помогает перевести спор из вкусового режима в decision model. Пороговые значения не универсальны, но ADR должен явно назвать допустимые границы: доля affected active users, revenue/strategic cohort impact, support ticket volume, crash/hang delta on old OS, engineering hours saved, QA matrix reduction и roadmap value unlocked. Если threshold не назван, команда не сможет честно повторить или оспорить решение через квартал.

1. **Почему deployment target нельзя повышать только ради нового API?**
   **Ответ:** новый API даёт engineering benefit, но deployment target меняет support contract. Нужно сравнить user reach loss, QA/support impact, product roadmap, security benefits и long-term maintenance cost.

2. **Какие данные доказывают, что target можно повысить?**
   **Ответ:** active usage/revenue by OS/device, critical flow usage, support tickets, crash/performance data, QA cost, compatibility debt inventory, dependency constraints и product approval. Публичной OS adoption статистики недостаточно.

3. **Что значит “старый fallback можно удалить”?**
   **Ответ:** minimum target больше не требует branch, tests подтверждают новый path, no supported users depend on old behavior, docs/previews/screenshots обновлены, migration risks закрыты и owner подтвердил removal.

4. **Почему deployment target decision нужно делать до release branch cut?**
   **Ответ:** это влияет на App Store availability, QA matrix, CI, support notes, release notes и user communication. Позднее решение создаёт риск непроверенной matrix и некорректного support messaging.

5. **Как калибровать спор между product reach и engineering leverage?**
   **Ответ:** использовать rubric: affected active users, revenue/strategic cohorts, engineering hours saved, risk removed, feature roadmap unlocked, QA cost reduction, security/privacy benefit and support cost. Decision должен быть explicit, а не эмоциональный.

Calibration rubric:
- **Raise now:** affected cohort мал или low-value, compatibility cost high, new baseline unlocks strategic/security value, support plan ready.
- **Prepare:** cohort ещё значим, но cost растёт; назначены deprecation communication, data collection и removal milestone.
- **Defer:** affected cohort large/strategic или support/QA/product not ready; compatibility debt получает explicit budget.
- **Reject:** proposal driven only by convenience, без product/security/release evidence.

#### Чеклист готовности решения
Deployment target change не готов, пока:
- **Evidence:** есть product-specific OS/device/user impact data.
- **ADR/RFC:** decision, rationale, alternatives и approval owners зафиксированы.
- **QA matrix:** CI/manual/smoke matrix покрывает oldest supported OS, newest OS, oldest supported device class, low-memory/low-storage cohorts where relevant, installability, archive, TestFlight и App Store validation.
- **Code cleanup:** dead availability branches and workarounds имеют removal tasks.
- **Dependencies:** package/vendor/toolchain minimums проверены.
- **Persistence:** migrations и local data behavior безопасны для users, обновляющихся с очень старых app versions.
- **Support:** release notes, support FAQ и user messaging готовы.
- **Release:** App Store availability, TestFlight, build settings и deployment target в app/extensions/widgets/App Clips/test hosts/packages согласованы.
- **Monitoring:** rollout metrics покажут unexpected drop-offs, support spikes или crash regressions.

#### Case study с эталонным разбором
**Сценарий:** команда хочет поднять deployment target с iOS N до iOS N+1, чтобы удалить legacy UI fallback и использовать новый navigation API.

**Эталонный разбор:** Staff engineer не начинает с PR, меняющего project setting. Сначала собирается OS/device usage по active users, revenue cohorts и critical flows. Затем составляется inventory fallback code: какие screens используют legacy path, какие tests его покрывают, какие bugs он создаёт. Product и support оценивают affected users и messaging. QA обновляет matrix. Если decision принят, создаётся ADR, release branch получает target change отдельным reviewable PR без смешивания с широким feature refactor, compatibility branches удаляются отдельными PR, CI/build settings синхронизируются, release notes описывают minimum OS change и последнюю совместимую app version, а rollout monitors отслеживают adoption, crash rate и support tickets.

### 1.8. Обратная совместимость и обработка deprecation
#### Назначение раздела
Обратная совместимость — это способность приложения сохранять корректное поведение на поддерживаемых OS versions, devices, data states, server contracts и ранее выпущенных app versions. Deprecation — это сигнал от платформы или dependency owner, что текущий API/behavior больше не является стратегическим path и требует migration planning. Senior engineer не воспринимает deprecation warning как косметический шум, но и не превращает каждое предупреждение в emergency rewrite.

Mental model: compatibility — это **managed divergence**, то есть управляемое расхождение. Пока приложение поддерживает несколько OS versions или app versions, часть поведения неизбежно расходится. Задача команды — сделать это расхождение явным, bounded, tested и removable.

#### Scope и prerequisites
Перед работой с backward compatibility нужно определить:
- supported deployment target и фактическую OS/device matrix;
- API availability boundaries;
- persisted data versions и migration paths;
- server API versions и backward-compatible contracts;
- dependency minimum versions;
- feature flags / remote config defaults;
- App Store/TestFlight release lanes;
- ownership для fallback paths и removal milestones.

Compatibility scope шире, чем `if #available`. Он включает UI behavior, lifecycle assumptions, permission models, file formats, local database schema, push payloads, deep links, widgets/extensions, analytics events, server responses и support scripts.

#### Core theory и mental model
Есть несколько видов совместимости:

| Вид совместимости | Что защищает | Типичный риск |
| --- | --- | --- |
| OS compatibility | app работает на supported iOS versions | API недоступен, behavior отличается, permission state другой |
| Source compatibility | код компилируется с выбранным SDK/toolchain | deprecation warnings, Swift language changes, stricter diagnostics |
| Binary/runtime compatibility | signed app запускается и вызывает frameworks корректно | weak linking, missing symbols, runtime availability crash |
| Data compatibility | app читает старые persisted formats | destructive migration, orphaned data, rollback breakage |
| Server compatibility | app и backend понимают contracts разных versions | старый app получает response, который не умеет обработать |
| UX compatibility | user-visible behavior остаётся понятным | разные OS показывают разные flows без explanation |
| Observability compatibility | metrics/logs остаются сопоставимыми | dashboards ломаются после event/schema rename |

Deprecation — не всегда запрет. Иногда API deprecated, но поддерживается долго. Иногда не-deprecated behavior меняется фактически. Поэтому правильная реакция — triage:
- **blocker:** API запрещён policy/App Review/security или ломает build/runtime;
- **must plan:** API deprecated и replacement явно стратегический;
- **observe:** warning есть, но migration risk выше immediate benefit;
- **defer with owner:** миграция нужна, но не в текущем release;
- **reject:** replacement не подходит продукту, documented rationale принят.

#### Подкапотные детали
Availability в Swift/iOS работает на нескольких уровнях:
- compile-time SDK знает символы, доступные в текущем SDK;
- deployment target определяет minimum OS, на которой binary должен запускаться;
- `@available` и `if #available` защищают calls к API, доступным только на новых OS;
- weak linking позволяет binary ссылаться на framework symbols, отсутствующие на старой OS, если runtime path защищён;
- compiler не доказывает, что fallback behavior product-correct;
- deprecation warning сообщает о recommended migration, но не описывает product impact.

Типичная ошибка: добавить `if #available` вокруг нового API и считать задачу закрытой. На самом деле нужно определить fallback UX, data behavior, tests on old OS, telemetry segmentation, removal plan и owner. Runtime crash может возникнуть не только из-за прямого вызова недоступного API, но и через stored closures, type initialization, static initializers, storyboard/nib references, SwiftUI modifiers, property wrappers или dependency code, который не защищён availability boundary.

Data compatibility подчиняется отдельной логике и требует различать три направления. **Upgrade compatibility** означает, что новая версия безопасно читает старый persisted state. **Downgrade/rollback compatibility** означает, что старый binary способен пережить state, уже изменённый новой версией. **One-way migration** означает, что downgrade не поддерживается; тогда migration должна быть явно gated, versioned, observable и иметь recovery plan. Если release process допускает emergency rollback binary, это нужно проверить до rollout, а не после data migration у пользователей.

#### Production-правила и ловушки
Production rules:
- не распыляй `if #available` по UI без архитектурной границы;
- каждый fallback path должен иметь owner, tests и removal trigger;
- deprecation warning triage должен иметь severity, target release и rationale;
- migration PR не должен смешивать API replacement с unrelated refactor;
- ветка для старой OS должна иметь реальную проверку, пока OS supported;
- server contracts должны быть additive, tolerate old app versions и иметь explicit support/sunset policy;
- analytics schema changes должны сохранять comparability или иметь migration plan;
- release notes/support docs должны отражать changed compatibility behavior;
- dependency upgrade должен проверять minimum OS и transitive SDK requirements.

Ловушки:
- **availability illusion:** код компилируется, но fallback UX не определён;
- **testing illusion:** tests run only on newest simulator;
- **deprecation panic:** команда мигрирует deprecated API без product reason и ломает stable behavior;
- **permanent workaround:** временный branch переживает несколько лет без owner;
- **silent server break:** backend начинает отдавать поля/enum cases, старый app падает или показывает invalid state;
- **rollback trap:** новая local migration делает старый app binary несовместимым;
- **analytics split-brain:** old/new event names делают release comparison невозможным.

#### Compatibility directions
Перед migration нужно назвать направление совместимости:
- **new app ↔ old data:** новая версия читает старые базы, файлы, caches, preferences и pending operations;
- **old app ↔ new data:** старый binary безопасно переживает данные, записанные новой версией, либо downgrade явно запрещён;
- **old client ↔ new server:** уже установленные old app versions получают responses, которые умеют обработать;
- **new client ↔ old server:** staged backend rollout не ломает новый app, который временно общается со старым backend behavior;
- **old analytics ↔ new analytics:** dashboards и alerts остаются сопоставимыми или имеют documented schema transition.

Для mobile release backward compatibility сервера — это не только additive schema. Backend должен иметь explicit support window для уже установленных app versions, sunset policy для слишком старых клиентов и rollout discipline, при которой old и new binaries сосуществуют во время staged release без forced breakage. Особо опасны removed/renamed fields, unknown enum cases, semantic changes без schema change, stricter validation, date/time format drift и server-side feature flags, меняющие meaning старого response.

Подробная экономика поддержки старых iOS versions и стоимость compatibility debt раскрывается в `1.9`; здесь focus — correctness, ownership границ и безопасная migration semantics.

#### Migration strategy
Хорошая migration strategy содержит:
1. **Inventory:** где используется deprecated API или старый behavior.
2. **Impact classification:** build blocker, runtime risk, product change, performance/security/privacy benefit.
3. **Boundary:** где будет находиться compatibility layer.
4. **Fallback:** что видит пользователь на старой OS.
5. **Tests:** old OS, new OS, data migration, server compatibility, critical flows.
6. **Rollout:** feature flags, staged release, telemetry, support notes.
7. **Removal:** trigger для удаления fallback после deployment target raise.

Пример правильной границы: вместо scattered `if #available` в каждом view создать small compatibility adapter или view modifier boundary, если это реально уменьшает duplication и risk. Но не нужно создавать абстракцию ради одного вызова; простое локальное `if #available` допустимо, если fallback obvious, tested и не повторяется.

#### Review Q&A с ответами
1. **Почему deprecation warning нельзя автоматически считать срочным blocker?**
   **Ответ:** deprecation означает, что API больше не preferred path, но urgency зависит от policy, replacement maturity, runtime risk, App Review risk и product roadmap. Нужен triage, а не panic rewrite.

2. **Почему `if #available` не доказывает обратную совместимость?**
   **Ответ:** он защищает только execution path от вызова недоступного API. Он не доказывает fallback UX, data correctness, analytics consistency, tests on old OS или migration safety.

3. **Как понять, что fallback path можно удалить?**
   **Ответ:** deployment target поднят выше affected OS, telemetry подтверждает отсутствие supported users on old path, tests/docs обновлены, data migrations безопасны, owner подтвердил removal, а release notes/support plan готовы.

4. **Что делает server API backward-compatible для mobile apps?**
   **Ответ:** additive changes, tolerant parsing, stable required fields, unknown enum handling, version negotiation where needed, explicit old app support window, sunset policy и no forced breaking response for installed old binaries.

5. **Почему API migration нельзя смешивать с большим refactor?**
   **Ответ:** иначе review не сможет отделить semantic change от mechanical migration, rollback станет сложнее, telemetry attribution ухудшится, а bugs будут казаться platform-related даже если они из refactor.

6. **Как проверять data migration при backward compatibility work?**
   **Ответ:** использовать fixtures старых versions, проверять upgrade path, launch after migration, rollback assumptions, partial migration failure, disk full и user data preservation. Успешный build не доказывает data compatibility.

#### Чеклист готовности migration/deprecation work
Compatibility/deprecation work не готово, пока:
- **Inventory:** все usages deprecated/changed API найдены и classified.
- **Triage:** severity и target release определены.
- **Boundary:** availability/fallback code расположен в понятной ownership boundary.
- **Fallback:** user-visible behavior на старой OS описан и протестирован.
- **Data:** persisted formats/migrations backward/forward strategy documented.
- **Server:** старые app versions не ломаются от backend changes; support window, sunset policy и staged rollout documented.
- **Tests:** covered oldest supported OS, newest OS, migration fixtures and critical flows.
- **Telemetry:** metrics сегментированы by OS/app version/path.
- **Removal:** owner и removal trigger для fallback/workaround зафиксированы.
- **Release:** support notes, known issues и rollout/rollback plan готовы.

#### Практическое упражнение с эталонным разбором
**Сценарий:** Apple deprecates старый navigation API, а новый API доступен только на iOS N+1. Продукт пока поддерживает iOS N.

**Эталонный разбор:** команда не переписывает весь navigation layer в одном PR. Сначала делается inventory screens и flows, где используется deprecated API. Затем выбирается boundary: например, navigation coordinator или small view adapter, который выбирает new API на iOS N+1 и fallback на iOS N. QA получает matrix для oldest supported OS и newest OS. Telemetry сравнивает navigation failures и support tickets по OS version. ADR фиксирует, что fallback будет удалён после повышения deployment target до iOS N+1. Если migration затрагивает deep links или state restoration, их проверяют отдельно fixtures и manual smoke.

### 1.9. Скрытая стоимость поддержки старых версий iOS
#### Назначение раздела
Поддержка старых версий iOS редко выглядит дорогой в одной строке кода. Стоимость прячется в матрице тестирования, fallback UI, ветках `if #available`, старых баг-репортах, замедленном освоении новых возможностей платформы, обращениях в support, ограничениях зависимостей, baseline security, раздробленной аналитике и cognitive load команды. Эта секция раскрывает экономическую сторону обратной совместимости: почему старый deployment target может быть оправдан, но должен иметь явную цену и владельца.

Связь с предыдущими секциями: `1.7` описывает governance решения о deployment target, `1.8` — correctness mechanics backward compatibility. Здесь focus — **total cost of support**: сколько реально стоит продолжать поддерживать старые версии iOS и как сделать эту стоимость видимой для engineering, QA, product, support и release owners.

#### Scope и prerequisites
Перед оценкой стоимости нужно собрать inventory:
- supported OS versions и device classes;
- active users / revenue / strategic cohorts на старых OS;
- critical flows, используемые этими cohorts;
- fallback code и ветки `if #available`;
- old-OS-only bugs и support tickets;
- стоимость manual QA, device coverage и release smoke checks;
- dependency/toolchain constraints;
- performance/memory limitations старых devices;
- security/privacy limitations старых OS;
- release blockers, App Review issues и known workarounds.

Стоимость поддержки нельзя считать только количеством пользователей. Маленький cohort может быть стратегически важным enterprise segment. Большой cohort может использовать только low-value flow. Decision model должен учитывать value, risk, support promise и opportunity cost.

#### Core theory и mental model
Скрытая стоимость старых iOS versions проявляется в нескольких слоях:

| Cost layer | Как проявляется | Почему скрыто |
| --- | --- | --- |
| Code complexity | availability branches, shims, duplicated UI paths | каждый branch кажется маленьким |
| QA cost | больше OS/device combinations | редко видно в feature estimate |
| Runtime risk | старые lifecycle/rendering/permission behaviors | баги появляются только на older devices |
| Performance cost | weaker CPU/GPU/memory, old WebKit/SwiftUI behavior | simulator не воспроизводит pressure |
| Dependency cost | packages drop old OS support | upgrade blocked unrelated feature work |
| Security/privacy cost | newer protections unavailable | risk появляется как compliance/security debt |
| Product cost | delayed adoption of new capabilities | opportunity loss не виден в crash logs |
| Support cost | old OS-specific tickets and guidance | support burden не попадает в code review |
| Cognitive cost | engineers боятся менять старые ветки поведения | slows delivery and onboarding |

Mental model: поддержка старой OS — это **ongoing subscription**, а не one-time compatibility work. Пока target остаётся низким, команда платит каждый sprint: в design, implementation, testing, release, support и incident response.

#### Подкапотные детали
Старые iOS versions могут отличаться не только отсутствием новых APIs. Различаться могут:
- SwiftUI layout invalidation и behavior modifiers;
- UIKit lifecycle edge cases;
- keyboard, safe area, sheet, navigation и focus behavior;
- `URLSession`, background tasks, push delivery и notification behavior;
- WebKit rendering и JavaScript quirks;
- Core Data/SwiftData availability and migration paths;
- memory pressure thresholds на older devices;
- permission prompts and limited access behavior;
- file protection timing;
- accessibility/Dynamic Type behavior;
- App Store/TestFlight требования к актуальному Xcode/base SDK, которые существуют отдельно от выбранного deployment target.

Важно не путать два слоя:
- **Deployment target** определяет минимальную версию iOS, на которой приложение обещает запускаться.
- **Base SDK / Xcode toolchain** определяет SDK и инструменты, которыми приложение собирается и отправляется в App Store/TestFlight.

Поддержка старого deployment target обычно не означает сборку старым SDK. Но она означает, что runtime path на старой iOS должен быть валиден, протестирован и не зависеть от APIs, доступных только на новых версиях системы.

Подкапотный риск: команда может считать старую ветку поведения “unchanged”, но новый feature code всё равно проходит через старые runtime assumptions. Например, новый SwiftUI screen использует modifier, который на старой OS имеет другой layout behavior. Или новая dependency повышает minimum OS silently и ломает archive для старого target.

#### Cost accounting framework
Чтобы обсуждение не было эмоциональным, Staff engineer делает стоимость видимой.

Минимальная cost model:
- **User value retained:** сколько active/critical users получают updates благодаря старому target.
- **Engineering hours:** сколько времени уходит на fallback implementation и maintenance.
- **QA hours:** сколько стоит matrix старых OS/devices per release.
- **Bug/support cost:** сколько incidents/tickets специфичны для старой OS.
- **Opportunity cost:** какие APIs/features/tooling заблокированы.
- **Risk cost:** какие security/privacy/performance ограничения остаются.
- **Complexity cost:** сколько code paths, shims и ownerless workarounds существуют.

Пример числового расчёта: если старая iOS версия даёт 3% active users, но требует 30% manual QA времени на релиз, блокирует security update networking dependency и создаёт 20% support tickets по критическому flow, это уже не “маленький compatibility branch”. Это отдельная продуктово-платформенная ставка, которую нужно либо финансировать, либо выводить из поддержки через понятный deprecation plan.

Пример threshold thinking:
- если old OS cohort low usage + high QA/support cost + blocks strategic API, raise target становится сильным кандидатом;
- если old OS cohort мал, но revenue-critical или contractual, нужен бюджет поддержки, а не игнорирование стоимости;
- если данных нет, first action — instrumentation, а не target change.

#### Матрица ownership
Скрытая стоимость становится управляемой только тогда, когда у каждого слоя есть владелец.

| Владелец | За что отвечает | Типичный сигнал риска |
| --- | --- | --- |
| Engineering | fallback inventory, availability branches, dependency constraints, cleanup after target raise | workaround без owner/removal trigger |
| QA | OS/device matrix, release smoke checks, old-device regression coverage | старая OS declared supported, но не тестируется |
| Product | value старого cohort, communication, deprecation timeline, exceptions | target decision принимается только по engineering convenience |
| Support | known issues, support scripts, ticket tagging by OS/device | old-OS bugs выглядят как random incidents |
| Release owner | TestFlight/App Store readiness, no-release gates, rollout/rollback notes | release подписывается без evidence по supported OS matrix |
| Security/privacy owner | limitations старой OS, accepted risks, logging/data handling | старый runtime не покрывает текущие privacy expectations |

#### Production-правила и ловушки
Production rules:
- не называй старый OS support “free”, если есть fallback code или QA matrix;
- если старая iOS заявлена supported, но нет реального device/simulator coverage и smoke checks для critical flows, это **release risk** и потенциальный **no-release gate**, а не полноценная поддержка;
- каждый old-OS workaround должен иметь owner и removal trigger;
- old device performance нужно проверять на realistic inputs;
- dependency upgrades должны включать minimum OS impact review;
- support tickets по старым OS должны попадать в platform cost dashboard;
- release estimates должны учитывать old OS validation;
- product roadmap должен видеть features blocked by deployment target;
- security/privacy limitations старых OS должны быть explicit risk, а не implicit acceptance.

Ловушки:
- **invisible QA tax:** старые OS остаются в support, но никто не выделяет время на тестирование;
- **zombie fallback:** fallback branch не используется большинством users, но ломается при каждом refactor;
- **dependency hostage:** важный package нельзя обновить из-за старого target;
- **performance denial:** команда тестирует только новый device и игнорирует older memory/CPU limits;
- **support blind spot:** tickets tagged as “random bug”, хотя pattern связан со старой OS;
- **false compassion:** команда якобы защищает старых users, но отдаёт им unstable, poorly tested experience.

#### Governance и decision process
Скрытая стоимость должна попадать в регулярный platform review, а не всплывать только во время release fire drill.

Рекомендуемый cadence:
- quarterly OS/device/support cost review;
- compatibility debt inventory;
- old OS crash/support/performance dashboard;
- dependency minimums review;
- QA matrix cost review;
- deployment target ADR update;
- product/support communication readiness.

Результаты решения:
- **Keep support with budget:** старая OS остаётся, но получает выделенный QA/support/engineering budget.
- **Prepare deprecation:** начинается communication, instrumentation, deprecation timeline и support plan.
- **Raise target:** target повышается с ADR, release plan и cleanup tasks.
- **Exception:** отдельный enterprise/strategic cohort получает special support path, если это продуктово оправдано.

#### Review Q&A с ответами
1. **Почему поддержка старой iOS не бесплатна, даже если код уже написан?**
   **Ответ:** код нужно тестировать, понимать, поддерживать при refactor, учитывать в release gates, объяснять support и не ломать при dependency/toolchain updates. Даже unchanged branch создаёт cognitive и QA cost.

2. **Как отличить реальную заботу о пользователях от ложной поддержки?**
   **Ответ:** реальная поддержка имеет QA coverage, support docs, bug triage, performance validation и owner. Ложная поддержка оставляет старых users на poorly tested path, который команда боится менять.

3. **Какие данные нужны, чтобы аргументировать повышение target?**
   **Ответ:** active/revenue users by OS/device, critical flow usage, old-OS crash/support rates, QA hours, fallback inventory, blocked roadmap items, dependency constraints и security/privacy risks.

4. **Когда маленький old OS cohort всё равно нужно поддерживать?**
   **Ответ:** когда cohort contractual, enterprise-critical, regulated, revenue-critical или стратегически важен. Тогда поддержка должна иметь explicit budget и service-level expectations.

5. **Почему dependency minimum OS — platform strategy issue?**
   **Ответ:** dependency может заблокировать security fixes, SDK updates, build modernization или feature work. Если старый target удерживает устаревшую dependency, это уже platform risk, а не локальная convenience.

6. **Что делать с old OS workaround после повышения target?**
   **Ответ:** удалить branch, tests, docs, screenshots/previews и support notes, если они больше не нужны. Если оставить workaround без supported users, он превращается в dead complexity.

7. **Почему отсутствие QA coverage для старой OS хуже честного deprecation?**
   **Ответ:** честный deprecation сообщает пользователям границы поддержки и даёт last compatible version. Непроверенная “поддержка” создаёт ложное обещание: приложение формально запускается, но critical flows могут быть сломаны без detection и owner.

#### Чеклист видимости стоимости
Поддержка старых iOS versions не считается управляемой, пока:
- **Users:** known active/revenue/strategic cohorts by OS/device.
- **QA:** old OS/device matrix имеет explicit owner и budget.
- **Release gate:** critical flows на supported OS matrix имеют smoke evidence или documented release risk.
- **Code:** fallback/workaround inventory поддерживается актуальным.
- **Metrics:** crash/hang/performance/support data сегментированы by OS/device.
- **Dependencies:** minimum OS constraints проверяются при upgrades.
- **Security/privacy:** limitations старой OS зафиксированы как accepted risk или blocker.
- **Product:** roadmap items blocked by old target видимы decision makers.
- **Support:** old OS known issues имеют support guidance.
- **Removal:** есть timeline или trigger для deprecation/target raise.

#### Практическое упражнение с эталонным разбором
**Сценарий:** старую iOS версию использует 3% active users, но она создаёт 30% manual QA времени и блокирует upgrade важной networking dependency.

**Эталонный разбор:** Staff engineer не предлагает немедленно “отрезать 3%”. Сначала cohort разбивается по revenue, geography, enterprise accounts и critical flows. QA показывает cost matrix, engineering показывает blocked dependency risks, support показывает ticket pattern. Если cohort не strategic, создаётся ADR на target raise: timeline, release notes, last compatible version, cleanup PRs, dependency upgrade plan и monitoring. Если cohort strategic, решение может быть “keep support with budget”: отдельная QA lane, owner fallback code, dependency mitigation и дата повторного review.


### 1.10. Стратегия освоения платформы уровня Staff
#### Назначение раздела
Staff-level освоение iOS-платформы — это не реакция на каждый WWDC-анонс и не накопление “современных” API ради резюме. Это управляемая стратегия: какие возможности Apple ecosystem дают продукту, пользователям, командам и платформе реальную отдачу; какие требуют migration cost; какие несут release, privacy, performance, accessibility или support risks; какие нужно отложить, пока у команды нет ownership, telemetry или compatibility plan.

Senior engineer часто решает локально: “можно ли использовать этот API в feature”. Staff/Architect решает шире: **какие платформенные возможности компания должна освоить, стандартизировать, запретить, отложить или обернуть в shared infrastructure**, чтобы несколько команд двигались быстрее и безопаснее.

Эта секция связывает предыдущие темы части I в единый governance-процесс: WWDC cycle, deployment target, backward compatibility, deprecation, hidden support cost, release gates, privacy, accessibility и operational readiness.

#### Контекст решения и stakeholders
Стратегия освоения платформы начинается с контекста, а не с технологии.

Минимальный контекст решения:
- **Product opportunity:** какую пользовательскую или бизнес-проблему решает возможность.
- **Platform leverage:** может ли возможность ускорить несколько features/teams, а не только один экран.
- **User cohorts:** какие users/devices/OS versions реально получат ценность.
- **Deployment target:** доступна ли возможность текущей supported OS matrix.
- **Fallback behavior:** что увидит пользователь, если возможность недоступна.
- **Release risk:** что изменится в TestFlight/App Store, signing, entitlements, review notes, privacy labels или rollout.
- **Operational risk:** как возможность будет debug-иться, мониториться и поддерживаться после release.
- **Team readiness:** понимает ли команда API, lifecycle, concurrency, testing и failure modes.
- **Removal/migration path:** как убрать experimental abstraction, если подход не оправдался.

Stakeholders:
- **Product:** определяет value, success criteria, non-goals и communication.
- **Design:** отвечает за UX, fallback, accessibility, localization и platform idioms.
- **iOS engineering:** проектирует ownership, APIs, lifecycle, performance и testing strategy.
- **QA:** определяет device/OS matrix, edge cases, regression scope и manual/automated gates.
- **Security/privacy:** проверяет permission surfaces, data minimization, logging, privacy manifest и risk acceptance.
- **Release owner:** проверяет TestFlight/App Store readiness, signing, entitlements, rollout и rollback.
- **Support/operations:** готовит support scripts, known issues, diagnostics и escalation paths.
- **Engineering management:** выделяет budget, staffing, sequencing и cross-team alignment.

Staff engineer обязан сделать этих участников видимыми. Если возможность затрагивает entitlements, persistence, sync, security, monetization, app lifecycle, navigation ownership или public APIs между модулями, решение не должно оставаться устной договорённостью внутри одной feature-команды.

#### Technical tradeoff и organizational impact
Платформенная возможность должна оцениваться как инвестиция, а не как isolated API call.

| Вопрос | Локальный ответ уровня feature | Staff-level ответ |
| --- | --- | --- |
| Доступность | `if #available` и fallback | OS adoption data, support policy, deprecation timeline, QA matrix |
| Архитектура | добавить wrapper/helper | ownership boundary, public API, dependency direction, migration plan |
| UX | показать новый system UI | design guidelines, accessibility, localization, degraded state |
| Performance | “работает на моём устройстве” | старые devices, memory/energy/thermal budget, launch/scroll impact |
| Privacy | добавить usage description | data minimization, logs, analytics, privacy manifest, incident response |
| Release | feature flag | rollout stages, App Review notes, entitlement validation, rollback path |
| Команды | одна команда умеет использовать API | enablement, docs, examples, review checklist, ownership model |

Типичный Staff tradeoff: новый platform API может уменьшить custom code и улучшить system integration, но повысить minimum OS, добавить entitlement, изменить permission flow, усложнить тестирование и потребовать migration существующих features. Правильное решение не обязано быть “adopt early” или “wait”. Правильное решение объясняет **когда, где, для кого, с каким fallback, под чьим ownership и по каким success metrics** возможность используется.

#### Классификация платформенных возможностей
Не все новые возможности Apple ecosystem требуют одинакового процесса.

| Категория | Примеры | Governance level |
| --- | --- | --- |
| Локальное UI/API improvement | новый SwiftUI modifier, UIKit convenience API | lightweight review, availability check, visual QA |
| Cross-feature UI pattern | NavigationStack conventions, sheet behavior, Dynamic Type policy | shared guideline, examples, regression matrix |
| Возможность с permission/entitlement | Camera, Location, Bluetooth, HealthKit, App Groups, Push Notifications | ADR/RFC, privacy review, release checklist |
| Возможность с data ownership | SwiftData/Core Data migration, offline sync, App Intents writing data | ADR/RFC, migration/rollback plan, observability |
| Возможность с external contract | Universal Links, widgets, Live Activities, App Clips, extensions | backend/product/support alignment, rollout plan |
| Platform-wide abstraction | networking client, analytics layer, design system, navigation shell | architecture governance, ownership, adoption plan |
| Experimental adoption | beta APIs, speculative new UX, prototype-only platform feature | explicit experiment scope, no production coupling без review |

Rule of thumb: чем больше возможность меняет user trust, persisted data, app lifecycle, external integrations или team APIs, тем больше нужен формальный артефакт решения.

#### End-to-end процесс принятия решения
Практический процесс должен быть линейным и проверяемым:

1. **Idea:** сформулировать user/product/platform problem, а не только название API.
2. **Triage:** определить категорию риска: local UI, cross-feature pattern, data ownership, entitlement, external contract или platform abstraction.
3. **Evidence:** собрать OS adoption, affected flows, privacy/security surface, QA matrix, performance risks и support impact.
4. **Pilot:** ограничить внедрение reversible scope, если uncertainty высокая.
5. **RFC/ADR:** зафиксировать options, decision, owner, migration, rollout, rollback и revisit/kill criteria.
6. **Rollout:** выпускать staged; feature flag или remote config использовать только там, где они реально помогают отключить риск без data loss.
7. **Observability:** заранее определить metrics, logs, crash/performance signals и support tags.
8. **Standardization or stop:** если pilot успешен — стандартизировать examples, docs и review criteria; если нет — закрыть experiment, удалить abstraction или оставить bounded fallback с owner.

Этот flow защищает от двух крайностей: хаотичного внедрения каждого нового API и консервативного запрета всего нового без product evidence.

#### Governance artifact или process to produce
Staff engineer не должен превращать каждую мелкую API adoption в бюрократию. Но значимые платформенные решения требуют одного из трёх уровней артефакта.

1. **Lightweight decision note** — для локального API usage без irreversible consequences.
   - Что используем.
   - На каких OS versions.
   - Какой fallback.
   - Как проверено.
   - Кто owner.

2. **RFC** — для cross-team pattern или shared infrastructure.
   - Problem statement.
   - Options considered.
   - Recommended approach.
   - Public API / integration contract.
   - Migration plan.
   - План тестирования и release.
   - Open questions с owner, deadline и stop/continue rule.

3. **ADR** — для irreversible или high-risk decisions.
   - Context.
   - Problem.
   - Options considered.
   - Decision.
   - Consequences.
   - Migration plan.
   - Rollback plan.
   - Review/revisit trigger.
   - Owner.

Открытые вопросы в RFC допустимы только как управляемый work item: у каждого вопроса должен быть owner, срок, правило `stop/continue` и влияние на release scope. В готовом учебном материале вопросы без ответа не оставляются; в реальном RFC они не должны превращаться в бессрочную неопределённость.

ADR/RFC обязателен, если platform adoption:
- вводит новый module/package/layer;
- меняет persistence/backend/sync architecture;
- добавляет critical dependency;
- меняет navigation/session/auth ownership;
- добавляет feature flags или rollout infrastructure;
- требует entitlement, App Group, extension target или background mode;
- меняет privacy/data retention/logging model;
- делает irreversible migration/release decision.

#### Platform adoption roadmap
Освоение платформы должно попадать в roadmap так же явно, как product features.

Хороший platform adoption roadmap содержит:
- **Now:** возможности, которые уже нужны текущим product goals и имеют clear rollout path.
- **Next:** возможности, которые нужно подготовить через abstractions, docs, QA matrix или dependency work.
- **Later:** возможности с возможной ценностью, но без достаточного adoption/data/team readiness.
- **Not now:** возможности, которые выглядят модно, но несут несоразмерный cost или не решают текущую проблему.

Каждая entry должна иметь:
- owner;
- expected user/product/platform value;
- supported OS/device policy;
- fallback/degraded behavior;
- risks and mitigations;
- validation plan;
- rollout and rollback plan;
- documentation/review checklist;
- revisit trigger.

Без revisit trigger roadmap превращается в wish list. Пример trigger: “вернуться к внедрению, когда iOS N+ adoption > 80% active users”, “когда dependency X поддержит нужный OS target”, “после закрытия P0 accessibility gaps”, “после появления telemetry для current workaround”.

Kill criteria нужны так же, как success criteria. Pilot закрывается или откатывается, если:
- degraded/accessibility paths не проходят supported device/OS checks;
- crash, hang, launch, memory или support metrics ухудшаются сверх заранее заданного threshold;
- возможность требует постоянного expert-only ownership;
- fallback становится сложнее исходной проблемы;
- privacy/security review находит неприемлемый risk;
- App Review, entitlement или backend contract делает rollout непредсказуемым.

Пример roadmap entry:

| Поле | Пример для App Intents |
| --- | --- |
| Owner | iOS platform lead + product owner search/actions |
| Ценность | user может выполнить сохранённое действие из system surfaces без открытия полного flow |
| OS policy | только supported iOS versions с App Intents; для остальных обычный in-app flow |
| Fallback | если auth/session/permission недоступны, intent возвращает безопасную localized ошибку и не мутирует данные |
| Risks | privacy of exposed entities, localization, background execution, idempotency, support confusion |
| Validation | unit/integration tests for intent handlers, manual VoiceOver/localization checks, analytics tags |
| Rollout | staged behind server-side eligibility where applicable, release notes and support docs |
| Rollback | disable eligibility, keep in-app flow, preserve local pending mutations |
| Revisit/kill trigger | kill if support tickets or failed intent rate exceed threshold during first release cohort |

#### Enablement и стандартизация
Staff-level adoption считается успешным только тогда, когда возможность может безопасно использовать не один эксперт, а несколько команд.

Enablement package:
- reference implementation или пример в production-like context;
- review checklist;
- usage guidelines;
- anti-patterns и минимум один плохой пример, который review должен отклонять;
- test matrix;
- accessibility/localization notes;
- privacy/logging rules;
- release notes template;
- migration guide;
- owner and escalation path.

Стандартизация не означает “обернуть всё в generic framework”. Часто лучший standard — короткий guideline, один хороший пример и запрещение опасных вариантов. Shared abstraction нужна только там, где она уменьшает duplicated risk, защищает invariants или создаёт cross-team leverage. Если abstraction скрывает platform semantics, ломает debugging или заставляет feature teams угадывать lifecycle, она вреднее прямого API usage.

#### Escalation, alignment и communication risks
Платформенные решения часто конфликтуют с локальными целями feature-команд. Staff engineer управляет этим конфликтом через ясные escalation rules.

Escalation нужен, если:
- команда хочет использовать возможность без fallback для supported OS;
- feature требует permission до понятной user value;
- rollout зависит от entitlement, backend contract, push, Universal Links или App Store review;
- migration может потерять user data;
- new dependency меняет deployment target, binary size, privacy surface или build reliability;
- performance impact не измерен на старых devices;
- возможность создаёт новый public API, который будут использовать другие команды;
- product хочет deadline, несовместимый с release safety.

Communication risks:
- **local optimization:** одна команда ускорилась, но остальные получили debt;
- **platform theater:** возможность adopted ради “modern stack”, но без user value;
- **silent policy change:** deployment target, permission behavior или data retention изменились без product/support awareness;
- **expert bottleneck:** только один engineer понимает new API и все edge cases;
- **documentation gap:** возможность есть, но review не знает критериев correctness;
- **fallback neglect:** happy path polished, degraded state плохо протестирован.

Staff response: не блокировать innovation reflexively, а потребовать evidence, scope, owner, fallback и артефакт решения подходящего размера.

Для high-risk возможностей обязателен threat/privacy review. Минимальный scope: какие данные становятся доступными новой поверхности, когда показывается permission prompt, что попадает в logs/analytics/crash metadata, нужен ли privacy manifest update, какой App Review risk появляется, как выглядит incident path и кто принимает residual risk.

Новая платформенная возможность не считается внедрённой, пока degraded paths и accessibility paths не проверены на поддерживаемых устройствах/iOS: VoiceOver, Dynamic Type, Reduce Motion, localization length, denied/restricted permissions и offline/error states.

#### Success metrics и observability
У платформенной стратегии должны быть observable outcomes.

Метрики adoption:
- доля features, использующих standard pattern вместо custom paths;
- сокращение duplicated code/workarounds;
- снижение defects в affected flows;
- time-to-implement для новых features;
- build/release stability;
- crash/hang/performance metrics by OS/device;
- accessibility/localization regression rate;
- support tickets by capability/version/device;
- скорость удаления legacy fallback после target raise.

Метрики должны защищать от vanity adoption. Если новый API внедрён, но user-visible reliability ухудшилась, QA matrix выросла без бюджета, а support не получил diagnostics, adoption нельзя считать успешным.

#### Review Q&A с ответами и calibration rubric
1. **Почему Staff engineer не должен автоматически внедрять каждый новый Apple API?**
   **Ответ:** новый API может быть ценным, но он несёт compatibility, release, privacy, performance, training и support costs. Staff-level решение требует доказать user/platform value, fallback, ownership и rollout path.

2. **Когда достаточно lightweight decision note, а когда нужен ADR/RFC?**
   **Ответ:** lightweight note подходит для локального reversible API usage. ADR/RFC нужен, когда решение меняет public API, ownership, persistence, sync, dependencies, entitlements, rollout infrastructure, privacy model или deployment target.

3. **Как отличить platform leverage от локального convenience?**
   **Ответ:** platform leverage улучшает несколько команд или целый класс features: снижает duplicated risk, ускоряет delivery, стандартизирует UX/correctness или улучшает observability. Local convenience ускоряет один implementation без устойчивой cross-team выгоды.

4. **Почему fallback — часть platform strategy, а не UI detail?**
   **Ответ:** fallback определяет, остаётся ли продукт корректным на supported OS/devices, при denied permissions, failed entitlement path, offline state или rollout rollback. Плохой fallback превращает platform adoption в сегментированный product bug.

5. **Как понять, что adoption стал bottleneck из-за одного эксперта?**
   **Ответ:** признаки: review ждёт одного человека, bugs не triage-ятся без него, docs отсутствуют, examples устарели, feature teams копируют code snippets без понимания lifecycle, а incidents эскалируются не по owner path, а “к тому, кто внедрял”.

6. **Что должно быть в calibration rubric для review?**
   **Ответ:** reviewers должны проверять value, supported OS policy, fallback, ownership, privacy/logging, accessibility/localization, performance, testing, rollout/rollback и observability. Если любой critical пункт неизвестен, решение не готово к broad adoption.

#### Case studies и упражнения с эталонным разбором
**Case study 1: раннее внедрение нового SwiftUI navigation API**

Сценарий: команда хочет заменить существующую navigation abstraction на новый SwiftUI API сразу после WWDC, потому что текущий код сложный.

**Эталонный разбор:** правильное решение начинается не с migration PR. Нужно собрать affected flows, supported OS matrix, deep links, state restoration, tests, known bugs, feature team usage и rollback strategy. Если новый API доступен не всем supported OS, нужен compatibility layer или staged adoption. Если abstraction является public API для нескольких команд, требуется RFC: options, migration plan, examples, review checklist и owner. Если benefit локальный, а migration risk высокий, допустим pilot на одном reversible flow.

**Case study 2: adoption App Intents для user actions**

Сценарий: product хочет добавить App Intents, чтобы user мог выполнять действия через system surfaces.

**Эталонный разбор:** Staff review проверяет не только API usage. Нужно определить supported actions, auth/session behavior, permission state, offline behavior, data mutation idempotency, privacy of exposed phrases/entities, analytics, localization, accessibility, support docs и rollback. Если intent мутирует данные, required path включает persistence consistency, conflict handling, background execution constraints и diagnostics.

**Case study 3: новая dependency для shared networking layer**

Сценарий: одна команда предлагает заменить networking layer на популярную library, чтобы ускорить implementation.

**Эталонный разбор:** Staff-level ответ требует dependency review: minimum OS, binary size, security posture, maintenance health, cancellation semantics, `URLSession` integration, auth refresh, logging redaction, testing, migration, rollback и ownership. Если выгода только в syntactic convenience, dependency может быть rejected. Если выгода в reliability, observability и shared correctness, решение оформляется ADR с staged migration.

#### Чеклист готовности platform adoption
Возможность не готова к Staff-level adoption, пока нет защищаемых ответов:
- **Value:** какая user/product/platform проблема решается.
- **Scope:** где возможность используется и где не используется.
- **OS policy:** какие iOS versions/devices supported, какой fallback.
- **Ownership:** кто владеет API, docs, incidents, migration и cleanup.
- **Architecture:** какие boundaries, dependencies и public contracts меняются.
- **Privacy/security:** какие data, permissions, entitlements, logs и manifests затронуты.
- **Accessibility/localization:** как возможность ведёт себя с VoiceOver, Dynamic Type, locale, RTL и content size changes.
- **Performance:** что происходит с launch, scrolling, memory, energy и old devices.
- **Testing:** какая automated/manual matrix доказывает correctness.
- **Release:** какие App Store/TestFlight/signing/entitlement/rollout steps нужны.
- **Observability:** как будут обнаружены regressions после release.
- **Rollback:** как отключить, откатить или ограничить возможность без data loss.
- **Enablement:** как другие команды узнают правильный usage и anti-patterns.


## 2. App lifecycle и поведение процесса
### 2.1. Холодный запуск
#### Назначение раздела
Холодный запуск — это путь от отсутствующего app process до первого используемого состояния интерфейса, когда пользователь может понять, что приложение живо, и начать осмысленное взаимодействие. В production iOS это не “быстро открыть экран на simulator”. Это lifecycle-critical path, где сходятся dyld, Swift runtime, static initializers, dependency creation, app/scene lifecycle, session restore, local persistence, feature flags, privacy prompts, logging, analytics, remote config и первый render.

Senior-level ошибка — считать запуск одной функцией `main` или `App.body`. Staff-level mental model: **cold launch — это продуктовый SLA, архитектурный boundary и release gate**. Всё, что попадает до first usable screen, конкурирует за пользовательское внимание, main thread, memory peak, disk I/O, CPU, energy и crash-free startup.

#### Определение и mental model
Различай несколько видов запуска:
- **Cold launch:** process не был в памяти; система создаёт процесс заново.
- **Warm launch:** process уже существует или недавно был suspended; часть state может быть в памяти.
- **Relaunch after jetsam:** внешне похож на cold launch, но должен восстановить durable state после memory termination.
- **Relaunch after crash:** требует crash-safe recovery, а не только fast UI.
- **Launch from notification/deep link/widget/App Intent:** запуск имеет routing intent и может требовать auth/session coordination.
- **Launch after update/migration:** старт включает compatibility, migration и feature gating risk.

Scope boundary: в этом разделе jetsam, crash recovery, scene recreation, background work и deep links рассматриваются только как **варианты входа в launch path и источники launch risk**. Глубокий разбор process lifetime, scene lifecycle, foreground/background transitions и background execution остаётся для следующих разделов части II.

Важно также учитывать prewarming и non-user-visible launch scenarios. iOS может подготовить или запустить процесс не строго из-за tap по иконке, а launch code может выполниться до того, как пользователь явно увидел UI. Поэтому startup side effects должны быть безопасными: не отправлять неверные analytics events, не выполнять лишние network mutations, не показывать permission prompts без контекста и не считать любой старт доказательством user intent.

Практическая формула: **на cold launch приложение должно сделать только минимально необходимое для безопасного, понятного и интерактивного первого состояния; всё остальное должно быть lazy, cancellable, отложено или выполняться инкрементально**.

Первый usable screen не всегда равен “главный экран полностью загружен”. Для news/feed app usable state может быть cached content + visible refresh indicator. Для banking app — secure auth gate. Для editor app — restored document shell. Для media app — library skeleton with local metadata. Product должен определить, что считается usable, иначе performance work превращается в спор о субъективном ощущении.

#### Performance budget и measurement target
Не существует универсального launch budget, который можно честно применить ко всем приложениям, устройствам и рынкам. Но production-команда обязана иметь измеримый target.

Минимальные launch targets:
- **First process alive:** process создан, early crash не произошёл.
- **First frame:** UI впервые представлен системой.
- **Первый usable screen:** пользователь видит осмысленное состояние, не пустой blocking spinner без контекста.
- **Interaction ready:** primary tap/scroll/input не блокируется heavy startup work.
- **Critical background readiness:** deep link, notification или auth routing не потеряны.

Budget задаётся по matrix:
- device class: latest, median supported, oldest supported;
- OS versions: newest, lowest supported, high-traffic previous versions;
- install state: fresh install, logged-in, logged-out, large local data, after update;
- entry point: icon tap, push notification, Universal Link, widget/App Intent handoff;
- network state: online, offline, captive/slow network;
- thermal/power state: normal vs Low Power Mode where relevant.

Senior target: запуск не должен выполнять unnecessary synchronous network/database/media work before first usable screen. Staff target: launch path должен быть **ограничен по ресурсам, наблюдаем, имеет владельца и защищён от регрессий**.

#### Launch decision gate
Перед оптимизацией нужно классифицировать startup work:

| Категория работы | Решение | Примеры |
| --- | --- | --- |
| Блокирует первый экран | Разрешено только при security/correctness necessity | auth lock state, critical schema compatibility check, required local snapshot |
| Выполняется до first interaction | Допустимо, если коротко и не держит main actor | root view model setup, lightweight cached state mapping |
| Выполняется после первого usable screen | Предпочтительно для refresh/prefetch/analytics | remote config refresh, feed sync, image prefetch, analytics upload |
| Выполняется в фоне/по расписанию | Только с lifecycle/background constraints | cleanup, indexing, periodic sync, large cache maintenance |
| Не должна запускаться на launch | Удалить из launch path | speculative SDK setup, full media decoding, unnecessary network mutation |

Если команда не может объяснить, почему work находится в первой категории, work должна быть перенесена ниже по таблице или удалена из launch path.

#### Launch phases под капотом
Cold launch удобно разбирать по фазам:

| Фаза | Что происходит | Типичный риск |
| --- | --- | --- |
| Process creation / dyld | загрузка executable, frameworks, symbols, ObjC/Swift metadata | тяжёлые dynamic frameworks, excessive initializers |
| Static/global initialization | global variables, singletons, static properties, dependency registries | скрытая работа до app lifecycle |
| `main` / SwiftUI `App` init | создание app object, environment, early services | synchronous DI graph, logging/analytics setup |
| Application/scene lifecycle | `UIApplicationDelegate`, `SceneDelegate`, SwiftUI scene creation | смешивание lifecycle, routing и heavy services |
| First render | построение initial view tree, layout, image/text preparation | heavy SwiftUI `body`, broad observation, media decoding |
| First interaction | user taps/scrolls/types while startup tasks continue | main actor saturation, state races, duplicate refresh |
| Post-launch отложенная работа | refresh, sync, migrations, prefetch, analytics | work не bounded, не cancellable, конкурирует с UI |

Подкапотный принцип: even if work is “async”, она может вернуться на main actor, захватить locks, создать memory peak или вызвать broad invalidation в момент первого render. Поэтому launch review должен смотреть end-to-end path, а не только наличие `Task {}`.

#### Instrumentation setup и trace interpretation
Launch performance нельзя оценивать по ощущению на одном simulator run.

Минимальный measurement setup:
- использовать Release-like build configuration, а не debug-only assumptions;
- тестировать на real device, если делается performance claim;
- очищать или контролировать state: fresh install, logged-in, cached data, large data;
- повторять сценарий несколько раз и сравнивать median/p95, а не один удачный run;
- отдельно измерять icon launch, notification launch, Universal Link launch и after-update launch;
- фиксировать device, OS, build number, data state, network state и tool.

Инструменты:
- **Xcode Organizer metrics:** high-level launch trends after release.
- **Instruments App Launch template:** фазы startup, main thread work, dyld/static initializer cost.
- **Time Profiler:** CPU hotspots during launch.
- **Instruments Hangs / Time Profiler:** long blocking work, CPU hotspots and UI stalls.
- **Main Thread Checker:** полезен для нарушений UIKit/AppKit main-thread contract, но не является основным инструментом измерения hangs.
- **os_signpost / MetricKit:** product-specific launch milestones.
- **Unified logging:** only privacy-safe, bounded startup diagnostics.

Пример signpost strategy:

```swift
import os

private let launchLog = OSLog(subsystem: "com.example.app", category: "Launch")

enum LaunchSignpost {
    static let firstUsableScreen = OSSignpostID(log: launchLog)

    static func markFirstUsableScreen() {
        os_signpost(.event, log: launchLog, name: "FirstUsableScreen", signpostID: firstUsableScreen)
    }
}
```

Для длительных фаз полезен не только event, но и interval signpost:

```swift
func measureSessionRestore(_ operation: () async throws -> Void) async rethrows {
    let signpostID = OSSignpostID(log: launchLog)
    os_signpost(.begin, log: launchLog, name: "SessionRestore", signpostID: signpostID)
    defer {
        os_signpost(.end, log: launchLog, name: "SessionRestore", signpostID: signpostID)
    }

    try await operation()
}
```

Interpretation rules:
- если trace показывает main thread blocked, сначала найти synchronous caller, а не “добавить ещё async”;
- если dyld/static cost высокий, проверить frameworks, global initializers, static registries и eager dependency graphs;
- если first frame быстрый, но interaction blocked, это всё равно launch regression;
- если p95 плохой, а median хороший, искать data-size, device-class, migration, network или auth edge cases;
- если launch after update медленный, отделить one-time migration от постоянной startup cost;
- если simulator выглядит хорошо, не считать это доказательством для старых devices.

#### Hot-path риски и static red flags
Static review часто находит launch regressions до Instruments.

Red flags:
- synchronous network request, remote config, auth refresh или feature flag fetch before first usable screen;
- database migration/fetch-all/save-all на main actor during launch;
- image/PDF/video thumbnail decoding before first screen;
- heavy JSON parsing, compression, hashing, encryption или search indexing на main actor;
- global singleton, который создаёт весь dependency graph при первом access;
- `@MainActor` service/repository только ради удобства UI calls;
- SwiftUI `body`, который сортирует/filter/map large collections во время initial render;
- broad observable app state, invalidating large view tree при каждом startup milestone;
- eager analytics/logging SDK setup, который блокирует launch;
- permission prompt на cold launch без user context;
- migration без progress/recovery strategy;
- unbounded `Task` launched from `App.init`, root view `task`, scene phase handler или dependency container;
- duplicated refresh: launch refresh + foreground refresh + first screen refresh одновременно.

Senior review должен требовать owner для каждого startup task:
- кто запускает work;
- почему она нужна до first usable screen;
- где cancellation/timeout;
- что происходит offline;
- как защищены local state и user intent;
- как work наблюдается в metrics/logs;
- как она не запускается повторно из scene recreation.

Пример распределения ответственности, не обязательная архитектура:

| Компонент | Ответственность | Не должен делать |
| --- | --- | --- |
| `BootCoordinator` | минимальный boot sequence, ordering, launch milestones | загружать feature data целиком |
| `SessionRestorer` | восстановить auth/session/security state | silently drop pending route intent |
| `RouteIntentStore` | сохранить launch/deep-link/push intent до готовности route | напрямую управлять SwiftUI navigation без domain checks |
| `MigrationRunner` | выполнить blocking compatibility migrations и запланировать deferred enrichment | делать необратимые изменения без recovery path |
| `FeatureRefreshScheduler` | запускать post-launch refresh/prefetch с cancellation/backoff | блокировать first usable screen |

#### Architecture rules for launch ownership
Хороший launch design отделяет app boot, session restoration, routing и feature loading.

Разделяй:
- **Boot state:** минимальная инфраструктура, без которой app не может показать безопасный shell.
- **Session state:** logged-in/logged-out/expired/locked/unknown.
- **Navigation intent:** icon, deep link, push, widget, App Intent, handoff.
- **Durable user state:** persisted drafts, pending mutations, selected document, auth tokens.
- **Feature data:** content, feeds, recommendations, profile, remote state.
- **Отложенная работа:** sync, prefetch, analytics upload, cleanup, indexing.

Правило: feature data редко должна блокировать app shell. Session/security gate может блокировать sensitive content, но не обязан блокировать rendering всего приложения. Navigation intent должен сохраняться, если auth/session transition временно не позволяет выполнить route сразу.

Migration rule: blocking launch migration допустима только для compatibility work, без которой приложение не может безопасно прочитать данные или показать корректный shell. Deferred enrichment — индексы, derived caches, thumbnails, search metadata, recommendations — должна выполняться после usable UI, инкрементально и с recovery path. Для каждой migration измеряй duration, failure rate, retry/rollback behavior и partial migration recovery. Если migration может быть interrupted by crash/jetsam, она должна быть idempotent и checkpointed.

Пример безопасной модели launch routing:

```swift
indirect enum LaunchRouteIntent: Equatable {
    case home
    case article(id: Article.ID)
    case pendingAuthThen(LaunchRouteIntent)
}

@MainActor
final class LaunchCoordinator {
    private var pendingIntent: LaunchRouteIntent?

    func receiveLaunchIntent(_ intent: LaunchRouteIntent) {
        pendingIntent = intent
        reconcileRouteIfPossible()
    }

    func sessionStateChanged() {
        reconcileRouteIfPossible()
    }

    private func reconcileRouteIfPossible() {
        // В production здесь проверяются session/auth/permission/domain constraints.
        // Важно: intent не теряется только потому, что app ещё не готова к route.
    }
}
```

#### Optimization tradeoff-ы и regression guardrails
Launch optimization не должна ломать correctness.

Tradeoffs:
- **Lazy initialization vs first-use latency:** отложенная работа ускоряет launch, но не должна создавать hitch при первом tap.
- **Cached UI vs stale content:** cached state ускоряет usable screen, но UI должен показывать freshness and refresh state.
- **Deferred migration vs data correctness:** не все migrations можно отложить; user-critical schema changes требуют safe upfront path.
- **Skeleton UI vs misleading readiness:** skeleton полезен, если пользователь понимает состояние; бесконечный blank spinner скрывает проблему.
- **Feature flags vs startup blocking:** flags полезны, но synchronous flag fetch before UI часто хуже, чем безопасные значения по умолчанию + later update.
- **SDK initialization vs observability:** analytics/crash SDKs важны, но не должны блокировать root UI без доказанной необходимости.

Guardrails:
- startup tasks имеют timeout/cancellation where applicable;
- local cached state отображается до remote refresh, если это безопасно;
- feature flag defaults production-safe and privacy-safe;
- migrations idempotent and crash-safe;
- startup signposts стабильны между releases;
- launch metrics segment by device/OS/data size/entry point;
- regression budget является release gate для primary flows;
- PR, добавляющий SDK/dependency/global initializer/root task, обязан явно указать, попадает ли work в launch path;
- `git diff`/review должен явно показывать, если новая dependency или initializer попадает в launch path.

#### Примеры before/after validation
**Пример 1: remote config блокирует первый экран**

Before:
```swift
@MainActor
func start() async throws {
    let flags = try await remoteConfig.fetch()
    appState.apply(flags)
    rootScreen = .home
}
```

Проблема: offline/slow network задерживает first usable screen, а failure remote config превращается в launch failure.

After:
```swift
@MainActor
func start() {
    appState.apply(cachedOrDefaultFlags)
    rootScreen = .home

    Task { [remoteConfig] in
        do {
            let freshFlags = try await remoteConfig.fetchWithTimeout()
            await MainActor.run {
                appState.apply(freshFlags)
            }
        } catch {
            // Launch остаётся usable; failure уходит в privacy-safe diagnostics.
        }
    }
}
```

Validation:
- offline launch shows usable safe default state;
- slow network does not block first interaction;
- flag update does not invalidate unrelated view tree;
- failed fetch produces bounded diagnostic event.

**Пример 2: database fetch-all during launch**

Before: root model загружает все records, чтобы показать счетчики, badges и recent items.

After: shell получает lightweight snapshot, critical screen lazily fetches visible data, badges update after first render.

Validation:
- launch trace shows no large main-thread fetch;
- old device with large dataset reaches first usable screen within target;
- after-update migration path remains crash-safe;
- UI distinguishes cached snapshot and refreshing state.

**Пример 3: deep link arrives before auth restoration**

Before: app parses Universal Link during launch, cannot route because session unknown, silently drops link.

After: app persists `LaunchRouteIntent`, restores session, then reconciles route or shows auth gate with pending destination.

Validation:
- link survives cold launch;
- link survives auth refresh;
- invalid/unauthorized link produces safe user-facing message;
- no duplicate navigation occurs after scene recreation.

**Пример 4: permission prompt на cold launch**

Before: app сразу показывает location или notification permission prompt, потому что первый экран “когда-нибудь использует” эту capability.

Проблема: пользователь ещё не видит value, prompt выглядит случайным, denial становится вероятнее, а launch path получает privacy/review risk.

After: первый экран объясняет product value, permission запрашивается в момент user intent, denied/restricted state имеет полноценный UI, а cold launch остаётся без prompt side effects.

Validation:
- fresh install launch не показывает permission prompt без действия пользователя;
- denied/restricted state не ломает первый экран;
- analytics не логирует sensitive prompt context;
- App Review rationale совпадает с реальным UX.

#### Testing strategy
Launch testing should cover correctness and performance.

Minimum matrix:
- fresh install logged-out;
- logged-in with cached data;
- logged-in with large local data;
- after app update with migration;
- offline launch;
- push/deep link launch;
- lowest supported iOS/device class;
- app killed during previous sync or mutation;
- denied/revoked permission affecting initial screen.

Automated tests can validate state machines, routing intent preservation, migration idempotency and startup policy decisions. Real-device profiling is needed for credible performance claims. Manual QA remains necessary for first-frame perception, auth gates, permission prompts, deep link flows and old-device responsiveness.

#### Interview/incident-review Q&A с ответами
1. **Почему холодный запуск нельзя оптимизировать только переносом работы в `Task {}`?**
   **Ответ:** `Task` не гарантирует, что work не повлияет на launch. Она может стартовать сразу, вернуться на main actor, удержать locks, вызвать memory peak или broad invalidation. Нужно понимать priority, cancellation, actor hops, resource usage and UI timing.

2. **Какая работа действительно должна выполняться до first usable screen?**
   **Ответ:** только работа, без которой нельзя безопасно показать корректный shell: минимальная configuration, crash-safe session/security state, локальный durable snapshot where needed, routing intent capture и essential dependency setup. Remote refresh, prefetch, analytics upload, indexing и noncritical SDK setup обычно должны быть deferred.

3. **Почему first frame не равен successful launch?**
   **Ответ:** первый frame может быть пустым shell или spinner, пока main actor заблокирован. Success означает first usable screen и interaction readiness: пользователь видит meaningful state и primary interaction не зависает.

4. **Как расследовать launch regression после release?**
   **Ответ:** сегментировать metrics by app version, OS, device, data size, entry point and install/update state; сравнить p50/p95; проверить crash/hang reports, MetricKit, Organizer metrics, startup signposts and recent changes in dependencies, migrations, SDK initialization and root view rendering.

5. **Когда launch slowdown допустим?**
   **Ответ:** только если slowdown bounded, one-time или product-critical, имеет user-visible rationale/progress, rollback/recovery path и измеренный impact. Например, обязательная migration может быть допустима, если она crash-safe, idempotent and communicated через release readiness.

6. **Что должно быть в post-incident action после плохого cold launch release?**
   **Ответ:** identify root startup path, add regression metric/signpost, remove or defer noncritical work, add QA scenario for affected state, document owner, add release gate and verify on representative device/OS/data matrix.

#### Чеклист production-readiness для cold launch
Cold launch не готов к production, пока:
- first usable screen определён product/engineering совместно;
- startup tasks имеют owners and justification;
- unnecessary network/database/media work removed before first usable screen;
- session restoration and deep link intent preservation covered;
- migrations are idempotent, crash-safe and measured;
- root SwiftUI view does not perform heavy sorting/filtering/decoding/fetching;
- feature flags have безопасные значения по умолчанию and do not block UI;
- privacy prompts are not shown before user context;
- launch metrics/signposts exist for primary milestones;
- release checks include old device / lowest supported OS / large data case;
- failures degrade to safe UI state instead of blank launch blocker;
- post-launch отложенная работа is bounded, cancellable and observable.


### 2.2. Тёплый запуск
#### Назначение раздела
Тёплый запуск — это возвращение пользователя в приложение, когда app process уже существует или недавно был suspended, а часть runtime state, caches, tasks, scenes и navigation state может оставаться в памяти. Он кажется проще cold launch, потому что dyld/static initialization уже позади, но production-риск часто выше: приложение должно быстро вернуть usable UI и одновременно reconcile stale state, session, permissions, network reachability, background results, deep links и scene lifecycle.

Senior-level ошибка — считать warm launch “просто продолжением того же состояния”. Staff-level mental model: **warm launch — это foreground reactivation path with stale assumptions**. Всё, что было истинно до ухода в background, могло измениться: auth token, permissions, local database, remote state, feature flags, device time, network, Low Power Mode, thermal state, widgets/extensions data, push payloads и user expectations.

#### Определение и границы scope
Warm launch включает несколько сценариев:
- пользователь возвращается из app switcher;
- suspended process становится active;
- backgrounded app получает foreground scene;
- новая scene подключается к уже живому process на iPadOS;
- приложение открывается через push/Universal Link/widget/App Intent, пока process уже существует;
- app возвращается после system UI: permission prompt, Share Sheet, document picker, Sign in with Apple, StoreKit, camera/photos/files flow;
- app возвращается после короткого background task или interrupted operation.

Scope boundary: этот раздел не повторяет cold launch и не раскрывает полностью background execution. Здесь фокус — **warm return path**: пользовательское восприятие возвращения, stale local UI, быстрый first interaction, bounded reconciliation, deduplicated refresh и безопасное восстановление route/session/permission state. Формальная семантика foreground activation callbacks, ordering, inactive/active transitions и различия app vs scene events раскрываются в `2.3`. Глубокий multi-window scene ownership остаётся для отдельных scene lifecycle разделов.

Практическая формула: **warm launch должен восстановить visible local state immediately, затем выполнить bounded reconciliation without blocking first interaction**.

#### Performance budget и measurement target
Warm launch target обычно строже cold launch по user perception: пользователь ожидает почти мгновенного возвращения туда, где остановился. Даже если remote state устарел, UI должен показать local visible content quickly и честно обозначить refresh/freshness.

Основные milestones:
- **Foreground activation received:** app/scene получила signal возвращения.
- **Previous UI visible:** последний meaningful screen снова отображён.
- **Interaction ready:** scroll/tap/input работают без main actor stall.
- **Reconciliation started:** refresh/session/permission checks запущены без blocking UI.
- **Reconciliation settled:** UI обновил freshness, auth, errors, conflicts или pending operations.

Warm launch budget должен измеряться не одним удачным run, а p50/p95/p99 на одинаковом device/scenario before-after. Matrix для сравнения:
- short background interval vs long background interval;
- same scene vs recreated/disconnected scene;
- single-window vs multi-window iPadOS;
- logged-in vs expired session;
- unchanged permissions vs revoked permissions;
- pending sync/mutation exists vs no pending work;
- notification/deep link entry vs simple app switcher return;
- old device / lowest supported OS / large visible dataset.

Rule: warm launch не должен синхронно блокировать previous UI на network refresh, remote config, full database reload, media decoding или auth refresh, если можно показать безопасный local state and reconcile after activation.

Sensitive UI exception: если session expired, app lock включён, device/security policy требует re-auth, account switched или screen содержит privacy-sensitive data, previous UI нельзя безусловно показывать immediately. Target state — redacted shell, lock gate или skeleton, который сохраняет navigation context, но не раскрывает protected content.

#### Lifecycle states и reactivation flow
Warm launch нельзя сводить к одному `scenePhase == .active`.

Relevant layers:
- **Process state:** process alive, suspended, backgrounded, active.
- **Application state:** active/inactive/background transitions.
- **Scene state:** connected, foreground active, foreground inactive, background, discarded.
- **Feature task state:** running, suspended, cancelled, obsolete, expired.
- **Data state:** fresh, stale, locally mutated, conflict-prone, invalidated.
- **Session state:** valid, expired, locked, revoked, unknown.

Типовой warm activation flow:
1. Capture activation context: simple return, deep link, notification, system UI return, scene recreation.
2. Render previous local UI state immediately if safe.
3. Reconcile session/security state.
4. Re-check permissions and external inputs that can change outside the app.
5. Resume or cancel feature tasks based on visibility and ownership.
6. Start bounded refresh/sync with cancellation and deduplication.
7. Update UI with freshness, errors, conflicts or pending state.
8. Emit privacy-safe metrics for activation latency and reconciliation outcome.

Важно: app may become active multiple times quickly. Activation handler must be idempotent, deduplicated and scene-aware.

#### Instrumentation setup и trace interpretation
Warm launch measurement differs from cold launch measurement. You are not measuring dyld; you are measuring foreground activation, UI continuity and reconciliation cost.

Recommended instrumentation:
- `scenePhase` / lifecycle signposts for `.inactive -> .active` and `.background -> .active`;
- signposts around session restore/check, permission recheck, visible screen refresh and pending mutation sync;
- Time Profiler for main actor work during foreground activation;
- Hangs instrument for interaction stalls after app switcher return;
- MetricKit/Organizer trends for hangs, app responsiveness and crash-free foreground sessions;
- privacy-safe logs for activation reason, route intent presence, reconciliation result and error category.

Пример signpost для activation interval:

```swift
import os

private let lifecycleLog = OSLog(subsystem: "com.example.app", category: "Lifecycle")

@MainActor
final class ForegroundActivationMetrics {
    private var activationID: OSSignpostID?

    func activationStarted(reason: String) {
        let id = OSSignpostID(log: lifecycleLog)
        activationID = id
        os_signpost(.begin, log: lifecycleLog, name: "ForegroundActivation", signpostID: id, "%{public}@", reason)
    }

    func activationFinished(result: String) {
        guard let id = activationID else { return }
        os_signpost(.end, log: lifecycleLog, name: "ForegroundActivation", signpostID: id, "%{public}@", result)
        activationID = nil
    }
}
```

Interpretation rules:
- если previous UI visible быстро, но first scroll/tap зависает, это warm launch regression;
- если every activation запускает full refresh, ищи missing deduplication;
- если refresh race overwrites local pending mutation, это data correctness bug, не performance-only issue;
- если p95 warm activation плохой, сегментируй by scene recreation, session expiration, permission changes and data size;
- если app возвращается из system UI и теряет state, проблема в lifecycle ownership, а не в “пользователь свернул приложение”.

#### Hot-path риски и static red flags
Warm launch hot path часто скрыт в lifecycle handlers.

Red flags:
- `onChange(of: scenePhase)` запускает heavy refresh каждый раз при `.active`;
- foreground activation делает fetch-all database reload;
- screen `.task` перезапускает work при каждом появлении без deduplication;
- auth/session refresh блокирует весь UI instead of sensitive operations;
- notification/deep link routing directly mutates SwiftUI navigation before session/domain checks;
- permissions assumed stable после первоначального grant;
- foreground refresh overwrites local pending mutations;
- background result and foreground refresh write same domain state without version/vector/timestamp/conflict policy;
- timers/polling resume aggressively without Low Power Mode/thermal awareness;
- multiple scenes share one mutable navigation state;
- background task completion and manual foreground refresh write same state concurrently;
- in-memory cache treated as durable state after long suspension;
- `@MainActor` repository/service performs parsing, sorting, image decoding or DB work during activation;
- analytics logs “app opened” on every transient active transition without user-visible context.

Static review rule for each activation task: task должен иметь явное поведение для rapid double activation, scene recreation, session expiration, permission revocation и immediate backgrounding. Если ответ сводится к “ничего особенного не предусмотрено”, task не готов к production warm launch path.

#### Ownership model for warm activation
Warm launch needs explicit ownership, otherwise every feature adds its own `.active` observer.

Recommended responsibility split:

| Owner | Responsibility | Common anti-pattern |
| --- | --- | --- |
| `LifecycleCoordinator` | centralizes activation reason, deduplication, metrics | every screen observes `scenePhase` independently |
| `SessionController` | checks auth/lock/revocation without blocking non-sensitive shell | global spinner while token refresh waits |
| `PermissionStateStore` | re-reads permissions and publishes meaningful state changes | assuming permission grant is permanent |
| `RouteIntentCoordinator` | preserves and reconciles notification/deep-link intents | direct view navigation from push handler |
| `SyncScheduler` | coordinates foreground refresh, pending mutations and background results | duplicate sync from launch + screen + scene handler |
| Feature model | refreshes visible data if owned and still relevant | refresh all features on every activation |

Rule: feature-level refresh can be triggered by activation, but ownership must remain feature-specific and cancellable. Central lifecycle code should coordinate signals; it should not become a god object that knows every feature’s business rules.

Route intent ownership in multi-scene apps: intent должен иметь target policy. Возможные варианты: route to currently active scene, create/reuse scene by document/account/context, ask user to choose, or reject intent with safe explanation. Intent must be consumed or rejected exactly once; shared process-level storage не должен напрямую мутировать navigation path всех scenes.

Conflict rule: foreground refresh and background result must merge through domain policy, not last-writer-wins by accident. Minimum options: server version, local mutation version, vector/timestamp, idempotency key, conflict state or product-specific merge rule. If policy is unknown, refresh must not overwrite pending local user intent.

#### Optimization tradeoff-ы и regression guardrails
Warm launch optimization is mostly about **not doing unnecessary work at the exact moment the user returns**.

Tradeoffs:
- **Immediate stale UI vs blocking refresh:** showing stale local content with freshness indicator is often better than blank blocking spinner.
- **Session security vs continuity:** sensitive content may require lock/auth gate; non-sensitive shell can remain visible.
- **Deduplication vs missed refresh:** avoid duplicate work, but preserve explicit user refresh and important invalidation signals.
- **Cache reuse vs correctness:** in-memory cache improves speed, but must be invalidated on logout, permission revocation, account switch, migration or external data change.
- **Foreground sync vs battery/thermal:** refresh should respect Low Power Mode, thermal state, network constraints and user-visible priority.
- **Multi-scene consistency vs isolated scene state:** shared domain state must be consistent, but each scene needs its own navigation/selection lifecycle.

Guardrails:
- activation handlers are idempotent and scene-aware;
- refresh work is deduplicated by key/purpose, not by accidental boolean flags;
- pending local mutations are protected from foreground refresh overwrite;
- session/permission changes produce explicit UI states;
- long work is cancellable when app backgrounds again;
- route intents are persisted until consumed or rejected with user-safe explanation;
- metrics segment warm activation by reason and result;
- PR adding `scenePhase`, app delegate activation logic or root `.task` must state warm-launch impact.

#### Примеры before/after validation
**Пример 1: duplicated refresh on every activation**

Before:
```swift
.onChange(of: scenePhase) { _, phase in
    if phase == .active {
        Task {
            await viewModel.reloadEverything()
        }
    }
}
```

Проблема: каждый foreground transition запускает full reload. Несколько screens могут сделать то же самое одновременно, создавая network burst, database contention and UI invalidation.

After:
```swift
enum RefreshPurpose: Hashable {
    case foregroundVisibleFeed
    case manualUserRefresh
    case pendingMutationSync
}

actor RefreshDeduplicator {
    private var runningPurposes: Set<RefreshPurpose> = []

    func runOnce(
        purpose: RefreshPurpose,
        operation: @Sendable () async throws -> Void
    ) async rethrows {
        guard !runningPurposes.contains(purpose) else { return }
        runningPurposes.insert(purpose)
        defer { runningPurposes.remove(purpose) }
        try await operation()
    }
}
```

Validation:
- two rapid active transitions produce one refresh per typed purpose;
- manual pull-to-refresh still works and has separate priority;
- foreground refresh does not overwrite pending local mutations;
- logs show skipped duplicate reason;
- cancellation/result policy is documented by caller, because this helper only deduplicates execution and is not a universal sync engine.

**Пример 2: permission revoked while app was backgrounded**

Before: app assumes camera/photos/location permission still granted and crashes or shows broken UI when user changed Settings.

After: activation re-checks permission state, maps denied/restricted/limited into first-class UI state and disables only affected features.

Validation:
- revoke permission in Settings, return to app;
- previous screen remains stable;
- affected feature shows actionable localized state;
- no raw sensitive data is logged.

**Пример 3: push deep link while process is alive**

Before: push handler directly changes navigation path while app is inactive, then scene activation triggers another route, causing duplicate navigation.

After: push handler stores route intent; activation reconciles it once after session/domain validation.

Validation:
- tap push while app suspended;
- tap push while app inactive but process alive;
- expired session shows auth gate then continues route;
- invalid route produces safe message and consumes intent once.

#### Testing strategy
Warm launch testing must simulate interruption, not only app icon launch.

Minimum matrix:
- app switcher return after short background interval;
- return after long suspension;
- return after permission revoked in Settings;
- return after auth token/session expiration;
- return from system UI: photo picker, file picker, StoreKit, Sign in with Apple, camera;
- push/Universal Link/widget/App Intent while process alive;
- foreground while pending mutation exists;
- foreground after background task partially completed;
- multi-window iPadOS scene activation where relevant;
- Low Power Mode / constrained network for refresh behavior.

Automated tests should cover activation state machines, route intent preservation, refresh deduplication and pending mutation protection. Manual/device QA is needed for app switcher behavior, Settings permission changes, system UI returns, push/deep link flows and old-device responsiveness.

#### Interview/incident-review Q&A с ответами
1. **Почему warm launch может быть сложнее cold launch?**
   **Ответ:** при warm launch process state уже существует, но может быть stale. Нужно reconcile session, permissions, pending tasks, caches, scene state and route intents без потери UI continuity и без duplicate work.

2. **Что должно происходить первым при возвращении в foreground?**
   **Ответ:** безопасное восстановление visible local UI и interaction readiness. Refresh, sync and remote checks должны запускаться ограниченно и с поддержкой cancellation, не блокируя весь UI, если нет security/correctness причины.

3. **Почему нельзя просто запускать reload на каждый `scenePhase == .active`?**
   **Ответ:** `.active` может происходить часто и для разных scenes. Без deduplication это создаёт network bursts, DB contention, broad UI invalidation, race с pending mutations and battery cost.

4. **Как warm launch должен обрабатывать revoked permissions?**
   **Ответ:** permission state нужно re-read on activation for affected capabilities. UI должен иметь denied/restricted/limited states, не crash-иться, не показывать stale privileged UI и не логировать sensitive context.

5. **Как защититься от deep link duplication при warm launch?**
   **Ответ:** route intent нужно хранить отдельно от SwiftUI navigation path, reconcile once after session/domain validation, mark consumed или rejected, and make scene ownership explicit.

6. **Что проверять в incident review после жалоб “приложение зависает при возвращении”?**
   **Ответ:** activation signposts, main actor work, foreground refresh duplication, session refresh blocking, database reloads, permission checks, pending mutation races, scene recreation and old-device traces.

#### Чеклист production-readiness для warm launch
Warm launch не готов к production, пока:
- visible local UI восстанавливается быстро и безопасно;
- foreground refresh не блокирует first interaction без security/correctness причины;
- activation handlers idempotent, deduplicated and scene-aware;
- session expiration/revocation имеет explicit UI path, including redacted/locked state for sensitive screens;
- permission changes outside app handled;
- route intents from push/deep link/widget/App Intent preserved, target scene policy defined, consumed/rejected once;
- pending local mutations protected from refresh overwrite by version/conflict/merge policy;
- background task completion cannot race foreground manual refresh;
- multi-scene navigation/state ownership defined where relevant;
- long activation work cancellable if app backgrounds again;
- metrics/signposts cover activation reason, duration and result;
- release QA includes app switcher return, Settings permission change and system UI return scenarios.


### 2.3. Активация foreground
#### Назначение раздела
Foreground activation — это переход app/scene в состояние, где пользователь снова может видеть и взаимодействовать с UI. В отличие от `2.2`, где фокус был на пользовательском warm return path, этот раздел описывает **формальную lifecycle-семантику**: какие callbacks/signals приходят, как различаются application и scene lifecycle, почему `.active` не означает “можно запустить всё”, как проектировать idempotent activation handlers и как не смешивать lifecycle events с feature business logic.

Senior-level цель — правильно реагировать на activation без дублирования работы, UI races и stale assumptions. Staff-level цель — создать platform convention: где живут app-level observers, где scene-level ownership, какие actions разрешены на activation, какие запрещены, как это тестируется и как команды не превращают `scenePhase` в глобальную кнопку “reload everything”.

#### Scope и prerequisites
Этот раздел предполагает, что читатель уже понимает:
- cold launch как startup path (`2.1`);
- warm launch как user-perceived return path (`2.2`);
- базовую разницу между process, app, scene, task и data lifecycle (`1.1`).

Здесь рассматриваются:
- UIKit application lifecycle callbacks;
- `UIScene` / `UIWindowScene` lifecycle;
- SwiftUI `scenePhase`;
- foreground inactive vs foreground active;
- ordering and duplication risks;
- multi-scene implications;
- ownership rules for activation reactions;
- testing and incident review for activation bugs.

Здесь не раскрываются глубоко background execution, scene restoration, push routing, widgets/extensions или product-level warm-return reconciliation. Deep links, permission revalidation, pending mutations и duplicate refresh упоминаются только как примеры того, почему lifecycle signal должен иметь owner и boundary; подробный warm-return reconciliation остаётся в `2.2`.

#### Core theory и mental model
Foreground activation — это **signal**, а не business event. Он сообщает, что application или scene изменили lifecycle state. Он не говорит, что нужно перезагрузить все данные, показать alert, обновить все tokens, сбросить navigation или запустить sync без ограничений.

Ключевые различия:

| Концепция | Что означает | Что не гарантирует |
| --- | --- | --- |
| Process alive | app process существует в памяти | UI видим, scene active, state fresh |
| App active | приложение foreground and receiving events | каждая scene готова к feature routing |
| Scene foreground active | конкретная scene видима и интерактивна | другие scenes имеют тот же navigation/state |
| Scene foreground inactive | scene видима, но временно не принимает normal events | можно запускать heavy work |
| SwiftUI `scenePhase` | environment signal для scene/app lifecycle | точный global process lifecycle или single delivery |
| `onAppear` / `.task` | view lifecycle/rendering signal | app foreground activation semantics |

Senior mental model: **activation handler должен быть idempotent, дешёвым по ресурсам, scene-aware and intent-preserving**. Он может инициировать reconciliation, но не должен сам становиться местом feature orchestration без ownership.

#### Подкапотные детали
В UIKit era приложение часто имело один window и application-level callbacks казались достаточными. С `UIScene` app может иметь несколько scenes, каждая со своим lifecycle. На iPadOS несколько windows одного приложения могут быть active, inactive, backgrounded или discarded независимо. SwiftUI скрывает часть этой сложности, но не отменяет её.

Критичное правило для современных iOS apps: при scene-based lifecycle UI foreground/background semantics принадлежат `UISceneDelegate`, `UIWindowScene` и SwiftUI scene lifecycle. `UIApplicationDelegate` остаётся process/configuration entry point для launch configuration, push registration, background events, app-wide services and handoff points, но не должен быть единственным owner scene-specific foreground activation, navigation или visible UI refresh.

Важные lifecycle signals:
- `application(_:didFinishLaunchingWithOptions:)` — process/app launch setup, не foreground activation для каждой scene.
- `applicationDidBecomeActive(_:)` — app-level active signal; может быть слишком широким для scene-specific work.
- `applicationWillResignActive(_:)` — temporary interruption или переход из active.
- `applicationDidEnterBackground(_:)` — app moved to background; не guaranteed final cleanup point.
- `scene(_:willConnectTo:options:)` — scene created/connected; место для scene setup and connection options.
- `sceneWillEnterForeground(_:)` — scene moving from background to foreground.
- `sceneDidBecomeActive(_:)` — конкретная scene стала active.
- `sceneWillResignActive(_:)` — interruption или потеря active state.
- `sceneDidEnterBackground(_:)` — scene moved to background.
- SwiftUI `@Environment(\.scenePhase)` — high-level signal, удобный для UI reactions, но требует осторожности в multi-scene apps.

SwiftUI `scenePhase` — это удобная абстракция, а не замена `UISceneSession`, connection options, push/deep-link delivery, restoration activity или explicit routing store. Для routing и ownership она должна быть input signal, а не единственный source of truth.

SwiftUI `scenePhase` delivery не является ordering boundary относительно UIKit/UIScene callbacks. Если correctness зависит от порядка, введи явную state machine и traceable events, а не полагайся на порядок доставки environment update.

Ordering can vary by entry path. Cold launch with scene connection, warm return, push tap, Universal Link, handoff, system UI return and multi-window creation могут давать разные combinations of app and scene callbacks. Production code должен опираться на documented lifecycle meaning и собственную state machine, а не на наблюдённый порядок одного simulator run.

Примеры типовых последовательностей, которые нужно воспринимать как conceptual model, а не как exhaustive contract:

| Сценарий | Типовая последовательность signals | Design implication |
| --- | --- | --- |
| Cold launch with scene connection | app launch/configuration → scene connection → scene foreground → scene active | scene setup and route options должны жить на scene boundary |
| Warm return from background | scene will enter foreground → scene did become active → SwiftUI `scenePhase` becomes `.active` | refresh должен быть idempotent and deduplicated |
| Temporary interruption | active → inactive → active without background | не завершай session и не очищай state как при background/termination |
| Multi-scene activation | one scene active/inactive while another remains active or backgrounded | navigation/selection are scene-scoped; domain/session state shared carefully |

One-shot vs repeating semantics: activation signals repeat many times. Handlers must be repeat-safe. Route intent consumption, analytics session start, irreversible mutations and migration steps require separate once-policy keyed by intent/session/version, not by lifecycle callback delivery.

#### Foreground inactive vs active
`inactive` не является “почти active, можно запускать всё”. Это transitional state: system alert, Control Center, multitasking transition, incoming call, permission prompt, app switcher, scene transition. UI может быть visible, но normal event delivery ограничена.

Правила:
- Не стартуй expensive refresh только потому, что scene стала inactive.
- Не считай inactive user abandonment.
- Не очищай sensitive state on every inactive без product/security policy: можно получить flicker around permission prompt или system UI.
- Не отправляй analytics “session ended” на каждый short inactive transition.
- Используй active для interaction-ready work, но всё равно deduplicate and bound.

Для privacy-sensitive apps может быть policy: redact UI при `willResignActive` или entering app switcher. Это отдельное product/security requirement, а не generic rule для всех приложений.

Additional inactive rule: `inactive` может возникать без перехода в background и может повторяться кратко. Cleanup, persistence, logout, analytics session end и destructive security decisions нельзя строить только на `inactive`; нужна отдельная policy based on background transition, elapsed time, device lock, app lock, account risk или explicit user action.

#### Ownership и boundaries
Главная архитектурная ошибка — позволить каждому screen самостоятельно подписаться на foreground activation и запускать refresh. Это создаёт N независимых lifecycle interpretations.

Recommended ownership:

| Boundary | Ответственность | Примеры allowed work |
| --- | --- | --- |
| App-level lifecycle owner | process/app-wide events, metrics, global security policy | app lock, analytics session boundary, global capability refresh |
| Scene-level owner | scene connection, active/inactive/background, scene-specific route intents | scene route reconciliation, visible scene refresh signal |
| Session owner | auth/session/lock state | token validity check, lock gate state, credential revocation handling |
| Permission owner | permission re-read and state publication | location/photos/camera/notification state changes |
| Sync owner | deduplicated refresh/sync coordination | pending mutation sync, foreground refresh with conflict policy |
| Feature owner | visible feature data update | refresh currently visible domain slice only |

Rule: lifecycle layer emits **semantic signals**; feature layer decides whether work is relevant. Example: `foregroundBecameActive(sceneID:)` is acceptable. `reloadHomeFeedAndProfileAndNotifications()` inside app delegate is not.

Минимальное multi-scene rule: process-level domain/session state can be shared, but scene-level navigation, selection, presentation state and route intent handling must be isolated or explicitly targeted. If code cannot name the target `UISceneSession`/scene identity, it should not mutate scene navigation.

#### Production-правила и ловушки
Production rules:
- Activation handlers must be idempotent; repeated `.active` should not duplicate irreversible work.
- Activation handlers must be cheap on main actor: heavy work moves off-main and returns with narrow UI updates.
- Scene-specific work must know scene identity; app-level work must not mutate every scene’s navigation blindly.
- Permission/session state must be revalidated where product behavior depends on it.
- Pending deep links/notifications must survive auth/session transitions and be consumed/rejected once.
- Foreground refresh must not overwrite pending local mutations without merge/conflict policy.
- Analytics must distinguish user-visible foreground session from transient lifecycle noise.
- Lifecycle callbacks are not durable persistence guarantees; checkpoint user-critical state earlier.

Ловушки:
- **Reload storm:** every screen observes `.active` and calls reload.
- **Scene confusion:** one global navigation path used by multiple scenes.
- **Inactive overreaction:** app treats every interruption as logout/session end.
- **Permission stale state:** user changed Settings while app inactive, UI still assumes grant.
- **Routing race:** push/deep link route fires before session/domain ready.
- **Main actor jam:** activation handler performs DB fetch, sorting, image decode or JSON parsing.
- **Analytics inflation:** “app opened” event emitted for system prompt return, not real user session.

#### SwiftUI-specific guidance
SwiftUI makes lifecycle observation easy, which increases risk of overuse.

Acceptable uses of `scenePhase` in a view:
- notify a feature model that visible scene became active;
- pause/resume lightweight visible work;
- trigger a narrowly scoped refresh with deduplication;
- update privacy redaction state for a visible scene.

Suspicious uses:
- root view calls multiple repositories on every `.active`;
- child rows observe `scenePhase` independently;
- `.task` and `.onChange(scenePhase)` both start the same work;
- scenePhase handler mutates global navigation directly;
- handler starts unbounded detached tasks.

Safer pattern:

```swift
struct ArticleListScreen: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var model: ArticleListModel

    var body: some View {
        ArticleListContent(state: model.state) {
            model.refreshRequestedByUser()
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            model.sceneBecameActive()
        }
    }
}

@MainActor
@Observable
final class ArticleListModel {
    private let refreshCoordinator: RefreshCoordinator
    private var visibleRefreshTask: Task<Void, Never>?

    func sceneBecameActive() {
        visibleRefreshTask?.cancel()
        visibleRefreshTask = Task { [refreshCoordinator] in
            await refreshCoordinator.refreshVisibleArticlesIfNeeded(reason: .foregroundActivation)
        }
    }

    func refreshRequestedByUser() {
        visibleRefreshTask?.cancel()
        visibleRefreshTask = Task { [refreshCoordinator] in
            await refreshCoordinator.refreshVisibleArticles(reason: .explicitUserIntent)
        }
    }
}
```

Важный нюанс: this is a pattern, not a mandate. If activation work is app-wide, keep it out of a feature view. If work is scene-specific, do not put it in process-level singleton without scene identity.

#### Debug workflow для activation incidents
Минимальный workflow расследования:
1. Собрать sequence app/scene/SwiftUI lifecycle events with timestamps.
2. Добавить scene identity / `UISceneSession` / route intent ID where applicable.
3. Определить, какой owner запустил work: app-level, scene-level, session, permission, sync или feature.
4. Проверить repeat-safety: был ли signal delivered more than once и есть ли deduplication/once-policy.
5. Проверить cancellation: что произошло, если app ушла inactive/background during work.
6. Снять main actor trace, если user-visible freeze связан с activation.
7. Проверить data policy: pending mutations, conflict handling, permission/session state and route consumption.

#### Примеры, упражнения и Q&A с ответами
**Пример 1: app-level callback мутирует scene navigation**

Проблема: `applicationDidBecomeActive` checks pending deep link and directly updates global SwiftUI navigation path. On iPadOS two scenes exist; wrong scene receives route or both scenes mutate.

Correct target state: route intent is stored with target policy. Scene-level coordinator reconciles intent when the correct scene becomes active. If target scene is unknown, app creates/selects scene or asks user, depending on product policy.

Validation:
- two scenes open different documents;
- Universal Link targets a document already open in one scene;
- wrong scene is not mutated;
- intent consumed exactly once.

**Пример 2: foreground refresh перетирает local edit**

Проблема: user edited item offline, backgrounds app, returns. Foreground refresh fetches server state and replaces local model, losing edit.

Correct target state: pending mutation is source of local user intent. Refresh merges by version/conflict policy, preserves local edit, shows sync/conflict state if needed and never silently discards local work.

Validation:
- offline edit survives foreground refresh;
- duplicate refresh does not duplicate mutation;
- conflict produces explicit UI state;
- logs do not include raw sensitive payload.

**Пример 3: inactive transition causes unnecessary logout**

Проблема: app logs out user on every `willResignActive`, including Control Center, incoming call or permission prompt. User returns and loses context.

Correct target state: security policy distinguishes temporary inactive from background timeout, device lock, account risk or explicit logout. Sensitive UI may be redacted, but session is not destroyed without policy reason.

Validation:
- open Control Center and return;
- show permission prompt and return;
- lock device beyond configured timeout;
- verify redaction/session behavior matches product/security policy.

#### Review Q&A с ответами
1. **Почему foreground activation нельзя считать product event “пользователь открыл приложение”?**
   **Ответ:** activation может быть вызвана system UI return, scene transition, permission prompt, multitasking or short interruption. Product analytics should distinguish true user-visible session start from lifecycle noise.

2. **Чем app-level active отличается от scene-level active?**
   **Ответ:** app-level active describes application foreground event, while scene-level active describes a specific scene becoming interactive. In multi-scene apps, scene-specific navigation/refresh must not be driven blindly by app-level callbacks.

3. **Почему `scenePhase == .active` не должен автоматически запускать full reload?**
   **Ответ:** `.active` may happen repeatedly and for different scenes. Full reload creates network bursts, DB contention, UI invalidation and data races with local pending mutations.

4. **Как правильно обрабатывать permission changes при activation?**
   **Ответ:** affected permission owners re-read system state, publish semantic domain state, and UI maps denied/restricted/limited/unavailable into explicit user-facing states. Do not assume previous grant is permanent.

5. **Когда нужно redacted UI при foreground/inactive transitions?**
   **Ответ:** when product/security policy says content is sensitive: banking, health, private documents, enterprise data. Redaction should protect content without destroying session or navigation unless policy requires lock/logout.

6. **Что должно быть в incident review, если activation вызывает зависание?**
   **Ответ:** collect app/scene lifecycle sequence, activation reason, main actor trace, duplicate refresh evidence, session/permission checks, route intent handling, pending mutation state, device/OS/data size and recent changes in lifecycle handlers.

#### Чеклист production-readiness для foreground activation
Foreground activation handling не готово к production, пока:
- app-level and scene-level responsibilities separated;
- activation handlers are idempotent and cheap;
- `.inactive` and `.active` have distinct policies;
- multi-scene routing/state ownership defined where relevant;
- session/security policy handles lock/redaction/logout separately;
- permissions can be revalidated after Settings/system UI changes;
- deep links/notifications are preserved through activation and consumed/rejected once;
- foreground refresh is deduplicated and conflict-safe;
- lifecycle events are observed with privacy-safe metrics;
- feature views do not each implement independent global lifecycle policy;
- tests cover rapid active/inactive transitions and system UI returns;
- incident playbook includes lifecycle sequence reconstruction.


### 2.4. Переход в background
#### Назначение раздела
Переход в background — это момент, когда приложение теряет foreground priority и должно быстро привести state, tasks, persistence, privacy-состояние и использование ресурсов в безопасное состояние перед suspension или дальнейшей system-managed background execution. Это не “последний шанс сделать всё” и не универсальное окно для sync. Это lifecycle boundary, где iOS ожидает, что app прекратит user-visible work, сохранит минимально необходимый durable state, освободит ненужные ресурсы и не будет бороться с системой за CPU, battery и attention.

Senior-level ошибка — использовать background transition как dumping ground: “когда app уходит, синхронизируем всё, пишем всё на диск, обновляем всё, отправляем analytics”. Staff-level mental model: **background transition is a checkpoint and shedding point, not a hidden execution budget**.

#### Scope и prerequisites
Этот раздел раскрывает именно переход foreground → background:
- `sceneWillResignActive` / `sceneDidEnterBackground`;
- `applicationWillResignActive` / `applicationDidEnterBackground` где применимо;
- checkpointing user-visible and durable state;
- cancellation/shedding of foreground-only work;
- privacy redaction / snapshot concerns;
- short background task completion windows;
- handoff to approved background mechanisms.

Не раскрывается глубоко:
- suspension and termination mechanics — это `2.5`;
- scene lifecycle and restoration — это `2.6` и `2.8`;
- multi-window ownership — это `2.7`;
- detailed `BackgroundTasks`, background modes, push, widgets and extensions — они должны иметь отдельные capability sections.

Практическая формула: **on background transition save what must survive, stop what no longer has foreground value, mark what must continue through an approved mechanism, and leave enough evidence to recover on next launch**.

#### Core theory и mental model
Background transition has three responsibilities:

1. **Durability:** сохранить smallest durable facts, которые пользователь ожидает увидеть после relaunch.
2. **Resource shedding:** остановить foreground-only work: animations, camera preview, polling, visible refresh, expensive rendering, speculative prefetch.
3. **Coordination:** определить, какая работа должна завершиться сейчас, какая отменяется, какая переносится в sanctioned background path, а какая остаётся pending до следующего foreground.

Ключевое различие:
- **Checkpoint:** быстрое сохранение локального state/progress, чтобы пережить suspension/process death.
- **Sync:** network/server reconciliation, который может быть delayed, interrupted, denied или retried later.
- **Cleanup:** освобождение ресурсов, cache trimming, temporary state boundary.
- **Background execution:** отдельная capability/policy, а не automatic right после `didEnterBackground`.

Senior rule: if user-visible state matters, persist intent/progress before relying on background time. If work is only nice-to-have, cancel/defer it. If work must continue, it needs declared reason, expiration handling and recovery plan.

#### Подкапотные детали
Когда app/scene уходит в background, система может вскоре suspend процесс. Во время suspension app code не выполняется. Перед suspension может быть короткое время для завершения ограниченной работы, но оно не является reliable product deadline. Если app просит additional background time через `beginBackgroundTask`, она получает bounded opportunity with expiration handler, not daemon privileges. Такой task должен быть завершён через `endBackgroundTask` both on normal completion and on expiration; иначе app тратит background budget некорректно и рискует termination.

Lifecycle signals differ by architecture:
- scene-based apps получают scene-level background callbacks per scene;
- app-level callbacks may still exist for process-wide events;
- SwiftUI `scenePhase == .background` is a high-level signal, not a persistence guarantee;
- multi-scene apps can have one scene backgrounded while another remains foreground active;
- system UI interruptions may pass through inactive without full background.

Important mechanics:
- **App snapshot:** iOS may capture UI for app switcher; sensitive screens may need redaction before background/inactive based on policy.
- **File protection:** protected files may become unavailable when device locks; critical writes should consider protection class and timing.
  Практическое правило: write critical checkpoints before lock/background where possible, handle protected-data-unavailable on next launch/foreground, and never treat file-protection write failure as user intent to delete data.
- **Task cancellation:** structured concurrency tasks do not automatically cancel because app backgrounds; owner must define policy.
- **URLSession background configuration:** background transfers are separate from foreground tasks and require explicit design.
- **BGTaskScheduler:** scheduling a future task is not the same as running work immediately.
- **Extensions/widgets:** must not rely on app process memory; shared state needs durable app group ownership.

#### Background transition decision table
Каждая активная работа должна быть классифицирована при уходе в background.

| Work type | Default decision | Production condition |
| --- | --- | --- |
| UI animation/rendering | stop | resume if scene becomes active again |
| Visible screen refresh | cancel/defer | keep local content and freshness state |
| User draft/edit | checkpoint | persist smallest durable edit state |
| Pending mutation | persist queue | retry later with idempotency/conflict policy |
| Analytics/log upload | batch/defer | do not block background transition |
| Media recording/playback | continue only with declared mode/user value | handle interruption and privacy indicators |
| Location/Bluetooth | continue only with entitlement/background mode/product reason | minimize energy and provide user value |
| Large migration/indexing | defer or BGProcessing if appropriate | checkpoint progress and expiration handler |
| Temporary import/export | finish only if bounded and user-critical | otherwise persist intent and recover later |

Rule: “finish everything before suspension” is not a strategy. Correct strategy is “make every interrupted point recoverable”.

#### Ownership и boundaries
Background transition policy must be centralized enough to be consistent, but not so centralized that it owns every feature.

Recommended boundaries:

| Owner | Responsibility | Not responsible for |
| --- | --- | --- |
| App lifecycle owner | process-wide background signal, metrics, global policies | feature-specific save logic |
| Scene owner | scene-specific navigation/selection checkpoint | global sync decisions |
| Feature owner | save visible editing/progress state | scheduling all app background work |
| Persistence owner | durable writes, transactions, migration checkpoints | deciding product semantics of drafts/conflicts |
| Sync owner | pending mutation queue, retry/backoff/idempotency | direct UI navigation |
| Privacy/security owner | redaction, lock policy, sensitive snapshot handling | generic performance cleanup |
| Background capability owner | BGTask/background mode registration and expiration handling | pretending background time is guaranteed |

Semantic signal example: lifecycle layer emits `sceneEnteredBackground(sceneID:)`. Feature layer decides whether it has visible draft, media session, pending upload or nothing to save.

Multi-scene aggregation rule: process-wide cleanup, cache trimming, session teardown or sync throttling should depend on aggregate scene state, not one scene callback. If another scene remains foreground active, one backgrounded scene must not trigger global shutdown.

#### Production-правила и ловушки
Production rules:
- Persist user intent before attempting best-effort server sync.
- Keep background transition work short, bounded and observable.
- Do not start new broad refresh just because app is entering background.
- Cancel foreground-only tasks explicitly.
- Use expiration handlers for any requested background time.
- Make writes idempotent or checkpointed; app may be suspended or killed mid-write.
- Redact sensitive UI no later than inactive/background transition if product/security policy requires it, and define restore policy on foreground/auth.
- Segment metrics by background reason and result: checkpoint saved, cancelled, scheduled, expired.
- Track checkpoint duration, expired background task count, pending queue count and whether sensitive redaction was applied/missed.
- Never rely on `applicationWillTerminate` as normal cleanup path.
- In multi-scene apps, backgrounding one scene must not destroy global state needed by active scenes.

Ловушки:
- **Background sync fantasy:** команда обещает “sync on close”, но iOS may suspend before completion.
- **Checkpoint too late:** draft saved only during `didEnterBackground`, but crash/jetsam loses data before that.
- **Main actor file writes:** synchronous persistence blocks transition and causes hangs.
- **No expiration path:** background task starts but expiration handler only logs.
- **Privacy snapshot leak:** app switcher shows sensitive data.
- **Scene overreach:** scene background clears shared session while another scene remains active.
- **Analytics blocking:** app waits for event upload during background transition.

#### `beginBackgroundTask` operational pattern
`beginBackgroundTask` подходит только для bounded completion work. It does not make the app a daemon and does not guarantee network success.

```swift
@MainActor
final class BackgroundCompletionRunner {
    private var taskID: UIBackgroundTaskIdentifier = .invalid

    func run(application: UIApplication, operation: @escaping () async -> Void) {
        taskID = application.beginBackgroundTask(withName: "FinishCriticalCheckpoint") { [weak self, weak application] in
            Task { @MainActor in
                guard let self, let application else { return }
                // Expiration path must cancel/checkpoint through owned state in production.
                self.finish(application: application)
            }
        }

        Task { [weak self, weak application] in
            await operation()

            await MainActor.run {
                guard let self, let application else { return }
                self.finish(application: application)
            }
        }
    }

    private func finish(application: UIApplication) {
        guard taskID != .invalid else { return }
        application.endBackgroundTask(taskID)
        taskID = .invalid
    }
}
```

Production version needs cancellation token, idempotent operation, timeout, privacy-safe diagnostics and recovery on next launch. The essential invariant is non-negotiable: every started background task must be ended on completion and expiration.

#### Swift Concurrency и cancellation
Background transition should interact deliberately with tasks.

Rules:
- Screen-owned tasks should cancel when screen/scene is no longer visible unless they protect data integrity.
- Data-integrity tasks should persist progress and continue only if allowed by lifecycle policy.
- Detached tasks require strict justification; otherwise ownership and cancellation become unclear.
- Main actor should only update state/checkpoint small values; heavy serialization, compression and DB work goes off-main.
- Background expiration should cancel or checkpoint work, not simply log timeout.

Example:

```swift
@MainActor
final class DraftEditorModel {
    private let draftStore: DraftStore
    private var autosaveTask: Task<Void, Never>?
    private var draft: Draft

    init(draft: Draft, draftStore: DraftStore) {
        self.draft = draft
        self.draftStore = draftStore
    }

    func sceneEnteredBackground() {
        autosaveTask?.cancel()
        let snapshot = draft

        autosaveTask = Task { [draftStore, snapshot] in
            do {
                try await draftStore.saveCheckpoint(snapshot)
            } catch {
                // Production path: record privacy-safe diagnostic and keep local in-memory state.
                // Recovery policy must be owned by the feature/persistence layer.
            }
        }
    }
}
```

Important caveat: this example shows ownership shape, not a guarantee that async work finishes before suspension. User-critical writes should already be durable at mutation boundaries or before risky transitions. A final async save during background transition is opportunistic safety net, not the primary durability mechanism.

#### Примеры, упражнения и Q&A с ответами
**Пример 1: “sync on close” loses user changes**

Проблема: user changes favorite, app backgrounds, app tries network sync in `didEnterBackground`. System suspends before response; on next launch UI assumes server is source of truth and loses local intent.

Целевое состояние: favorite mutation is persisted locally with idempotency key before network attempt. Background sync is best-effort. Next launch resumes pending queue and reconciles server response.

Проверка:
- kill app after local mutation before network acknowledgement;
- relaunch shows local intent pending/synced state;
- duplicate delivery does not duplicate mutation;
- conflict policy is explicit.

**Пример 2: sensitive data visible in app switcher**

Проблема: banking/health/private document screen remains visible in app snapshot after user backgrounds app.

Целевое состояние: security policy defines when to redact. App/scene applies redaction before snapshot timing where possible, restores content after auth/foreground policy, and does not destroy navigation unnecessarily.

Проверка:
- background app from sensitive screen;
- inspect app switcher snapshot;
- return within and beyond lock timeout;
- verify VoiceOver/accessibility state does not announce hidden sensitive content.

**Пример 3: scene background clears shared state**

Проблема: on iPadOS one scene enters background and clears selected account/session/global cache; another scene still active breaks.

Целевое состояние: scene background only checkpoints scene-specific navigation/selection. Process-level session/cache remains while any scene or policy still needs it.

Проверка:
- open two windows with different documents;
- background one scene;
- active scene remains usable;
- returning scene restores its own state without overwriting the other.

#### Review Q&A с ответами
1. **Почему background transition нельзя считать надёжным временем для sync?**
   **Ответ:** система может быстро suspend процесс, background time ограничен and policy-controlled, network may be unavailable, and expiration can interrupt work. Correct path persists local intent and retries through approved mechanisms.

2. **Что обязательно нужно делать при уходе в background?**
   **Ответ:** checkpoint user-critical local state, cancel or pause foreground-only work, apply privacy redaction if required, persist pending operations and leave recovery evidence. Broad refresh/sync is not mandatory and often harmful.

3. **Чем checkpoint отличается от sync?**
   **Ответ:** checkpoint сохраняет локальный durable fact или progress, чтобы пережить interruption. Sync пытается согласовать state с server and may be delayed, retried or conflict-prone. Checkpoint is correctness; sync is reconciliation.

4. **Как использовать `beginBackgroundTask` безопасно?**
   **Ответ:** only for bounded completion work with clear expiration handler. The handler must cancel/checkpoint/recover, not only log. It must not turn feature logic into assumed long-running daemon work.

5. **Почему `scenePhase == .background` не должен делать всю persistence?**
   **Ответ:** signal может прийти поздно, не прийти для crash/jetsam, быть scene-specific and repeated. User-critical persistence should happen at mutation boundaries and use background transition only as additional checkpoint opportunity.

6. **Что проверять в incident review после потери данных при уходе из app?**
   **Ответ:** where user intent became durable, whether sync was treated as durability, lifecycle sequence, write atomicity, pending queue state, background expiration, app kill timing and next-launch recovery path.

#### Чеклист production-readiness для background transition
Background transition handling не готово к production, пока:
- user-critical state is persisted before relying on background time;
- foreground-only tasks are cancelled or paused;
- pending mutations are durable and idempotent;
- background work has trigger, deadline, cancellation, retry and user-visible effect;
- expiration handlers have real recovery behavior;
- sensitive snapshot/redaction policy is defined where needed;
- analytics/log upload does not block transition;
- multi-scene background does not corrupt active scene state;
- file writes are atomic/checkpointed where correctness matters;
- metrics show checkpoint/scheduled/cancelled/expired outcomes;
- next launch can recover from partial background work;
- QA covers backgrounding during edit, sync, import/export and sensitive screens.


### 2.5. Приостановка и завершение
#### Назначение раздела
Приостановка и завершение процесса — это граница, где iOS окончательно напоминает: приложение не владеет своим lifetime. После background transition процесс может быть frozen, позже resumed, killed by jetsam, terminated by user/system, replaced after update or restarted after crash. Production app должна быть correct across these outcomes без надежды на финальный callback.

Senior-level ошибка — считать suspension “паузой, после которой всё продолжится как было”, а termination — “редким edge case”. Staff-level mental model: **process death is a normal recovery scenario; suspension means no code runs; termination is often non-cooperative**.

#### Scope и prerequisites
Этот раздел продолжает `2.4`: background transition уже произошёл или происходит. Здесь фокус:
- что означает suspension;
- почему timers/tasks/network callbacks не продолжают выполняться во время suspension;
- какие виды termination существуют;
- почему `applicationWillTerminate` is not a durability mechanism;
- как проектировать recovery after jetsam/crash/force quit/update;
- как memory pressure and cache policy влияют на process lifetime;
- какие diagnostics нужны для расследования process death.

Не раскрывается глубоко scene restoration (`2.8`), detailed crash reporting, memory profiling, BackgroundTasks или release operations. Они связаны, но здесь рассматриваются только как факторы корректности process lifetime.

#### Core theory и mental model
Состояния процесса нужно отделять от UI state:

| State | Что означает | Инженерное следствие |
| --- | --- | --- |
| Foreground active | process выполняется, UI interactive | user-visible work has priority, but must stay responsive |
| Background running | process still executing with limited eligibility | finish/checkpoint bounded work; respect expiration |
| Suspended | process frozen in memory; app code does not run | timers/tasks do not progress; only durable state matters |
| Terminated | process no longer exists | next launch must recover from persisted facts |
| Jetsam killed | process killed by memory pressure | no normal Swift error path; investigate memory diagnostics |
| Crashed | process ended due to fault | crash recovery and data integrity required |
| Force quit | user explicitly removed app | treat as user intent; background behavior may be affected |

Key rule: in-memory state is only a cache/coordination convenience. If state должно пережить suspension + termination, it needs persistence, restoration, pending operation queue or explicit rebuild path.

#### Подкапотные детали
Suspension freezes execution. `Timer`, `Task.sleep`, async tasks, Combine pipelines, operation queues and in-process polling do not keep making progress just because their Swift objects exist. When the suspended process resumes, time has passed, network/auth/permissions/data may have changed, and stale continuations may resume into a different product context. После termination/relaunch in-memory continuations do not continue; recovery happens only from durable state, journal, pending queue or rebuilt domain state.

Termination is not always cooperative:
- **Jetsam:** kernel/system kills app under memory pressure. No Swift exception, no guaranteed cleanup callback.
- **Crash:** app faults; crash reporter may capture stack, but durability must already exist.
- **Watchdog termination:** app blocks launch/foreground/background deadlines or main thread badly enough.
- **User force quit:** user intent may suppress or alter some background launches until user opens app again.
- **System update/reboot:** process disappears; next start is cold launch with old assumptions invalidated.
- **App update:** binary and schema may change; recovery must handle migration.

Update rule: app update is a cold launch with new binary/schema. Recovery and migration must be idempotent, restart-safe and independent from any pre-update callback. If update happens after interrupted work, the new version must understand old pending records or migrate them safely.

`applicationWillTerminate(_:)` is not a reliable production hook for saving user data. It may be called in some controlled paths, but design must assume it will not be called before jetsam, crash, suspension or many real-world terminations.

#### Diagnostics для process death
Investigation must distinguish symptoms:

| Termination type | Useful signals | Typical evidence |
| --- | --- | --- |
| Crash | crash reports, stack traces, exception type | reproducible fault, assertion, fatal error |
| Jetsam / memory termination | Organizer metrics, MetricKit, device logs, memory footprint/peak | no Swift exception, high resident/dirty memory, media/cache spike |
| Watchdog | launch/foreground/background deadline symptoms, main-thread stall traces | app killed while blocking lifecycle deadline |
| Force quit | user action context, absence of expected background continuation | product expectation conflicts with user intent |
| Update/reboot | version/build transition, migration logs, pending journal state | cold launch recovery with new binary/schema |

Do not collapse all process deaths into “crash”. Different termination classes require different fixes: memory reduction, launch path deferral, main-thread unblocking, recovery journal, migration repair or product requirement correction.

#### Memory pressure, jetsam и cache policy
Jetsam risk is process-lifetime risk, not only memory optimization concern.

Memory-related rules:
- use bounded caches with eviction and memory pressure handling;
- release decoded images, video frames, PDF pages, thumbnails and media buffers when no longer visible;
- do not keep full-resolution media across repeated rows or inactive scenes;
- separate source-of-truth data from regenerable cache;
- treat temporary memory peaks during parsing/decoding/migration as jetsam risks;
- observe memory warnings/pressure as action signals, not logging trivia;
- test old devices and large data states, not only latest simulator.

Recovery rule: if process was killed by memory pressure, next launch should not repeat the exact same eager allocation path. Otherwise app can enter a jetsam loop: launch → load too much → killed → relaunch → killed.

#### Durability model
Correct durability starts before background/suspension. The app should know which facts должно пережить process death.

| Data / state | Durability expectation | Correct mechanism |
| --- | --- | --- |
| User draft/edit | должно пережить relaunch if product promises it | incremental local checkpoint |
| Pending mutation | должно пережить until server reconciliation | durable queue with idempotency key |
| Navigation intent | should survive auth/session transition or relaunch if user action requires | route intent store with expiry/validation |
| UI selection/tab | may be restored if useful | scene/session restoration state |
| Cached feed/content | can be stale but useful | bounded cache with freshness metadata |
| Decoded media/thumbnail | regenerable | memory/disk cache with eviction |
| Analytics event | best effort unless compliance-critical | batched queue, not launch/background blocker |
| Temporary import/export | depends on user expectation | explicit ownership, retention and cleanup policy |

Staff-level review rule: every important state must be classified as source of truth, pending user intent, derived cache, UI convenience or diagnostic artifact. Each category has different persistence, privacy and cleanup rules.

Staff-level ownership matrix:

| Category | Owner | Review rule |
| --- | --- | --- |
| Durable source of truth | persistence/domain owner | schema, migration, backup/file protection and corruption recovery defined |
| Pending user intent | sync/feature owner | idempotency, retry, conflict and user-visible pending state defined |
| Recoverable operation | operation owner | journal entry, resume/cancel policy and expiry defined |
| Regenerable cache | cache/media owner | memory/disk bounds, eviction and rebuild path defined |
| Diagnostics artifact | observability owner | privacy redaction, retention and incident usefulness defined |

#### Recovery after process death
Recovery must be explicit and testable.

Recovery flow:
1. Detect launch context: normal launch, after crash indicator, after update, large local data, pending operations, last known session state.
2. Load minimal durable state needed for safe shell.
3. Reconcile pending operations without duplicate irreversible effects.
4. Validate auth/session/permission state.
5. Restore scene/navigation only if still valid.
6. Rebuild caches lazily; do not eagerly recreate previous memory pressure.
7. Surface user-safe recovery UI: pending sync, conflict, draft restored, previous operation incomplete.
8. Emit privacy-safe diagnostics for recovery path.

Do not hide recovery behind a generic spinner. If user intent survived but server sync is pending, say so through UI state. If previous operation failed mid-way, make retry/cancel/resume policy explicit.

#### Production-правила и ловушки
Production rules:
- Do not rely on termination callbacks for critical persistence.
- Persist user intent at mutation boundary, not only on background/termination.
- Make pending operations idempotent and resumable.
- Treat suspension as no-code-execution; do not design around in-process timers.
- Make async continuations validate current ownership/session/scene before applying results.
- Bound caches and release media resources before memory pressure becomes jetsam.
- Handle app update/migration as recovery path, not only release paperwork.
- Segment diagnostics by crash, jetsam/memory termination, watchdog, user force quit and normal relaunch where possible.
- Do not promise background behavior after force quit; product requirements should assume user launch may be required to resume.

Ловушки:
- **Final callback fantasy:** saving everything in `applicationWillTerminate`.
- **Timer illusion:** assuming timer continues while suspended.
- **Stale continuation:** async task resumes after process/scene/session context changed.
- **Cache as source of truth:** only in-memory cache contains user-visible state.
- **Jetsam loop:** next launch eagerly reloads the same huge media/data set.
- **Force-quit confusion:** product expects background work after user explicitly killed app.
- **Crash-only diagnostics:** team sees no Swift crash and misses memory termination.

#### Practical recovery journal
Для high-value operations полезен lightweight recovery journal: durable breadcrumbs that describe in-flight user intent, not full logs.

Example:

```swift
struct RecoveryJournalEntry: Codable, Equatable {
    enum Kind: String, Codable {
        case draftCheckpoint
        case pendingMutation
        case importInProgress
        case migrationStep
    }

    let id: UUID
    let kind: Kind
    let createdAt: Date
    let operationKey: String
    let safeUserVisibleSummary: String
}

actor RecoveryJournal {
    private let store: RecoveryJournalStore

    func record(_ entry: RecoveryJournalEntry) async throws {
        try await store.upsert(entry)
    }

    func complete(id: UUID) async throws {
        try await store.remove(id: id)
    }

    func entriesForNextLaunch() async throws -> [RecoveryJournalEntry] {
        try await store.loadPendingEntries()
    }
}
```

Rules:
- journal must not contain raw PII, tokens or full payloads;
- entries need expiry/cleanup policy;
- completion must be idempotent;
- next launch must know how to resume, retry, cancel or explain each entry.

#### Примеры, упражнения и Q&A с ответами
**Пример 1: draft exists only in memory**

Проблема: user writes long note, app backgrounds, process is jetsam killed. Next launch loses note because draft lived only in `@State`.

Целевое состояние: draft checkpoints at edit boundary or debounce interval, not only on background. Next launch restores draft or explains recovery state. Sensitive content uses appropriate file protection and privacy policy.

Проверка:
- type draft;
- background app;
- simulate kill/relaunch;
- verify draft restored and no sensitive content logged.

**Пример 2: suspended timer drives product logic**

Проблема: countdown, upload retry or polling loop depends on in-process timer while app suspended. User returns later; UI shows impossible state.

Целевое состояние: store absolute deadlines/timestamps and recompute on foreground/launch. Retry uses scheduler/pending queue, not suspended timer illusion.

Проверка:
- start countdown/retry;
- background for longer than interval;
- return or relaunch;
- verify state derived from wall-clock/domain truth, not missed timer ticks.

**Пример 3: jetsam loop after media-heavy launch**

Проблема: app restores previous gallery and eagerly decodes full-resolution images. Old device gets jetsam killed repeatedly.

Целевое состояние: restore lightweight gallery shell, downsample visible images only, bound cache, lazy-load thumbnails and record memory termination diagnostics.

Проверка:
- large gallery on oldest supported device;
- relaunch after memory termination;
- verify app does not eagerly decode all assets;
- monitor memory footprint and cache eviction.

#### Review Q&A с ответами
1. **Почему `applicationWillTerminate` нельзя использовать как основной save hook?**
   **Ответ:** many real terminations are non-cooperative: jetsam, crash, watchdog, suspension followed by kill. Critical state must be durable before termination, ideally at mutation/checkpoint boundaries.

2. **Что реально происходит во время suspension?**
   **Ответ:** process remains in memory but code is frozen. Timers, tasks and callbacks do not progress. When app resumes, elapsed time and external state must be reconciled explicitly.

3. **Чем jetsam отличается от crash для расследования?**
   **Ответ:** jetsam is memory-pressure termination, often without Swift exception stack. Нужно смотреть memory reports, device logs, Organizer metrics, memory footprint and allocation peaks, not only crash stack traces.

4. **Как защититься от stale async continuation после resume/activation?**
   **Ответ:** task result must validate current owner, session, scene identity, request generation and cancellation state before applying changes. After cold relaunch there is no old in-memory continuation; durable operations resume only through journal/pending queue and should be idempotent and versioned.

5. **Что должно переживать process death?**
   **Ответ:** user intent, user-created content, pending mutations, required recovery breadcrumbs, and product-promised restoration state. Regenerable caches and decoded media usually should not be treated as durable truth.

6. **Что проверять после жалобы “приложение иногда открывается пустым после возврата”?**
   **Ответ:** whether process was suspended/killed, whether state was only in memory, launch recovery path, scene restoration, pending operations, cache eviction, memory termination evidence and stale auth/permission state.

7. **Почему next launch после jetsam должен быть cheaper/lazier than previous launch?**
   **Ответ:** если relaunch eagerly recreates the same memory-heavy state that caused jetsam, app can enter a kill loop. Recovery should load lightweight shell, rebuild caches lazily, downsample visible media only and avoid repeating previous peak allocation.

#### Чеклист production-readiness для suspension/termination
Process lifetime handling не готово к production, пока:
- critical user state is persisted before termination callbacks would be needed;
- in-memory state is classified as cache/coordination, not durability;
- pending operations are durable, idempotent and resumable;
- timers use absolute time/domain state, not suspended ticks;
- async results validate current ownership before applying state;
- cache and media memory are bounded and evictable;
- jetsam diagnostics are distinguishable from crash diagnostics;
- next launch has explicit recovery path for pending journal entries;
- app update/migration path handles interrupted prior work;
- force quit assumptions are product-reviewed;
- tests cover kill/relaunch during edit, sync, import, migration and media-heavy flows.


### 2.6. Жизненный цикл scene
#### Назначение раздела
Scene lifecycle — это модель владения видимой UI-сессией в iOS/iPadOS. После появления `UIScene` приложение перестало быть “один process = один window = один navigation state”. Один app process может иметь несколько scene sessions, каждая может подключаться, становиться foreground active/inactive, уходить в background, disconnect-иться и позже восстанавливаться. Production iOS architecture должна отличать app-wide state от scene-scoped state.

Senior-level ошибка — хранить navigation, selection, draft UI state и pending route в глобальном singleton, потому что “сейчас у нас один экран”. Staff-level mental model: **scene is a UI ownership boundary**. Scene owns presentation/navigation/selection context; app/domain layer owns shared durable data and session policy.

#### Scope и prerequisites
Этот раздел раскрывает:
- что такое `UISceneSession`, `UIWindowScene`, подключение и отключение scene;
- как scene lifecycle отличается от app/process lifecycle;
- какие state categories должны быть scene-scoped;
- как SwiftUI `WindowGroup`, `Scene`, `scenePhase`, `@SceneStorage` relate to UIKit scenes;
- как маршрутизация, восстановление и external intents взаимодействуют со scenes;
- какие production bugs возникают из-за неправильного scene ownership.

Не раскрывается подробно:
- multi-window product strategy, concurrent windows, conflict UX and document collaboration — это `2.7`;
- full state restoration pipeline, encoding/decoding, versioning, migration and restoration tests — это `2.8`;
- foreground activation semantics — это `2.3`;
- suspension/termination — это `2.5`.

Практическая формула: **если state описывает конкретное окно/scene, его owner должен быть scene-scoped; если state описывает domain/session/source of truth, он может быть process-wide или durable**.

#### Core theory и mental model
Scene lifecycle separates three layers:

| Layer | Примеры | Owner |
| --- | --- | --- |
| Process/app | dependency graph, logging, app-wide session policy, push registration | app composition root / app services |
| Domain/data | account, documents, sync queues, persisted content, permissions | domain/persistence/sync owners |
| Scene/UI session | navigation stack, selected tab, focused document, modal presentation, transient editing UI | scene coordinator / scene model |

Scene is not just “a window object”. It is a lifecycle and ownership boundary for visible interaction context. A scene can be disconnected while process lives. A new scene can be created for another document, activity or external display. A scene can be backgrounded while another remains active. Even if product currently supports one visible window, code should avoid preventable coupling that would break scene semantics later.

Core rule: **app-level state can feed scenes; scene state must not accidentally become global state**.

#### Подкапотные детали
Key UIKit concepts:
- `UISceneSession` represents a system record of a scene session that may outlive a concrete `UIScene`/`UIWindowScene` instance. App configures/receives sessions through scene configuration; it does not directly “own a window forever”.
- `UIWindowScene` represents a concrete window scene used for UI.
- `UISceneConfiguration` tells the system how to create a scene for a role.
- `connectionOptions` can carry URL contexts, user activities, shortcut items and notification response context. It is one-shot input at scene connection, not a long-lived routing store; normalize required intents and hand them to scene coordinator.
- `stateRestorationActivity(for:)` can provide scene-specific restoration information.
- scene delegate callbacks describe scene connection, foreground/background and disconnection.
- `application(_:didDiscardSceneSessions:)` tells the app that the system discarded scene sessions; use it to clean related restoration records that no longer have a system-owned session.

Key SwiftUI concepts:
- `WindowGroup` can create multiple windows/scenes for the same app role, even though code has one declarative entry point. If a root model owns navigation/presentation, create it on the scene boundary, not as accidental app-global singleton.
- `@Environment(\.scenePhase)` reports high-level lifecycle phase but is not a routing store.
- `@SceneStorage` stores small scene-specific UI state, not domain data.
- `@State` and view-local state are convenient but not durable scene restoration by default.
- SwiftUI app lifecycle still maps to platform scene lifecycle; hiding boilerplate does not remove ownership requirements.

Important distinction:
- **Scene disconnection** does not necessarily mean process death.
- **Scene background** does not necessarily mean all app work should stop.
- **Process termination** removes all scenes from memory, but restoration may recreate scene sessions from durable/restoration data.
- **Scene identity** should be explicit when routing, restoring, logging or syncing scene-related UI state.

Scene/session `persistentIdentifier` is useful for diagnostics and restoration bookkeeping, but it should not become permanent domain identity. Domain identity belongs to documents, accounts, entities or routes, not to a system scene session ID.

#### Scene-scoped state taxonomy
Use this taxonomy during design review:

| State | Scene scope | Reason |
| --- | --- | --- |
| Navigation path | usually yes | different scenes can show different flows/documents |
| Selected tab/sidebar item | usually yes | user context per window |
| Presented sheet/alert | yes | presentation belongs to visible scene |
| Focused document/item | yes or document-scoped | depends on product model |
| Scroll position/filter/sort UI | usually yes | UI convenience, not global truth |
| Draft edit text | scene-owned but durable if product promises recovery | one scene may edit independently |
| Auth session | no, app/account-scoped | shared security policy |
| Pending mutation queue | no, domain/sync-scoped | must survive scenes/process |
| Cached content | no or shared cache | bounded regenerable data |
| Permission state | app/capability-scoped | system grant shared, UI reaction scene-specific |

Rule: when adding state, ask which scene owns it, how it is restored, and what happens if another scene exists. If answer is “we only have one scene”, document that as current product constraint, not platform truth.

#### Routing и external intents
External intents can arrive at scene connection or while scenes already exist:
- Universal Links;
- custom URL schemes;
- push notification responses;
- shortcuts / quick actions;
- handoff / user activities;
- document open requests;
- App Intents handoff.

Routing must choose target scene policy:
- route into currently active compatible scene;
- reuse existing scene showing same document/context;
- create new scene if product supports it;
- ask user to choose if ambiguity matters;
- reject with safe explanation if route is invalid or unauthorized.

Dangerous pattern: parse URL in app delegate and mutate global navigation path. Correct pattern: parse into domain route intent, validate auth/domain/permissions, then deliver to selected scene coordinator exactly once.

Example shape:

```swift
struct SceneRouteIntent: Equatable, Codable {
    enum Target: Equatable, Codable {
        case activeScene
        case document(Document.ID)
        case newScene
    }

    let id: UUID
    let target: Target
    let route: AppRoute
    let createdAt: Date
}

@MainActor
final class SceneRouteCoordinator {
    private let sceneID: String
    private var consumedIntentIDs: Set<UUID> = []

    init(sceneID: String) {
        self.sceneID = sceneID
    }

    func handle(_ intent: SceneRouteIntent) {
        guard !consumedIntentIDs.contains(intent.id) else { return }
        guard canHandle(intent) else { return }

        consumedIntentIDs.insert(intent.id)
        // Apply route to this scene's navigation state only.
    }

    private func canHandle(_ intent: SceneRouteIntent) -> Bool {
        // Check target policy, auth/session/domain validity and scene compatibility.
        true
    }
}
```

#### Scene restoration boundaries
This subsection defines boundaries and ownership only. Full restoration pipeline design — encoding/decoding, schema/versioning, migration, validation matrix and tests — remains in `2.8`. Scene restoration is not the same as persistence: restoration rebuilds UI context; persistence preserves domain truth.

Good restoration candidates:
- selected tab/sidebar section;
- current document ID;
- navigation route if still valid;
- draft checkpoint reference;
- scroll position where useful;
- split view/sidebar visibility.

Bad restoration candidates:
- raw auth tokens;
- full DTO payloads;
- large decoded media buffers;
- sensitive content that should require re-auth;
- transient network response objects;
- domain data that belongs in persistence layer.

Restoration must validate current reality: document may be deleted, permission revoked, account switched, feature disabled, route unauthorized or app updated. Invalid restoration should degrade to safe fallback, not crash or show stale private content.

#### Production-правила и ловушки
Production rules:
- Keep scene navigation/presentation state scene-scoped.
- Do not use one global navigation path for all scenes unless product explicitly forbids multiple scenes and documents why.
- Route external intents through domain validation and scene target policy.
- Use `@SceneStorage` only for small UI state; do not store domain truth there.
- Preserve pending route intents through session/auth transitions and consume/reject once.
- Make scene disconnection safe: cancel scene-owned tasks, checkpoint scene UI state, do not clear app-wide domain state blindly.
- Include scene identity in lifecycle diagnostics and route logs.
- Treat SwiftUI `scenePhase` as signal, not full scene session model.

Ловушки:
- **Global navigation singleton:** second scene corrupts first scene route.
- **Scene disconnect data loss:** draft only in scene memory with no checkpoint.
- **App delegate routing overreach:** app-level handler mutates UI before scene exists.
- **Restoring stale private content:** old route shown after logout/account switch.
- **SceneStorage abuse:** storing large or sensitive domain data in scene UI storage.
- **Duplicate intent handling:** URL/push handled by app and scene both.
- **No scene diagnostics:** incident logs cannot tell which scene received lifecycle event.

#### SwiftUI-specific guidance
SwiftUI apps should still make scene ownership explicit.

Recommended patterns:
- create a scene-scoped model/coordinator per `WindowGroup` scene where navigation or route ownership matters;
- keep app-wide dependencies injected into scene model, not stored as mutable scene state;
- use `@SceneStorage` for small restoration hints, not source-of-truth data;
- use typed route intents and explicit scene target policy;
- avoid passing one global view model into all windows if it owns navigation or presentation.

Suspicious patterns:
- root `@StateObject` used as global navigation owner for every window;
- `.onOpenURL` directly mutates global path;
- every scene observes same singleton and presents same alert/sheet;
- `@SceneStorage` contains full serialized document/user profile;
- scene lifecycle callback clears account/session state.

#### Примеры, упражнения и Q&A с ответами
**Пример 1: Universal Link before scene exists**

Проблема: Universal Link arrives during scene connection. App tries to mutate a root view model that has not been created yet, so route is lost.

Целевое состояние: connection options become durable/queued `SceneRouteIntent`. Scene coordinator consumes it after setup and validation.

Проверка:
- launch from Universal Link cold;
- launch from Universal Link while app has existing scene;
- require auth before route;
- verify intent consumed once and safe fallback on invalid route.

**Пример 2: two scenes share one navigation path**

Этот пример нужен только для доказательства scene ownership. Product strategy for concurrent windows, conflict UX and document collaboration intentionally remains in `2.7`.

Проблема: user opens document A in one window and document B in another. Global path changes when second scene navigates, first scene jumps unexpectedly.

Целевое состояние: navigation path is scene-scoped; shared document data lives in domain/persistence layer. Each scene has separate selection/navigation and shared updates flow through domain state.

Проверка:
- open two scenes with different documents;
- navigate independently;
- update shared document content;
- verify navigation remains isolated and data updates remain consistent.

**Пример 3: `@SceneStorage` used as persistence**

Проблема: app stores full draft text or DTO payload in `@SceneStorage`. Sensitive data leaks into inappropriate storage path and large state becomes fragile.

Целевое состояние: `@SceneStorage` keeps small draft ID or UI hint. Draft body is persisted by feature/persistence owner with file protection, migration and cleanup policy.

Проверка:
- create large draft;
- terminate/relaunch;
- account switch/logout;
- verify restoration references valid durable data and does not reveal unauthorized content.

#### Review Q&A с ответами
1. **Почему scene lifecycle нельзя заменить app lifecycle?**
   **Ответ:** app lifecycle describes process/application state, while scene lifecycle describes конкретную UI-сессию. In multi-scene environment one scene can be active while another is backgrounded or disconnected.

2. **Какие state обычно должны быть scene-scoped?**
   **Ответ:** navigation path, selected tab/sidebar item, presentation state, scroll/filter UI, focused document context and scene-specific route handling. Domain source of truth and pending mutations обычно живут вне scene.

3. **Почему `@SceneStorage` не подходит для domain data?**
   **Ответ:** it is for small scene restoration hints. Domain data needs persistence, migration, privacy, backup/file protection and consistency policy.

4. **Как route intent должен попадать в scene?**
   **Ответ:** external input parses into typed intent, domain/session validation checks it, target scene policy selects scene, scene coordinator consumes or rejects intent once.

5. **Что делать, если restoration route больше не valid?**
   **Ответ:** degrade to safe fallback: home/document list/auth gate/error state with user-safe message. Do not crash, show stale private content or recreate deleted data.

6. **Как расследовать баг “окно само переключилось на другой экран”?**
   **Ответ:** inspect scene identity in logs, global navigation owners, external intent consumption, shared singleton mutations, scene connection/disconnection sequence and whether another scene changed shared UI state.

#### Чеклист production-readiness для scene lifecycle
Scene lifecycle handling не готово к production, пока:
- scene-scoped and app-scoped state boundaries documented;
- navigation/presentation state is not accidentally global;
- external intents have target scene policy;
- scene connection options are preserved until scene coordinator is ready;
- scene disconnection cancels scene-owned tasks without clearing app-wide truth;
- restoration validates auth, account, permissions, documents and feature availability;
- `@SceneStorage` contains only small non-sensitive UI hints;
- multi-scene diagnostics include scene/session identity;
- scene lifecycle tests cover connection, foreground/background, disconnection and invalid restoration;
- product explicitly documents if multi-scene is unsupported and code relies on that constraint.


### 2.7. Поведение multi-window
#### Назначение раздела
Multi-window поведение — это продуктово-архитектурное lifecycle-решение, а не “iPad-only optional polish”. На iPadOS пользователь может открыть несколько окон одного приложения, работать с разными документами, сценами, split view/Stage Manager layouts, external display contexts и system-driven scene restoration. Даже если приложение формально не продвигает multi-window UX, оно должно понимать, что scene model делает случайный global UI state опасным.

Senior-level цель — не сломать одну scene, когда появляется вторая. Staff-level цель — определить multi-window policy: поддерживаем, ограничиваем, запрещаем или поэтапно внедряем; какие domain entities могут быть открыты одновременно; как синхронизируются edits; как route intents выбирают окно; как QA/release доказывает корректность.

#### Scope и prerequisites
Этот раздел продолжает `2.6`. Там были scene lifecycle and ownership boundaries. Здесь фокус:
- product policy для multi-window;
- concurrent scene behavior;
- document/entity ownership across scenes;
- navigation and selection isolation;
- shared domain state and conflict policy;
- external intent target selection;
- QA, observability and release risks.

Не раскрывается подробно:
- low-level scene lifecycle callbacks — `2.6`;
- full state restoration — `2.8`;
- document architecture, collaboration and sync conflict resolution in depth — будущие data/sync sections;
- advanced iPad UI design patterns — отдельная UI/UX/accessibility topic.

Практическая формула: **multi-window readiness means every state has explicit scope: process-wide, account-wide, document-wide, scene-wide or view-local**.

#### Core theory и mental model
Multi-window breaks hidden singletons.

Single-window assumption:
- one navigation path;
- one selected item;
- one visible document;
- one current draft;
- one active route intent;
- one foreground scene;
- one presentation stack.

Multi-window reality:
- multiple scenes can be active or visible;
- each scene can show different navigation state;
- two scenes can reference same domain entity;
- one scene can be backgrounded while another remains active;
- external intents need target policy;
- domain updates should propagate consistently without hijacking UI context;
- destructive actions in one window can invalidate content in another.

Staff mental model: **UI context is scene-scoped; domain truth is shared and versioned; conflicts are product policy, not framework accidents**.

#### Product policy matrix
Before implementation, decide the product stance.

| Policy | When appropriate | Engineering consequences |
| --- | --- | --- |
| No multi-window support | app has strict single-session UX or high risk | explicitly disable/limit scene creation where possible; still avoid accidental global corruption |
| Passive compatibility | app may run multiple scenes but does not optimize UX | isolate navigation, prevent data loss, basic QA matrix |
| Document/entity windows | documents/items can open in separate windows | document identity, route target policy, concurrent edit rules |
| Power-user multi-window | users expected to compare/edit across windows | strong sync/conflict UX, drag/drop, keyboard, Stage Manager QA |
| External display / special roles | presentation/control split or media/pro workflows | scene roles, privacy, performance, input routing |

Policy must define non-goals. Example: “multiple windows may view different documents, but concurrent editing of same document is not supported; second editor opens read-only or asks user to switch”. Without this, engineers invent behavior ad hoc.

Governance rule: enabling or materially changing multi-window support requires ADR/RFC when it changes document/entity window policy, external display roles, route target policy, concurrent editing, navigation ownership, session/account behavior, persistence/sync semantics or release QA matrix.

Product examples:
- **Banking app:** often limits multi-window or uses read-only duplicate views because privacy/session risk is high.
- **Document editor:** usually benefits from document/entity windows, but needs edit locks, versioning and conflict UX.
- **Media/presentation app:** may use external display roles, requiring privacy and input-routing policy.
- **Commerce app:** may allow multiple browsing windows but keep checkout/session/payment state tightly scoped and protected.

#### Подкапотные детали
Relevant platform mechanics:
- `WindowGroup` can create multiple scenes for same app role.
- `DocumentGroup` and document-based apps naturally encourage multiple document scenes.
- `UIApplication.requestSceneSessionActivation` can ask system to activate/create a scene.
- `UISceneSession` has role and persistent identifier useful for bookkeeping, not domain identity.
- `connectionOptions` can carry external intents at scene creation.
- scene sessions can be discarded by system.
- SwiftUI navigation and presentation state can accidentally become global if owned above scene boundary.

Important principle: system owns window management. The app can request scene activation and provide configuration, but user/system may decide layout, visibility, size class, multitasking mode and restoration timing.

#### State scope matrix
Use this matrix to review every state variable:

| Scope | Examples | Storage/owner | Multi-window risk |
| --- | --- | --- | --- |
| Process-wide | app services, analytics config, dependency container | app composition root | accidental UI ownership in singleton |
| Account/session-wide | auth, account, entitlement state | session/account owner | logout/account switch impacts all scenes |
| Domain/entity-wide | document content, task, article, pending mutation | persistence/domain/sync owner | two scenes edit/read same entity |
| Scene-wide | navigation path, selected tab, presented sheet, focused document | scene coordinator/model | global path corrupts other scene |
| View-local | text field focus, transient animation state | view/model | over-persisting temporary UI |
| Capability-wide | permission state, background mode eligibility | capability owner | one scene assumes grant changed only for itself |

Rule: if state affects what a particular window displays, default to scene-wide. If state affects source of truth, default to domain/account-wide with versioning and conflict policy.

Review invariant: every new state variable, observable object or coordinator added to multi-window-capable code must be classified by scope before code review approval: process-wide, account/session-wide, domain/entity-wide, scene-wide, view-local or capability-wide.

#### Concurrent data and edit policy
Multi-window introduces same-entity concurrency inside one process.

Decide explicitly through product rules:
- **Same entity visibility:** define whether the same document/entity can be open in two scenes.
- **Edit concurrency:** define whether both scenes can edit or only one scene is writer.
- **Read-only duplicate:** define when duplicate scenes become read-only.
- **Edit lock:** define whether editing is locked to one scene and how user sees that lock.
- **Live propagation:** define whether changes are live-synced between scenes or require explicit refresh.
- **Deletion handling:** define how a scene reacts when another scene deletes the entity it displays.
- **Account/session change:** define how all scenes respond to logout, account switch, revocation or lock.

Common policies:
- **Single writer:** only one scene can edit; others view or navigate to existing editor.
- **Optimistic shared editing:** both scenes edit and domain model broadcasts changes with conflict resolution.
- **Read-only duplicates:** duplicate windows can view but not mutate.
- **Document identity reuse:** opening same document activates existing scene instead of creating duplicate.
- **Explicit conflict UI:** concurrent edits create conflict state user must resolve.

Never let accidental last-writer-wins become product policy. If two scenes can mutate same state, persistence/sync layer needs versioning, idempotency and conflict rules.

#### Routing and scene target policy
General external-intent mechanics were introduced in `2.6`. Here the focus is multi-window-specific target choice: same entity, existing compatible scene, privacy, unsaved edits, duplicate editor, and new scene vs reuse. Every external intent needs target decision.

Target options:
- existing active scene;
- existing scene showing same document/entity;
- most recently used compatible scene;
- new scene;
- user choice;
- reject route as unsupported/unauthorized.

Routing policy must consider:
- auth/session state;
- account ownership;
- document/entity availability;
- current scene edit state;
- whether opening route would destroy unsaved context;
- privacy of showing content in another window;
- platform capability: iPhone vs iPadOS, Stage Manager, external display.

Example policy object:

```swift
struct SceneTargetPolicy {
    enum Decision: Equatable {
        case useExistingScene(sceneID: String)
        case requestNewScene
        case requireUserChoice
        case reject(reason: RejectionReason)
    }

    func decide(
        intent: SceneRouteIntent,
        availableScenes: [OpenSceneSnapshot],
        session: SessionState
    ) -> Decision {
        guard session.canAccess(intent.route) else {
            return .reject(reason: .unauthorized)
        }

        if let scene = availableScenes.first(where: { $0.canHandle(intent) }) {
            return .useExistingScene(sceneID: scene.id)
        }

        return .requestNewScene
    }
}
```

This is a policy example, not a required abstraction. The important part is that target choice is explicit and testable.

#### UX, accessibility and localization implications
Multi-window changes user experience:
- titles and document names must clarify which window is which;
- destructive actions need clear scope: current window, current document, all account data;
- VoiceOver focus should not jump due to updates in another scene;
- keyboard shortcuts may target active scene only;
- drag/drop may create external intents or document copies;
- localized window titles and conflict messages need enough context;
- small split view widths can expose layout assumptions;
- external display scenarios can expose privacy-sensitive content.

Accessibility rule: when shared domain updates from another scene, current scene should announce meaningful changes only if they affect current user context. Do not spam VoiceOver with background-window updates.

#### Production-правила и ловушки
Production rules:
- Define product policy before enabling or relying on multi-window behavior.
- Isolate navigation, selection and presentation per scene.
- Share domain state through explicit owners, not UI singletons.
- Use scene identity in logs and route diagnostics.
- Decide same-entity concurrent edit behavior before shipping.
- Make destructive actions propagate safely to other scenes.
- Keep pending mutations process/domain-scoped, but UI pending indicators scene-specific.
- Do not treat `UISceneSession.persistentIdentifier` as document/account identity.
- Test old iPadOS versions and current iPadOS multitasking modes where supported.

Ловушки:
- **Accidental singleton UI:** one global view model owns navigation for all scenes.
- **Implicit last writer wins:** two windows edit same object and later save silently overwrites.
- **Route hijack:** push/deep link changes wrong scene.
- **Delete ghost:** one scene deletes item, another continues showing stale editable screen.
- **Logout blast radius unknown:** account change closes or corrupts scenes unpredictably.
- **No scene observability:** support cannot identify which window had the bug.
- **Unsupported but not audited:** app does not advertise/create extra windows, but configuration/restoration/external-intent paths still need audit so unexpected additional scene/session degrades safely instead of corrupting state.

#### Testing strategy
Minimum multi-window QA matrix:

Required for any multi-window-capable app:
- open two scenes with different entities;
- background one scene while another remains active;
- route Universal Link/push/document open while multiple scenes exist;
- account logout/switch with multiple scenes;
- process kill/relaunch with multiple scene restoration records;
- verify scene/session diagnostics for target decisions.

Conditional by product support:
- open two scenes with same entity if allowed;
- same-entity concurrent edit if allowed;
- delete/mutate entity in one scene and observe the other;
- permission revocation while multiple scenes show affected features;
- Stage Manager / Split View / Slide Over sizes where supported;
- external display if supported;
- drag/drop if supported;
- VoiceOver focus and keyboard shortcuts in active scene if interaction model supports them.

Instrumentation should include privacy-safe `sceneRole`, scene/session identity, `routeIntentKind`, route intent ID, active scene count, target decision, rejection reason and hashed/non-PII document/entity identifier where needed.

#### Примеры, упражнения и Q&A с ответами
**Пример 1: same document opened twice**

Проблема: app lets user edit same document in two windows. Each scene has local copy. Last save wins and silently discards changes from other scene.

Целевое состояние: product policy decides single writer, shared live model, read-only duplicate or explicit conflict UI. Persistence layer stores versions and refuses silent overwrite.

Проверка:
- open same document in two scenes;
- edit both;
- save in different order;
- verify policy outcome and user-visible conflict/read-only/merge behavior.

**Пример 2: Universal Link targets wrong window**

Проблема: user has document A in one window and document B in another. Universal Link to B activates A and changes its navigation unexpectedly.

Целевое состояние: route policy finds existing compatible scene for B or creates/asks for target. Scene A remains unchanged unless user chose it.

Проверка:
- two windows with different documents;
- route to each document;
- route to missing/unauthorized document;
- verify target decision logs.

**Пример 3: product does not support multi-window**

Проблема: team assumes iPhone-like single scene but does not document or test restrictions. A restored second scene appears with broken global state.

Целевое состояние: product explicitly declares unsupported multi-window, app does not advertise/create extra windows, platform configuration is audited, and any restored/extra scene or untargetable route degrades safely without data loss/global corruption.

Проверка:
- try system paths that create/restore additional scenes;
- verify safe fallback or refusal;
- ensure global state is not corrupted;
- document product limitation.

#### Review Q&A с ответами
1. **Почему multi-window — product decision, а не только UIKit detail?**
   **Ответ:** it changes user workflow, document ownership, concurrent editing, routing, support and QA matrix. Framework can create scenes, but product must define what multiple windows mean.

2. **Что должно быть scene-scoped in multi-window app?**
   **Ответ:** navigation path, selected item, presentation state, focused document context, scroll/filter UI and scene-specific route consumption. Domain data, auth and pending mutation queue usually live outside scene.

3. **Как избежать silent overwrite при двух окнах?**
   **Ответ:** define same-entity edit policy, use versioning/conflict detection, preserve local pending intent and show explicit merge/read-only/conflict UI instead of accidental last-writer-wins.

4. **Как external intent выбирает window?**
   **Ответ:** через target scene policy: existing compatible scene, new scene, user choice or rejection. Direct mutation of global navigation path is unsafe.

5. **Что делать, если multi-window не поддерживается продуктом?**
   **Ответ:** document non-goal, limit scene creation/restoration where possible, handle unexpected extra scene safely, and test that unsupported path does not corrupt state or lose data.

6. **Какие diagnostics нужны для multi-window bugs?**
   **Ответ:** scene/session ID, active scene count, route intent ID, target decision, entity/document ID where privacy-safe, lifecycle sequence and owner that mutated navigation/domain state.

#### Чеклист production-readiness для multi-window
Multi-window behavior не готов к production, пока:
- product policy and non-goals documented, with ADR/RFC for broad ownership or behavior changes;
- scene/domain/account/process state scopes are explicit;
- navigation and presentation are scene-scoped;
- same-entity concurrent edit policy defined;
- external intent target scene policy implemented and tested;
- destructive actions propagate safely to other scenes;
- unsupported multi-window behavior is intentionally limited and safe;
- logs include privacy-safe scene identity and target decisions;
- QA covers multiple scenes, same/different entities, account changes and restoration;
- accessibility and localization cover window titles, focus and conflict states;
- release notes/support guidance reflect supported multi-window behavior.


### 2.8. Восстановление состояния
#### Назначение раздела
Восстановление состояния — это способность приложения после relaunch, scene recreation, process death, update, auth/session transition или route handoff вернуть пользователя в корректный, безопасный and meaningful context. Это не “сохранить всё, что было на экране”. Правильное восстановление отделяет domain source of truth, pending user intent, scene UI context, transient rendering state and regenerable cache.

Senior-level ошибка — serializing entire view model or navigation stack без validation. Staff-level mental model: **state restoration is a contract between lifecycle, persistence, navigation, privacy and product expectations**. Восстановленное состояние должно быть valid now, not merely valid when it was captured.

Scope boundary: этот раздел покрывает restoration contract, validation, payload compatibility and recovery behavior. Он не раскрывает глубоко storage engines, Core Data/SwiftData migration internals, multi-window product policy or full sync conflict resolution. Эти темы принадлежат persistence/data migration, multi-window and sync sections; здесь они рассматриваются только как constraints for restoration correctness.

#### Rendering и lifecycle model
Restoration happens through several paths:
- cold launch after termination or update;
- warm scene recreation;
- scene restoration after system discarded session;
- deep link / push / handoff after auth gate;
- draft/document recovery after crash/jetsam;
- app reinstall/upgrade where local data may or may not survive;
- account switch/logout where old restoration state becomes invalid.

Rendering model: UI should first show a safe shell, then restore validated context incrementally. Do not block the first frame on full restoration of every nested screen if a lightweight shell can show progress, conflict, auth gate or fallback.

Lifecycle rule: restoration data is input to a state machine, not command to blindly recreate UI. Every restored route/state must pass validation:
- account/session still matches;
- domain entity exists and user can access it;
- permission/capability still available;
- app version can decode restoration payload;
- feature flag still allows route;
- privacy/security policy allows showing content;
- scene target still makes sense.

Validation matrix:

| Validation axis | Required check | Safe fallback |
| --- | --- | --- |
| Account | restored account matches current/available account | auth/account chooser/home |
| Session/security | session valid or lock gate can protect content | redacted shell/auth gate |
| Permission | capability still granted/limited/available | denied/restricted UI state |
| Feature flag | route still enabled in current build/config | home/list with message |
| Entity existence | document/item still exists and user can access it | list/search/recovery state |
| Schema version | payload decodes or migrates safely | quarantine entry and fallback |
| Privacy lock | content can be shown to current user/device state | redacted state until unlock |
| File protection | protected data available or deferred until unlock | waiting/unavailable state without data deletion |

#### Граница ownership состояния
State categories:

| Category | Purpose | Owner | Restoration policy |
| --- | --- | --- | --- |
| Source of truth | durable product data | persistence/domain owner | load through domain layer |
| Pending user intent | unsent mutation, draft, import/export | feature/sync owner | must restore or explain |
| Scene restoration hint | selected tab, route, document ID, scroll position | scene coordinator | restore after validation |
| UI transient state | focus, hover, animation, temporary alert | view/scene owner | usually no |
| Regenerable cache | thumbnails, decoded media, derived layout | cache/media owner | rebuild lazily |
| Diagnostic breadcrumb | recovery journal, last failure category | observability owner | use for recovery/debug only |

Rule: restoration payload should usually store identifiers and small hints, not full objects. Store `documentID`, `route`, `draftID`, `scrollAnchor`, `selectedTab`, not entire DTOs, decoded images, tokens or view model graphs.

`@SceneStorage` boundary: use it for small scene-local hints supported by the mechanism and safe for restoration, such as selected tab, lightweight route identifier or UI preference. Do not store secrets, large payloads, full document bodies, DTO graphs, token-like values or complex migration-sensitive objects there. Complex restoration should use a typed envelope with schema/version, validation and cleanup policy.

#### Schema, versioning и migration
Restoration state is shipped data. If you persist it, you own compatibility.

Rules:
- include schema/version for restoration payloads;
- decode unknown/missing fields safely;
- preserve compatibility for shipped restoration data unless destructive reset is explicitly accepted;
- clear only invalid restoration entries, not unrelated user data;
- app update must migrate or gracefully ignore old restoration payload;
- rollback/re-release must understand data written by pulled release where possible;
- new versions should avoid writing restoration payload that older rollback version turns into a launch loop;
- app group/shared restoration data must consider extensions/widgets separately.

Example envelope:

```swift
struct SceneRestorationEnvelope: Codable, Equatable {
    static let currentSchemaVersion = 1

    let schemaVersion: Int
    let sceneKind: String
    let accountID: Account.ID?
    let route: RestorableRoute
    let selectedTab: String?
    let updatedAt: Date
}

enum RestorableRoute: Codable, Equatable {
    case home
    case document(id: Document.ID)
    case search(queryID: UUID)
}
```

Do not put raw auth tokens, full profile payloads, full document bodies or sensitive free-text search queries into restoration payload unless product/security explicitly approves storage, retention and protection policy.

#### Layout, invalidation и performance-риски
Restoration can create launch regressions if it eagerly rebuilds heavy UI.

Performance risks:
- decoding large restoration graph before first usable screen;
- immediately fetching all data for restored nested route;
- restoring scroll position by materializing entire list;
- restoring media-heavy gallery and decoding full-size images;
- broad SwiftUI invalidation when route/session restoration updates global state;
- old restoration payload causing migration on main actor;
- invalid route repeatedly failing and retrying on launch.

Performance rules:
- restore shell first, data second;
- use identifiers and lazy domain fetch;
- validate route before loading expensive content;
- show placeholder/skeleton with stable layout if content is loading;
- downsample media and restore only visible range;
- make failed restoration terminal until user/action changes state;
- instrument restoration duration and failure category.

Restoration must not cause a relaunch loop. If payload is corrupt, unauthorized, too old or repeatedly fails, app should quarantine/drop that restoration entry and open safe fallback.

Deterministic corrupt-payload policy: decode failure marks only that restoration entry invalid with reason; app opens one safe fallback; invalid entry is not retried on every launch; cleanup affects only restoration metadata, not source-of-truth user data.

#### Safe decode and fallback pattern
Minimal restoration pipeline:

```swift
enum RestorationFailureReason {
    case decodeFailed
    case unsupportedFutureSchema
    case invalidCurrentContext
}

struct RestorationValidationContext {
    func canAccess(route: RestorableRoute, accountID: Account.ID?) -> Bool {
        // Validate account/session/permission/entity/feature flag/privacy lock.
        true
    }
}

enum RestorationDecision {
    case restore(SceneRestorationEnvelope)
    case fallback(reason: RestorationFailureReason)
}

func decodeAndValidateRestoration(
    data: Data,
    context: RestorationValidationContext
) -> RestorationDecision {
    guard let envelope = try? JSONDecoder().decode(SceneRestorationEnvelope.self, from: data) else {
        return .fallback(reason: .decodeFailed)
    }

    guard envelope.schemaVersion <= SceneRestorationEnvelope.currentSchemaVersion else {
        return .fallback(reason: .unsupportedFutureSchema)
    }

    guard context.canAccess(route: envelope.route, accountID: envelope.accountID) else {
        return .fallback(reason: .invalidCurrentContext)
    }

    return .restore(envelope)
}
```

Production implementation should record privacy-safe failure reason, quarantine invalid entry if needed and avoid retry loops.

#### Accessibility и localization-соображения
Restored UI must be understandable to assistive technologies and localized users.

Rules:
- VoiceOver focus should land on meaningful restored context or safe fallback, not invisible stale element.
- If restored content is unavailable, announce actionable state: document moved, permission denied, account changed, draft recovered. After a payload is quarantined, fallback announcement should not repeat on every launch as if it were a new event.
- Dynamic Type/layout changes since last session should not make restored route unusable.
- Locale/language changes can invalidate formatted search filters, dates, sorting and cached display strings.
- RTL layout can change navigation/sidebar assumptions.
- Restored alerts/sheets should be shown only if still actionable; do not resurrect old modal noise.
- Privacy-sensitive restored screens may require redaction/auth before accessibility exposes content.

Accessibility restoration is not only focus. It includes state explanation, announcement timing, reduced motion, input focus, keyboard navigation and avoiding repeated announcements on launch.

#### Failure cases и debugging workflow
Common failure cases:
- entity deleted or moved;
- user logged out or switched account;
- permission revoked;
- feature flag disabled route;
- restoration payload from older schema fails decode;
- scene restored into wrong account/window;
- draft restored but source file unavailable due to file protection;
- app loops because corrupted route retries every launch;
- sensitive content restored before auth gate;
- scroll position restored before list data is available.

Debugging workflow:
1. Capture restoration source: scene session, `@SceneStorage`, file/UserDefaults/DB record, recovery journal, deep link or pending intent.
2. Decode payload with schema/version and log privacy-safe failure category.
3. Validate account/session/permission/entity/feature flag.
4. Identify owner: scene coordinator, domain layer, persistence, sync or feature model.
5. Check performance: what restoration work runs before first usable screen.
6. Check accessibility: focus, announcements, redaction and fallback message.
7. Confirm cleanup: invalid payload is quarantined or removed without deleting user data.

Observability should include restoration kind, schema version, route kind, validation result, failure category, duration and fallback used. Avoid raw document titles, queries, content or PII in logs.

#### Примеры, previews и упражнения для добавления
**Пример 1: восстановление удалённого документа**

Проблема: restoration payload points to `documentID`, but document was deleted on another device. App crashes because route assumes document exists.

Целевое состояние: route validation detects missing entity, removes invalid restoration hint, opens document list with localized message and optional recovery/support action.

Проверка:
- open document;
- persist scene restoration;
- delete document through another path;
- relaunch;
- verify safe fallback and no crash.

**Пример 2: account switch invalidates restoration**

Проблема: user logs out and different user logs in. App restores previous user's private route.

Целевое состояние: restoration envelope includes account/context identity. On account mismatch, payload is rejected or quarantined, sensitive content not shown, and scene opens safe home/auth state.

Проверка:
- save restoration under account A;
- logout/login account B;
- relaunch;
- verify no private content leak and clear fallback.

**Пример 3: restoration causes launch jank**

Проблема: app restores image gallery by decoding all thumbnails and full images before first frame.

Целевое состояние: restoration stores gallery route and scroll anchor only. UI restores shell, lazily loads visible thumbnails, downsampled by target size, with bounded cache.

Проверка:
- large gallery on old device;
- terminate/relaunch;
- compare launch/first interaction metrics;
- verify memory peak and no jetsam loop.

#### Review Q&A с ответами
1. **Почему нельзя просто сериализовать весь ViewModel для restoration?**
   **Ответ:** ViewModel often contains services, tasks, transient UI, stale domain snapshots and private data. Restoration should store small validated identifiers/hints and rebuild current state through owners.

2. **Чем restoration отличается от persistence?**
   **Ответ:** persistence stores product truth. Restoration stores UI context hints that help return user to a place. Restoration must validate against current domain/session/permission reality.

3. **Что делать с invalid restoration payload?**
   **Ответ:** reject or quarantine it, open safe fallback, log privacy-safe failure category and avoid deleting unrelated user data. Repeated invalid payload should not cause relaunch loop.

4. **Как restoration взаимодействует с migration?**
   **Ответ:** persisted restoration payload needs schema/version compatibility. App update should migrate, ignore or safely drop old restoration hints without corrupting source-of-truth data.

5. **Какие restoration данные нельзя хранить?**
   **Ответ:** raw tokens, full sensitive payloads, decoded media buffers, unbounded DTOs, private free-text queries without policy, and data that belongs in secure persistence or domain store.

6. **Как проверить restoration quality?**
   **Ответ:** test relaunch after kill, update, account switch, permission revocation, deleted entity, corrupt payload, large data and accessibility focus. Verify fallback, performance and privacy.

#### Чеклист production-readiness для state restoration
State restoration не готово к production, пока:
- restoration data inventory separates domain truth, pending intent, scene hints, cache and diagnostics;
- payloads use schema/version and safe decode behavior;
- account/session/permission/entity validation happens before showing restored content;
- invalid payload has safe fallback and cleanup/quarantine policy;
- restoration does not block first usable screen with heavy work;
- sensitive content is not restored before auth/privacy policy allows it;
- `@SceneStorage` is limited to small non-sensitive UI hints;
- migrations/updates handle shipped restoration payloads;
- accessibility focus and localized fallback messages are tested;
- observability records privacy-safe restoration result and duration;
- QA covers kill/relaunch, update, account switch, deleted entity, revoked permission and corrupt payload.


## 3. Системные интеграции
### 3.1. Push-уведомления
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 3.2. Ограничения silent push
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 3.3. Deep links
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 3.4. Universal Links
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 3.5. Widgets
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 3.6. App Intents
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 3.7. Live Activities
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 3.10. Siri / Shortcuts
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 3.11. App Groups
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 3.12. Управление интеграциями уровня Staff
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review Q&A с ответами и calibration rubric
#### Case studies и упражнения с эталонным разбором для добавления

---

# Часть II. Глубокий разбор языка Swift

## 4. Основы Swift на уровне Senior+
### 4.1. Семантика значений
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 4.2. Семантика ссылок
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 4.3. Идентичность и равенство
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 4.4. Контроль изменяемости
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 4.5. Контроль доступа и дизайн поверхности API
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 4.7. Optionals за пределами основ
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 4.8. Сопоставление с образцом
#### Модель угроз и защищаемые assets
#### Механизмы платформы и entitlement surface
#### Жизненный цикл данных, retention и deletion behavior
#### Ограничения logging, analytics и crash reporting
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 4.9. Правила инициализации
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 4.10. Деинициализация и lifetime
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 4.11. Языковые возможности, которые выглядят простыми, но формируют архитектуру
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления

## 5. Memory model Swift
### 5.1. Стек и heap в практическом Swift
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 5.2. Value witness tables
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 5.3. Операции copy / destroy / move
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 5.4. Внутренности copy-on-write
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 5.5. `isKnownUniquelyReferenced`
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 5.6. Скрытые копии в hot paths
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 5.7. Подводные камни больших value types
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 5.8. Structs, которые не должны быть слишком большими
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 5.11. Crash-семантика `unowned`
#### Operational goal и ownership
#### Build, signing и environment constraints
#### Telemetry, logging и alerting signals
#### Rollout, rollback и incident workflow
#### Compliance и support handoff checklist
#### Runbook-примеры для добавления
### 5.12. Autorelease pools в смешанном Swift/UIKit-коде
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 5.13. Чеклист ревью владения памятью
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления

## 6. Protocols, existentials и generics
### 6.1. Protocols как контракты поведения
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 6.2. Protocols как архитектурные границы
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 6.3. Чрезмерное использование protocols и декоративные абстракции
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
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
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 6.6. Existential containers под капотом
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 6.7. Inline existential buffer
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 6.8. Witness tables
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 6.9. Opaque types: `some Protocol`
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 6.10. Generic constraints
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 6.11. Generic specialization
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 6.12. Conditional conformances
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 6.13. Type erasure
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 6.14. Phantom types
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 6.15. Полиморфизм compile-time vs runtime
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 6.16. Дизайн API с generics на уровне Staff
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления

## 7. Dispatch, metadata и dynamic behavior
### 7.1. Статическая диспетчеризация
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 7.2. Динамическая диспетчеризация
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 7.3. Диспетчеризация через witness table
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 7.4. Диспетчеризация сообщений Objective-C
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 7.5. `final` и девиртуализация
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 7.6. `@objc`, `dynamic`, KVO и стоимость bridging
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 7.7. Runtime metadata
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 7.8. Ограничения reflection
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 7.9. Стабильность ABI
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 7.10. Стабильность модулей
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 7.11. Режим library evolution
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

## 8. Продвинутые инструменты языка Swift
### 8.1. Property wrappers
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 8.2. Result builders
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 8.3. Macros
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 8.4. Key paths
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 8.5. Dynamic member lookup
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 8.6. Пользовательские операторы и почему большинства из них стоит избегать
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 8.7. Внутренности Codable и кастомизация
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 8.8. Аннотации Sendability на уровне языка
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 8.9. Поведение языка в Debug vs Release
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 8.10. Когда языковая изобретательность вредит maintainability
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
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
### 9.3. Группы tasks
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist
### 9.4. Async let
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
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
### 10.7. Tasks, принадлежащие жизненному циклу
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 10.9. Чеклист ownership для production tasks
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления

## 11. Actors и executors
### 11.1. Изоляция actors
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 11.2. Reentrancy actors
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 11.3. Инварианты actors
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 11.4. Nonisolated APIs
#### Контракт и ownership данных
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
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 11.6. Переходы между actors
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
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
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 11.10. Антипаттерны actors
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления

## 12. Sendable и готовность к Swift 6
### 12.1. `Sendable`
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 12.2. `@unchecked Sendable`
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
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
#### Production-ловушки и review Q&A с ответами
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
#### Production-ловушки и review Q&A с ответами
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
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 13.8. Счётчики поколений
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 13.9. Тестирование cancellation
#### Execution model и isolation boundary
#### Task lifecycle и cancellation semantics
#### Actor, Sendable и data-race ограничения
#### Priority, executor и main-thread последствия
#### Debugging и instrumentation workflow
#### Migration и code-review checklist

## 14. AsyncSequence и streams
### 14.1. Ментальная модель AsyncSequence
#### Контракт и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 14.2. Буферизация
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 14.3. Backpressure
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 14.4. Мосты к delegate APIs
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Interview/incident-review Q&A с ответами
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 15.2. View values vs render tree
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 15.3. Инвалидация body
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 15.4. Структурная identity
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 15.5. Явная identity
#### Scope и граница test target
#### Deterministic setup и fixture strategy
#### Failure modes, flakiness и timing-риски
#### Coverage expectations и missing-case checklist
#### CI, artifacts и triage workflow
#### Примеры тестов и упражнения для добавления
### 15.6. Ловушки `.id()`
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 15.7. Ментальная модель diffing
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Production-ловушки и review Q&A с ответами
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 16.3. `@Observable`
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 16.4. `@Bindable`
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 16.5. `@Environment`
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 16.6. `@EnvironmentObject`
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 16.7. Legacy `ObservableObject`
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 16.11. Ревью state ownership уровня Staff
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
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
### 17.3. Мифы о GeometryReader
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 17.4. Preference keys
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
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
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления

## 18. SwiftUI performance
### 18.1. Форматирование в `body`
#### Модель угроз и защищаемые assets
#### Механизмы платформы и entitlement surface
#### Жизненный цикл данных, retention и deletion behavior
#### Ограничения logging, analytics и crash reporting
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 18.2. Повторное создание formatters
#### Модель угроз и защищаемые assets
#### Механизмы платформы и entitlement surface
#### Жизненный цикл данных, retention и deletion behavior
#### Ограничения logging, analytics и crash reporting
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 18.3. Декодирование изображений в rows
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 18.4. `AnyView` и стоимость type erasure
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 18.5. Чрезмерное использование `.id()`
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 18.6. Большие observable objects
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 18.7. Lazy containers
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления

## 19. UIKit и legacy interoperability
### 19.1. Жизненный цикл view controller
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
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 19.8. Core Animation transactions
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
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления

---

# Часть V. Основы архитектурного мышления

## 20. Архитектурное мышление
### 20.1. Что такое архитектура и чем она не является
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
### 20.3. Обратимость
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 20.4. Стоимость изменений
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 20.5. Локальный оптимум vs глобальный оптимум
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 20.6. Архитектура как управление рисками
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 20.7. Архитектура как средство коммуникации
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 21.8. Runtime coupling
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 21.9. Data coupling
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 21.10. Temporal coupling
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 21.11. Semantic coupling
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 21.12. Организационное coupling
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

## 22. Ownership состояния и side effects
### 22.1. Источник истины
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 22.9. Navigation side effects
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 22.10. Network side effects
#### Контракт и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 22.11. Persistence side effects
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 23.5. Путь миграции
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 23.6. Правила sunset
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 23.7. Governance без бюрократии
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review Q&A с ответами и calibration rubric
#### Case studies и упражнения с эталонным разбором для добавления

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
#### Контракт и ownership данных
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
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 24.6. Ownership navigation
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
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
#### Production-ловушки и review Q&A с ответами
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
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 26.5. Разделение lifecycle приложения и session
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 28.2. Каркас приложения
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 28.3. Правила Shared/Core
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Review Q&A с ответами и calibration rubric
#### Case studies и упражнения с эталонным разбором для добавления
### 28.6. Стратегия выделения модулей
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review Q&A с ответами и calibration rubric
#### Case studies и упражнения с эталонным разбором для добавления
### 28.7. Последствия для build time
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

## 29. Hexagonal / Ports & Adapters
### 29.1. Ports
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 29.2. Driving adapters
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 29.3. Driven adapters
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 29.4. Чистота domain
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 29.5. DTO/error mapping на границах
#### Контракт и ownership данных
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
#### Production-ловушки и review Q&A с ответами
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 30.3. Mutations
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 30.4. Reducers
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 30.5. Effects
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 30.6. Store scope
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 30.7. Traceable feature state
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления

## 31. TCA-style architecture
### 31.1. Ментальная модель TCA
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
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Production-ловушки и review Q&A с ответами
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 32.4. `reduce`
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 32.5. Rx vs async/await варианты
#### Контракт и ownership данных
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
#### Production-ловушки и review Q&A с ответами
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
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 34.3. Адаптация passive view для SwiftUI
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 34.4. Как избегать декоративных view protocols
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
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
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 35.3. Presenter
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 35.4. Router
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 35.5. Worker
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления

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
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 36.3. Presenter
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 36.4. Entity
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 36.5. Router
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 36.6. Builder
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 36.7. VIPER в SwiftUI
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 36.8. Антипаттерн с перегруженным Presenter
#### Модель угроз и защищаемые assets
#### Механизмы платформы и entitlement surface
#### Жизненный цикл данных, retention и deletion behavior
#### Ограничения logging, analytics и crash reporting
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления

## 37. RIBs
### 37.1. Router
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 37.2. Interactor
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 37.3. Builder
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 37.4. Component
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 37.5. Lifecycle attach/detach
#### Модель угроз и защищаемые assets
#### Механизмы платформы и entitlement surface
#### Жизненный цикл данных, retention и deletion behavior
#### Ограничения logging, analytics и crash reporting
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
#### Production-ловушки и review Q&A с ответами
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 38.3. Структура Xcode-проекта
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 38.4. Управление build time
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 38.5. Командный ownership
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 38.6. Контроль public API
#### Контракт и ownership данных
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
#### Review Q&A с ответами и calibration rubric
#### Case studies и упражнения с эталонным разбором для добавления

## 39. Dependency management
### 39.1. SwiftPM
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 39.4. Политика обновлений
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 39.5. Security-ревью
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
#### Модель угроз и защищаемые assets
#### Механизмы платформы и entitlement surface
#### Жизненный цикл данных, retention и deletion behavior
#### Ограничения logging, analytics и crash reporting
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 40.2. Components
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 40.3. Theming
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 40.6. Governance design system
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review Q&A с ответами и calibration rubric
#### Case studies и упражнения с эталонным разбором для добавления

---

# Часть VIII. Networking и API contracts

## 41. Основы networking
### 41.1. URLSession
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 41.2. Моделирование requests
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 41.3. Валидация responses
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 41.4. Decoding
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 41.7. Retries
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

## 42. URLSession под капотом
### 42.1. DNS
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 42.2. TCP/TLS
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 42.3. HTTP/2 multiplexing
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 42.5. URL cache
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 42.7. Семантика timeout
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 42.8. Дорогие и сети с ограничениями
#### Контракт и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics

## 43. Проектирование API contract
### 43.1. DTOs
#### Контракт и ownership данных
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
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 43.5. Idempotency
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 43.6. Частичный успех
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 43.7. Versioning
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 43.8. Backward-compatible mobile APIs
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 44.2. Хранение token
#### Контракт и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 44.3. Refresh tokens
#### Модель угроз и защищаемые assets
#### Механизмы платформы и entitlement surface
#### Жизненный цикл данных, retention и deletion behavior
#### Ограничения logging, analytics и crash reporting
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 44.4. Expiration
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 44.5. Logout
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 44.6. Восстановление session
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 44.7. Поддержка нескольких аккаунтов
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

## 45. Network resilience
### 45.1. Поведение offline
#### Контракт и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 45.2. Retryable vs non-retryable failures
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 45.6. Пользовательская обратная связь
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

---

# Часть IX. Persistence, local data и sync

## 46. Варианты persistence
### 46.1. UserDefaults
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 46.2. Keychain
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 46.4. SQLite
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 46.5. Core Data
#### Контракт и ownership данных
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
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 46.7. App Groups
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

## 47. Глубокий разбор SwiftData / Core Data
### 47.1. Object graph
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 47.2. Identity
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 47.3. Faulting
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 47.4. Ownership context
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 47.5. Отслеживание изменений
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 47.9. Производительность запросов
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview/incident-review Q&A с ответами
### 47.10. Индексация и ограничения fetch
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

## 48. Offline-first и sync
### 48.1. Локальный source of truth
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 48.2. Ожидающие mutations
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 48.3. Ключи idempotency
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 48.4. Разрешение конфликтов
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 48.5. Tombstones
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 48.6. Local IDs vs server IDs
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 48.7. Риски last-write-wins
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 48.10. Наблюдаемость sync
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления

## 49. Data safety
### 49.1. Secrets vs non-secrets
#### Модель угроз и защищаемые assets
#### Механизмы платформы и entitlement surface
#### Жизненный цикл данных, retention и deletion behavior
#### Ограничения logging, analytics и crash reporting
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 49.2. Защита файлов
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 49.3. Разрушающие миграции
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 49.4. Поведение backup
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 49.5. Удаление данных
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 49.6. Требования в стиле GDPR/CCPA
#### Модель угроз и защищаемые assets
#### Механизмы платформы и entitlement surface
#### Жизненный цикл данных, retention и deletion behavior
#### Ограничения logging, analytics и crash reporting
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления

---

# Часть X. Security и privacy

## 50. Security model iOS
### 50.1. Sandbox
#### Модель угроз и защищаемые assets
#### Механизмы платформы и entitlement surface
#### Жизненный цикл данных, retention и deletion behavior
#### Ограничения logging, analytics и crash reporting
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 50.2. Keychain
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 50.4. App Groups
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 50.5. Secure Enclave
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 50.6. Biometrics
#### Operational goal и ownership
#### Build, signing и environment constraints
#### Telemetry, logging и alerting signals
#### Rollout, rollback и incident workflow
#### Compliance и support handoff checklist
#### Runbook-примеры для добавления

## 51. Threat modeling для iOS
### 51.1. Случайный атакующий
#### Модель угроз и защищаемые assets
#### Механизмы платформы и entitlement surface
#### Жизненный цикл данных, retention и deletion behavior
#### Ограничения logging, analytics и crash reporting
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 51.2. Устройство с jailbreak
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 51.3. Сетевой атакующий
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 51.6. Границы доверия к server
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

## 52. Secure coding
### 52.1. Lifecycle секретов
#### Модель угроз и защищаемые assets
#### Механизмы платформы и entitlement surface
#### Жизненный цикл данных, retention и deletion behavior
#### Ограничения logging, analytics и crash reporting
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 52.2. Хранение token
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 52.4. TLS и ATS
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 52.5. Tradeoff-ы certificate pinning
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 52.6. Валидация ввода
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 52.7. Ограничения reverse engineering
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

## 53. Privacy engineering
### 53.1. Минимизация данных
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 53.2. Permission prompts
#### Модель угроз и защищаемые assets
#### Механизмы платформы и entitlement surface
#### Жизненный цикл данных, retention и deletion behavior
#### Ограничения logging, analytics и crash reporting
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 53.3. Privacy manifests
#### Модель угроз и защищаемые assets
#### Механизмы платформы и entitlement surface
#### Жизненный цикл данных, retention и deletion behavior
#### Ограничения logging, analytics и crash reporting
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 53.4. Privacy labels App Store
#### Модель угроз и защищаемые assets
#### Механизмы платформы и entitlement surface
#### Жизненный цикл данных, retention и deletion behavior
#### Ограничения logging, analytics и crash reporting
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 53.5. Privacy analytics
#### Модель угроз и защищаемые assets
#### Механизмы платформы и entitlement surface
#### Жизненный цикл данных, retention и deletion behavior
#### Ограничения logging, analytics и crash reporting
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 53.6. Privacy crash reports
#### Модель угроз и защищаемые assets
#### Механизмы платформы и entitlement surface
#### Жизненный цикл данных, retention и deletion behavior
#### Ограничения logging, analytics и crash reporting
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 54.2. Frame budgets
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 54.5. Предотвращение regressions
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

## 55. Launch performance
### 55.1. Холодный запуск
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview/incident-review Q&A с ответами
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 55.5. Метрики запуска
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview/incident-review Q&A с ответами
### 55.6. dyld и загрузка библиотек
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

## 56. CPU profiling
### 56.1. Time Profiler
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview/incident-review Q&A с ответами
### 56.2. Self weight vs total weight
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 56.3. Интерпретация stack trace
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 56.4. Symbolication
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 56.5. Алгоритмическая сложность в UI
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 56.6. Сортировка/фильтрация в hot paths
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

## 57. Memory performance
### 57.1. Рост heap
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 57.2. Retain cycles
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 57.3. Дизайн cache
#### Контракт и ownership данных
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
#### Interview/incident-review Q&A с ответами
### 57.5. Data blobs
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 57.6. Memory pressure
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview/incident-review Q&A с ответами
### 57.7. Jetsam
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

## 58. Image pipeline performance
### 58.1. Compressed vs decoded image
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 58.2. Downsampling
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 58.3. Decompression
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 58.4. Стоимость cache
#### Контракт и ownership данных
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
#### Interview/incident-review Q&A с ответами

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
#### Примеры, упражнения и Q&A с ответами для добавления
### 59.3. Offscreen rendering
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 59.4. Blending
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 59.5. Shadows and masks
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 59.6. Подвисания scrolling
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview/incident-review Q&A с ответами
### 59.7. Backpressure пагинации
#### Контракт и ownership данных
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
#### Interview/incident-review Q&A с ответами
### 60.3. Allocations
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 60.4. Leaks
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 60.5. Hangs
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 60.6. Network-инструменты
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 60.8. MetricKit
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

---

# Часть XII. Accessibility, localization и inclusive UX

## 61. Accessibility
### 61.1. VoiceOver
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 61.2. Labels, hints, traits
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 61.5. Tap targets
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 61.6. Reduce Motion
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 61.7. Contrast
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 62.2. Plurals
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 62.3. Даты и числа
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 62.4. RTL
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 62.5. String interpolation
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 62.6. Pseudolocalization
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Interview/incident-review Q&A с ответами

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
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 64.3. Async-тесты
#### Контракт и ownership данных
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
### 64.6. Детерминизм
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 64.7. Диагностика flakiness
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

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
#### Production-ловушки и review Q&A с ответами
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
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 66.6. Result bundles
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

---

# Часть XIV. CI/CD и release engineering

## 67. Build system
### 67.1. Xcode build pipeline
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 67.2. Schemes
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 67.3. Configurations
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 67.4. DerivedData
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 67.5. Module cache
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 67.7. Анализ build logs
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

## 68. Swift compiler и binary behavior
### 68.1. Производительность type-checker
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview/incident-review Q&A с ответами
### 68.2. Взрывы compile time из-за result builders
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 68.3. Generic constraints и compile time
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 68.4. Dead stripping
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 68.5. Видимость символов
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 68.6. Размер binary
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 68.7. Производительность Debug vs Release
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview/incident-review Q&A с ответами

## 69. CI pipelines
### 69.1. GitHub Actions / Bitrise / Xcode Cloud
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 69.2. Статические gates
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 69.6. Триаж failures
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 69.7. Стратегия cache
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 70.2. Provisioning profiles
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview/incident-review Q&A с ответами
### 70.3. Entitlements
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 70.4. App Groups
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления

---

# Часть XV. Observability и operations

## 72. Logging
### 72.1. OSLog
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 72.2. Redaction
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 72.3. Log levels
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 72.4. Структурированные logs
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 72.5. Correlation IDs
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 72.6. Supportability
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления

## 73. Analytics
### 73.1. Таксономия событий
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 73.2. Privacy-safe analytics
#### Модель угроз и защищаемые assets
#### Механизмы платформы и entitlement surface
#### Жизненный цикл данных, retention и deletion behavior
#### Ограничения logging, analytics и crash reporting
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 73.5. Эксперименты
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

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
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 74.5. Обнаружение regressions
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

## 75. Runtime monitoring и incidents
### 75.1. MetricKit
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 75.2. Дашборды производительности
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview/incident-review Q&A с ответами
### 75.3. Network-метрики
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 75.6. Postmortems
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

---

# Часть XVI. Engineering leadership

## 76. Execution уровня Senior engineer
### 76.1. Ownership
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 76.2. Выявление рисков
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 76.3. Техническое планирование
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 76.4. Коммуникация
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review Q&A с ответами и calibration rubric
#### Case studies и упражнения с эталонным разбором для добавления
### 76.5. Оценка
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 76.6. Контроль scope
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

## 77. Навыки Tech Lead
### 77.1. Декомпозиция работы
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 77.2. Делегирование
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 77.3. Качество ревью
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 77.4. Менторство
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 77.5. Cross-functional работа
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 77.6. Delivery без heroics
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

## 78. Навыки Staff engineer
### 78.1. Влияние без формальной authority
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 78.2. Техническая стратегия
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review Q&A с ответами и calibration rubric
#### Case studies и упражнения с эталонным разбором для добавления
### 78.3. Engineering leverage
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 78.4. Standards и governance
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review Q&A с ответами и calibration rubric
#### Case studies и упражнения с эталонным разбором для добавления
### 78.5. RFC и ADR
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review Q&A с ответами и calibration rubric
#### Case studies и упражнения с эталонным разбором для добавления
### 78.6. Долгосрочная maintainability
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 78.7. Когда нужно сказать нет
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

## 79. Technical debt и strategy
### 79.1. Осознанный debt
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 79.6. Стратегия погашения debt
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review Q&A с ответами и calibration rubric
#### Case studies и упражнения с эталонным разбором для добавления

---

# Часть XVII. Code review, documentation и knowledge sharing

## 80. Code review
### 80.1. Корректность
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 80.2. Архитектура
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 80.3. Security
#### Модель угроз и защищаемые assets
#### Механизмы платформы и entitlement surface
#### Жизненный цикл данных, retention и deletion behavior
#### Ограничения logging, analytics и crash reporting
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 80.4. Performance
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview/incident-review Q&A с ответами
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 81.2. Что не документировать
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 81.3. Комментарии об ownership
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 81.4. Комментарии о side effects
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 81.5. API contracts
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 81.7. Устаревание документации
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

## 82. Project documentation
### 82.1. README
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 82.6. Onboarding-документация
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

---

# Часть XVIII. Product engineering и requirements

## 83. Product requirements
### 83.1. Критерии приёмки
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 83.2. Non-goals
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 83.3. Пограничные случаи
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 83.4. Разрешение неоднозначностей
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 83.5. Product tradeoff-ы
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

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
#### Примеры, упражнения и Q&A с ответами для добавления
### 84.3. Технические milestones
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления

## 85. Experimentation
### 85.1. Feature flags
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 85.4. Kill switches
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 85.5. Этичные эксперименты
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

---

# Часть XIX. Debugging mastery

## 86. Debugging mental models
### 86.1. Воспроизведение
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 86.2. Минимальный repro
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 86.3. Детерминизм
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления

## 87. LLDB
### 87.1. Breakpoints
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 87.2. Условные breakpoints
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 87.3. Watchpoints
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 87.4. Вычисление expressions
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления

## 88. Log-driven debugging
### 88.1. Correlation IDs
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 88.2. Redacted context
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 88.3. Breadcrumbs
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 88.4. Support logs
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 88.5. Debugging без утечки пользовательских данных
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

---

# Часть XX. Практические case studies

## 89. Case study news/feed app
### 89.1. Требования
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления

## 90. Case study auth/session
### 90.1. Login
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 90.2. Хранение token
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 90.4. Logout
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 90.5. Восстановление session
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 90.6. Security-ревью
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 91.3. Разрешение конфликтов
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 91.4. Retry/backoff
#### Контракт и ownership данных
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
#### Примеры, упражнения и Q&A с ответами для добавления

## 92. Case study modularization большого приложения
### 92.1. Исходный монолит
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 92.4. Производительность сборки
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview/incident-review Q&A с ответами
### 92.5. Командный ownership
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления

---

# Часть XXI. Interview и calibration materials

## 93. Темы Senior iOS interview
### 93.1. Swift
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
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
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 93.4. Архитектура
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 93.5. Networking
#### Контракт и ownership данных
#### Request/response и правила mapping
#### Failure, retry, cancellation и idempotency behavior
#### Offline, cache и persistence-последствия
#### Security, privacy и logging-ограничения
#### Test matrix и production diagnostics
### 93.6. Persistence
#### Контракт и ownership данных
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
#### Interview/incident-review Q&A с ответами

## 94. Темы Lead / Staff interview
### 94.1. System design
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 94.2. Архитектура ревью
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
#### Review Q&A с ответами и calibration rubric
#### Case studies и упражнения с эталонным разбором для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления
### 94.6. Влияние между командами
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review Q&A с ответами и calibration rubric
#### Case studies и упражнения с эталонным разбором для добавления

## 95. Банк вопросов
### 95.1. Теоретические вопросы
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 95.2. Практические вопросы по коду
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 95.3. Сценарии debugging
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
#### Примеры, упражнения и Q&A с ответами для добавления

## 96. Рубрики оценки ответов
### 96.1. Ответ Junior
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 96.2. Ответ Middle
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 96.3. Ответ Senior
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 96.4. Ответ Staff
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review Q&A с ответами и calibration rubric
#### Case studies и упражнения с эталонным разбором для добавления
### 96.5. Red flags
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления

---

# Часть XXII. Приложения

## 97. Чеклисты
### 97.1. Чеклист готовности feature
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 97.2. Чеклист PR
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 97.3. Чеклист релиза
#### Operational goal и ownership
#### Build, signing и environment constraints
#### Telemetry, logging и alerting signals
#### Rollout, rollback и incident workflow
#### Compliance и support handoff checklist
#### Runbook-примеры для добавления
### 97.4. Чеклист архитектура ревью
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 97.5. Чеклист security
#### Модель угроз и защищаемые assets
#### Механизмы платформы и entitlement surface
#### Жизненный цикл данных, retention и deletion behavior
#### Ограничения logging, analytics и crash reporting
#### Review checklist и incident response
#### Примеры и adversarial questions для добавления
### 97.6. Чеклист performance
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview/incident-review Q&A с ответами
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
#### Review Q&A с ответами и calibration rubric
#### Case studies и упражнения с эталонным разбором для добавления
### 98.2. Шаблон RFC
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
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
### 98.6. Шаблон архитектура ревью
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
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 99.2. Термины платформы iOS
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review Q&A с ответами и calibration rubric
#### Case studies и упражнения с эталонным разбором для добавления
### 99.3. Архитектурные термины
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 99.4. Термины networking
#### Контракт и ownership данных
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
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 100.2. Спроектировать offline sync
#### Контракт и ownership данных
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
#### Interview/incident-review Q&A с ответами
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
#### Review Q&A с ответами и calibration rubric
#### Case studies и упражнения с эталонным разбором для добавления
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
