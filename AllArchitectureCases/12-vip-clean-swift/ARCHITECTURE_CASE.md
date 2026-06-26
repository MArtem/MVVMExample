# VIP / Clean Swift Architecture Case

## Project
`VIPCleanSwiftCase`

## Goal
Full functional clone of the source app using a pragmatic VIP / Clean Swift architecture adapted for SwiftUI.

## Current Status
- [x] Full app functionality/design baseline copied into a standalone project name.
- [x] Source app and previous-case identities removed from active app/test/docs surfaces.
- [x] Feature presentation ownership converted to Clean Swift scene roles.
- [x] Build verified after conversion.

## VIP / Clean Swift Target State
Each feature scene uses the roles only where they have real work:
- **View**: SwiftUI screen/components render state and forward user intents only.
- **Interactor**: observable scene owner for business flow, async tasks, state transitions, cancellation, optimistic updates, and route requests.
- **Presenter**: format-only mapper from domain/error data to `*ViewState`; no repository, persistence, navigation, or async ownership.
- **Router**: navigation path and destination routing only.
- **Worker**: repository, persistence, and local interaction I/O used by an interactor.
- **Request / Response / view-state roles**: represented only where the existing product already has meaningful request/view-state contracts (`UpdateProfileRequest`, `NewsPageRequest`, and `*ViewState`). No empty pass-through request/response wrappers are added.

## Implemented Mapping
- **Auth**: `LoginScreen` forwards user intents to `LoginInteractor`; `LoginWorker` owns auth repository calls.
- **News list**: `NewsListInteractor` owns pagination, refresh, navigation intent, optimistic like state, and cancellation; `NewsListPresenter` formats cards/pagination/error view state; `NewsListWorker` owns repository and interaction-store access.
- **News detail**: `NewsDetailInteractor` owns detail loading and favorite mutation flow; `NewsDetailPresenter` formats detail states; `NewsDetailWorker` owns repository and interaction-store access.
- **Profile**: `ProfileInteractor` owns profile loading/edit/logout intents; `ProfilePresenter` formats profile states; `ProfileWorker` owns session-bound profile loading.
- **Profile edit**: `ProfileEditInteractor` owns edit transaction/save/cancel; `ProfileEditWorker` owns profile mutation I/O.
- **Routers**: `NewsRouter` and `ProfileRouter` keep navigation-only responsibilities.

## Stop Rules
- Do not add empty Clean Swift ceremony, pass-through request/response structs, or decorative protocols.
- Do not move formatting into interactors when a presenter can format it without owning side effects.
- Do not let presenters call repositories, persistence, or routers.
- Do not let routers perform business/data work.
- Do not remove source app behavior/design to make the case simpler.
