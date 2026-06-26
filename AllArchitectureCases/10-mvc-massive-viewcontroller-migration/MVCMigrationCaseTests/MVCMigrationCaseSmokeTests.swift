import Testing
@testable import MVCMigrationCase

@Suite("MVCMigrationCase test target smoke tests")
struct MVCMigrationCaseSmokeTests {
    @Test("App unit test target can import MVCMigrationCase")
    func appUnitTestTargetCanImportMVCMigrationCase() {
        #expect(AppTab.news != AppTab.profile)
    }
}
