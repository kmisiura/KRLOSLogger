import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(LogTests.allTests),
        testCase(LogStorageTests.allTests),
    ]
}
#endif
