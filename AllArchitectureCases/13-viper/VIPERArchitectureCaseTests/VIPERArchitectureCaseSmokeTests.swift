import Testing
@testable import VIPERArchitectureCase

@Suite("VIPERArchitectureCase test target smoke tests")
struct VIPERArchitectureCaseSmokeTests {
    @Test("App unit test target can import VIPERArchitectureCase")
    func appUnitTestTargetCanImportVIPERArchitectureCase() {
        #expect(AppTab.news != AppTab.profile)
    }
}
