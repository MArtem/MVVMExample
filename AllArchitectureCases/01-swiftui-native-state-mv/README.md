# SwiftUINativeStateCase

A full functional architecture-case clone that preserves the app behavior and design while using a SwiftUI Native State / MV ownership style.

## Verification

```zsh
./scripts/verify.sh list
./scripts/verify.sh build
./scripts/verify.sh test-build
```

Runtime simulator test lanes remain explicit.


## Semantic Ownership Clarification
This case intentionally demonstrates **SwiftUI Native State / MV with screen lifecycle models**, not a pure no-owner toy MV variant. SwiftUI views still own rendering and local UI composition, while lightweight `*Model` objects own async lifecycle, cancellation, pagination, persistence reconciliation, and navigation callbacks needed to preserve the full app behavior. These models must not be treated as generic MVVM `ViewModel` boilerplate or as permission to add `send(_:)`/action-enum APIs; they are bounded lifecycle owners for screens whose behavior would otherwise be duplicated in SwiftUI `body` code.
