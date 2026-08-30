import Testing
@testable import CleanLayeredCase

@Suite("CleanLayeredCase test target smoke tests")
struct CleanLayeredCaseSmokeTests {
    @Test("App unit test target can import CleanLayeredCase")
    func appUnitTestTargetCanImportCleanLayeredCase() {
        #expect(AppTab.news != AppTab.profile)
    }
}
