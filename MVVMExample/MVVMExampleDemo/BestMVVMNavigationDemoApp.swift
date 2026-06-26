import SwiftUI

/// Process entry point that installs the app dependency graph and root SwiftUI scene.
///
/// Ownership: created by the system once for the app process; keep launch-time composition here and move feature behavior into app/feature owners.
@main
struct MVVMExample: App {
    @State private var rootCoordinator = AppRootCoordinator(
        dependencies: AppDependencies.live()
    )

    var body: some Scene {
        WindowGroup {
            AppRootView(coordinator: rootCoordinator)
        }
    }
}
