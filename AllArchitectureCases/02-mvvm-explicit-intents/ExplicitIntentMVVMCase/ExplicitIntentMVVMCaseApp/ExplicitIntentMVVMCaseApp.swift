import SwiftUI

@main
struct ExplicitIntentMVVMCase: App {
    @State private var rootCoordinator = AppRootCoordinator(
        dependencies: AppDependencies.live()
    )

    var body: some Scene {
        WindowGroup {
            AppRootView(coordinator: rootCoordinator)
        }
    }
}
