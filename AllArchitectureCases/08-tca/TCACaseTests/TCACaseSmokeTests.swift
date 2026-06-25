import Testing
@testable import TCACase

@Suite("TCACase test target smoke tests")
struct TCACaseSmokeTests {
    @Test("App unit test target can import TCACase")
    func appUnitTestTargetCanImportTCACase() {
        #expect(AppTab.news != AppTab.profile)
    }
}
