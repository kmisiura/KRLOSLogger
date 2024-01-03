import XCTest
@testable import OSLogger

final class LogTests: XCTestCase {
    func testDisplay() {
        Log.critical("critical")
        Log.error("error")
        Log.warning("warning")
        Log.info("info")
        Log.debug("debug")
        Log.verbose("verbose")
        XCTAssert(true)
    }

    static var allTests = [
        ("testDisplay", testDisplay),
    ]
}
