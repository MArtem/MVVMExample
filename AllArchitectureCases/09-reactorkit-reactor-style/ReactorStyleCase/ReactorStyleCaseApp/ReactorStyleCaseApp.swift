import SwiftUI

/// Struct contract for a local app boundary.
///
/// Document ownership and side effects here when this type grows beyond value-only data.
@main
struct ReactorStyleCase: App {
    @State private var rootCoordinator = AppRootCoordinator(
        dependencies: AppDependencies.live()
    )

    var body: some Scene {
        WindowGroup {
            AppRootView(coordinator: rootCoordinator)
        }
    }
}
