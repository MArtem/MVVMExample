import Testing
@testable import SwiftUINativeStateCase

@Suite("SwiftUINativeStateCase test target smoke tests")
struct SwiftUINativeStateCaseSmokeTests {
    @Test("App unit test target can import SwiftUINativeStateCase")
    func appUnitTestTargetCanImportSwiftUINativeStateCase() {
        #expect(AppTab.news != AppTab.profile)
    }
}
