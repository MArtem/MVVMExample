import Testing
@testable import ExplicitIntentMVVMCase

@Suite("ExplicitIntentMVVMCase test target smoke tests")
struct ExplicitIntentMVVMCaseSmokeTests {
    @Test("App unit test target can import ExplicitIntentMVVMCase")
    func appUnitTestTargetCanImportExplicitIntentMVVMCase() {
        #expect(AppTab.news != AppTab.profile)
    }
}
