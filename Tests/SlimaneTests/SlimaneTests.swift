import XCTest
@testable import Slimane

class SlimaneTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        //XCTAssertEqual(Slimane().text, "Hello, World!")
    }


    static var allTests : [(String, (SlimaneTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
