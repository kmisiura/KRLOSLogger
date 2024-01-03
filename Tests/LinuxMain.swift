import XCTest

import LogTests

var tests = [XCTestCaseEntry]()
tests += LogTests.allTests()
tests += LogStorageTests.allTests()
XCTMain(tests)
