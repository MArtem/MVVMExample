import Testing
@testable import ReduxElmUDFCase

@Suite("ReduxElmUDFCase test target smoke tests")
struct ReduxElmUDFCaseSmokeTests {
    @Test("App unit test target can import ReduxElmUDFCase")
    func appUnitTestTargetCanImportReduxElmUDFCase() {
        #expect(AppTab.news != AppTab.profile)
    }
}
