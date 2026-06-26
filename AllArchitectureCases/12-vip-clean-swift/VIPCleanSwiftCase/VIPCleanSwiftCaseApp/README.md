# VIPCleanSwiftCase App Source

This folder contains the app source for the VIP / Clean Swift architecture case.

## Scene Role Direction
- `*Screen` and component views render state and forward user intent.
- `*Interactor` types own scene state, async lifecycle, business/data orchestration, and route requests.
- `*Presenter` types format domain/error data into view state only.
- `*Worker` types own repository, persistence, and local interaction I/O.
- Routers own navigation paths only.

Do not add empty VIP roles or remove behavior/design to fit the architecture label.
