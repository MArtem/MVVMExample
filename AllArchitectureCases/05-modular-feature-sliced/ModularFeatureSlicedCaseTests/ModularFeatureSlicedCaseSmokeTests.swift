import Testing
@testable import ModularFeatureSlicedCase

@Suite("ModularFeatureSlicedCase test target smoke tests")
struct ModularFeatureSlicedCaseSmokeTests {
    @Test("App unit test target can import ModularFeatureSlicedCase")
    func appUnitTestTargetCanImportModularFeatureSlicedCase() {
        #expect(AppTab.news != AppTab.profile)
    }
}
