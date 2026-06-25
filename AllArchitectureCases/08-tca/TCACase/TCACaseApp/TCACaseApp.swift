import SwiftUI

@main
struct TCACase: App {
    @State private var rootCoordinator = AppRootCoordinator(
        dependencies: AppDependencies.live()
    )

    var body: some Scene {
        WindowGroup {
            AppRootView(coordinator: rootCoordinator)
        }
    }
}
