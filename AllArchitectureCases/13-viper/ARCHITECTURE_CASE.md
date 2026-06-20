# VIPER Architecture Case

## Project
`VIPERArchitectureCase`

## Target Architecture
VIPER: View / Interactor / Presenter / Entity / Router / Builder.

## Conversion Status
- [x] Removed source-app project naming from this case.
- [x] Replaced copied baseline with standalone VIPER project files.
- [x] Added non-empty VIPER roles for the `ArticleList` module.
- [x] Build verified.
- [x] Tests verified.

## VIPER Gate
- Presenter owns presentation decisions and module coordination.
- Interactor owns deterministic data/business retrieval.
- Router owns route state and destination view construction.
- Builder owns assembly.
- View renders state and forwards user intent only.
- No empty pass-through role exists solely for ceremony.
