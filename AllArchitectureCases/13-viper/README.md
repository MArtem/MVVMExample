# VIPERArchitectureCase

A standalone iOS project demonstrating a compact, non-empty VIPER module.

## Architecture
The sample module is `ArticleList` and uses VIPER responsibilities:

- **View**: renders presenter state and forwards user intent.
- **Interactor**: owns business/data retrieval for deterministic sample articles.
- **Presenter**: coordinates loading, selection, and presentation mapping.
- **Entity**: represents domain data used by the module.
- **Router**: owns navigation route state and destination construction.
- **Builder**: assembles the module dependencies.

## Verification

```zsh
./scripts/verify.sh list
./scripts/verify.sh build
./scripts/verify.sh test
```
