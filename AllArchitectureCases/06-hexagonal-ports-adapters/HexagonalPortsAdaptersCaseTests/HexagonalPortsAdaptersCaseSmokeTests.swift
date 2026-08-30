import Testing
@testable import HexagonalPortsAdaptersCase

@Suite("HexagonalPortsAdaptersCase test target smoke tests")
struct HexagonalPortsAdaptersCaseSmokeTests {
    @Test("App unit test target can import HexagonalPortsAdaptersCase")
    func appUnitTestTargetCanImportHexagonalPortsAdaptersCase() {
        #expect(AppTab.news != AppTab.profile)
    }
}
