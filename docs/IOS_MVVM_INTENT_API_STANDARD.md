# iOS MVVM Intent API Standard

## Purpose
Define the default ViewModel API shape for SwiftUI/UIKit MVVM projects.

This standard exists to prevent accidental reducer-style/event-bus architecture in projects that are intended to use clear MVVM boundaries.

## Default Rule
ViewModels expose **explicit intent methods**. Do not use a generic `send(_ action:)` dispatcher or a UI action enum as the default ViewModel API.

Preferred shape:

```swift
@MainActor
final class LoginViewModel {
    func usernameChanged(_ value: String)
    func passwordChanged(_ value: String)
    func loginTapped()
    func demoCredentialsTapped()
}
```

```swift
@MainActor
final class ArticlesViewModel {
    func appeared()
    func refreshRequested()
    func articleTapped(id: Article.ID)
    func likeTapped(id: Article.ID)
    func commentsTapped(id: Article.ID)
}
```

Avoid as a default:

```swift
func send(_ action: LoginAction)

enum LoginAction {
    case appeared
    case loginTapped
    case usernameChanged(String)
}
```

## Why
Explicit methods are the preferred default because they:

- make the public ViewModel contract readable without opening an action enum;
- keep call sites searchable and refactorable;
- avoid hiding unrelated flows behind one dispatcher;
- reduce boilerplate in simple and medium features;
- make reviews stricter: every public method must represent a product/user/system intent;
- avoid introducing reducer/event-bus architecture without a real need.

## Allowed Exception
A generic `send(_ action:)` / action enum style is allowed only when all conditions are true:

1. The user explicitly approves a reducer/unidirectional-flow architecture for that feature/project.
2. The action enum represents a real state-machine/event contract, not boilerplate around simple methods.
3. The decision is documented in an ADR or feature architecture note.
4. The review explains why explicit intent methods are insufficient.

## View Contract
Views should receive immutable state plus callbacks or a directly injected ViewModel only at the owning screen boundary.

Child views should normally receive:

```swift
struct ArticleCardView: View {
    let state: ArticleCardViewState
    let onOpen: () -> Void
    let onLike: () -> Void
    let onComments: () -> Void
}
```

Do not pass broad ViewModels into repeated rows when narrow state and callbacks are enough.

## Naming Rules
Use method names in the language of product/user/system intent:

- `loginTapped()`
- `refreshRequested()`
- `saveTapped()`
- `logoutTapped()`
- `appeared()`
- `searchQueryChanged(_:)`
- `articleTapped(id:)`
- `retryTapped()`

Avoid implementation-command names:

- `setLoadingTrue()`
- `callRepository()`
- `updateArray()`
- `dispatch(_:)`
- `handle(_:)` as the only public API

## Review Checklist
Before approving a ViewModel API, verify:

- Can a reviewer understand the feature's public behavior from method names alone?
- Are lifecycle, user, and system intents separated clearly?
- Is there one source of truth for state mutations?
- Are async methods cancellation-safe and stale-result-safe?
- Are child views using narrow state/callbacks instead of broad ViewModel references?
- If `send(_:)` exists, is there an explicit approved architecture reason?

## Stop Rules
- Do not introduce `func send(_ action:)` as default MVVM boilerplate.
- Do not create `FeatureAction` enums only to route simple button taps.
- Do not hide many unrelated flows behind `handle(_:)` or `dispatch(_:)` without a real state-machine reason.
- Do not keep prompt/article examples that recommend action enums as mandatory defaults; adapt them to explicit intents.
