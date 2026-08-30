# SwiftUINativeStateCase

Полный SwiftUI demo-проект под iOS 17+.

## Как запустить

1. В Xcode создай новый проект: **iOS App**, SwiftUI, Swift.
2. Назови его `SwiftUINativeStateCase`.
3. Удали стандартный `ContentView.swift`.
4. Перетащи папку `SwiftUINativeStateCase` из этого архива в проект.
5. Убедись, что все `.swift` файлы добавлены в app target.
6. Запусти.

## Демо-логин DummyJSON

- username: `emilys`
- password: `emilyspass`

## Архитектура

- AppRootCoordinator: auth gate login/main app.
- MainCoordinator: selected tab + tab routers.
- NewsRouter/ProfileRouter: typed route navigation through NavigationPath.
- SwiftUI Native State / MV.
- DTO -> Mapper -> Domain -> Repository -> Model -> ViewState -> View.
- View не знает DTO/API/Repository.
- Model @MainActor.
- API/Data layer не @MainActor.
- Navigation payloads are structs.
