import XCTest
@testable import SharkCardScan

final class SharkCardScanTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SharkCardScan().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
