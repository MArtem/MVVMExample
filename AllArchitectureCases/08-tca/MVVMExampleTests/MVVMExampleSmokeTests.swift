import Testing
@testable import MVVMExample

@Suite("MVVMExample test target smoke tests")
struct MVVMExampleSmokeTests {
    @Test("App unit test target can import MVVMExample")
    func appUnitTestTargetCanImportMVVMExample() {
        #expect(AppTab.news != AppTab.profile)
    }
}
