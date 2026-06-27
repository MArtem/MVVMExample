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
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 1.9. Скрытая стоимость поддержки старых версий iOS
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 1.10. Стратегия освоения платформы уровня Staff
#### Decision context и stakeholders
#### Technical tradeoff и organizational impact
#### Governance artifact или process to produce
#### Escalation, alignment и communication risks
#### Review Q&A с ответами и calibration rubric
#### Case studies и упражнения с эталонным разбором для добавления

## 2. App lifecycle и поведение процесса
### 2.1. Холодный запуск
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview/incident-review Q&A с ответами
### 2.2. Тёплый запуск
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview/incident-review Q&A с ответами
### 2.3. Активация foreground
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 2.4. Переход в background
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 2.5. Приостановка и завершение
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 2.6. Жизненный цикл scene
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 2.7. Поведение multi-window
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 2.8. Восстановление состояния
#### Rendering и lifecycle model
#### Граница ownership состояния
#### Layout, invalidation и performance-риски
#### Accessibility и localization-соображения
#### Failure cases и debugging workflow
#### Примеры, previews и упражнения для добавления
### 2.9. Стоимость графа зависимостей во время запуска
#### Ответственности ролей
#### Направление зависимостей и ownership boundaries
#### Размещение состояния, side effects и navigation
#### Tradeoff-ы, failure modes и стоимость миграции
#### Review-чеклист и антипаттерны
#### Упражнения по reference implementation
### 2.10. Под капотом: dyld, загрузка Swift metadata и static initializers
#### Определение и mental model
#### Синтаксис и API surface
#### Compiler и runtime-механика
#### Edge cases и неочевидное поведение
#### Production-ловушки и review Q&A с ответами
#### Примеры и упражнения для добавления
### 2.11. Под капотом: main run loop и путь запуска приложения
#### Scope и prerequisites
#### Core theory и mental model
#### Подкапотные детали
#### Production-правила и ловушки
#### Примеры, упражнения и Q&A с ответами для добавления
### 2.12. Чеклист production-ready запуска
#### Performance budget и measurement target
#### Instrumentation setup и trace interpretation
#### Hot-path риски и static red flags
#### Optimization tradeoff-ы и regression guardrails
#### Примеры before/after validation
#### Interview/incident-review Q&A с ответами

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
