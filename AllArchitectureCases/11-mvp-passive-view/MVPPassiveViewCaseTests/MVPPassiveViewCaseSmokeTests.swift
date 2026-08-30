import Testing
@testable import MVPPassiveViewCase

@Suite("MVPPassiveViewCase test target smoke tests")
struct MVPPassiveViewCaseSmokeTests {
    @Test("App unit test target can import MVPPassiveViewCase")
    func appUnitTestTargetCanImportMVPPassiveViewCase() {
        #expect(AppTab.news != AppTab.profile)
    }
}
