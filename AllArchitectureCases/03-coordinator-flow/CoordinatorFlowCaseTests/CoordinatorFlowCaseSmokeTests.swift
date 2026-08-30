import Testing
@testable import CoordinatorFlowCase

@Suite("CoordinatorFlowCase test target smoke tests")
struct CoordinatorFlowCaseSmokeTests {
    @Test("App unit test target can import CoordinatorFlowCase")
    func appUnitTestTargetCanImportCoordinatorFlowCase() {
        #expect(AppTab.news != AppTab.profile)
    }
}
