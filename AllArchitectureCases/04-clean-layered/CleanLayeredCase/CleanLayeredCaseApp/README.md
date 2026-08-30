# CleanLayeredCase

Полный SwiftUI demo-проект под iOS 17+.

## Как запустить

1. В Xcode создай новый проект: **iOS App**, SwiftUI, Swift.
2. Назови его `CleanLayeredCase`.
3. Удали стандартный `ContentView.swift`.
4. Перетащи папку `CleanLayeredCase` из этого архива в проект.
5. Убедись, что все `.swift` файлы добавлены в app target.
6. Запусти.

## Демо-логин DummyJSON

- username: `emilys`
- password: `emilyspass`

## Архитектура

- AppRootCoordinator: auth gate login/main app.
- MainCoordinator: selected tab + tab routers.
- NewsRouter/ProfileRouter: typed route navigation through NavigationPath.
- Feature-based MVVM.
- DTO -> Mapper -> Domain -> Repository -> ViewModel -> ViewState -> View.
- View не знает DTO/API/Repository.
- ViewModel @MainActor.
- API/Data layer не @MainActor.
- Navigation payloads are structs.
