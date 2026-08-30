import Testing
@testable import ReactorStyleCase

@Suite("ReactorStyleCase test target smoke tests")
struct ReactorStyleCaseSmokeTests {
    @Test("App unit test target can import ReactorStyleCase")
    func appUnitTestTargetCanImportReactorStyleCase() {
        #expect(AppTab.news != AppTab.profile)
    }
}
