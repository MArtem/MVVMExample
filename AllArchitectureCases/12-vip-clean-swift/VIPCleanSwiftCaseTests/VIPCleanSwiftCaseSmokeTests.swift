import Testing
@testable import VIPCleanSwiftCase

@Suite("VIPCleanSwiftCase test target smoke tests")
struct VIPCleanSwiftCaseSmokeTests {
    @Test("App unit test target can import VIPCleanSwiftCase")
    func appUnitTestTargetCanImportVIPCleanSwiftCase() {
        #expect(AppTab.news != AppTab.profile)
    }
}
