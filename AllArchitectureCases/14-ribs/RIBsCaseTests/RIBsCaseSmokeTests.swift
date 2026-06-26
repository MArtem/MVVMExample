import Testing
@testable import RIBsCase

@Suite("RIBsCase test target smoke tests")
struct RIBsCaseSmokeTests {
    @Test("App unit test target can import RIBsCase")
    func appUnitTestTargetCanImportRIBsCase() {
        #expect(AppTab.news != AppTab.profile)
    }
}
