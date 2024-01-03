import XCTest
@testable import OSLogger

final class LogStorageTests: XCTestCase {
    
    var logStorage: LogStorage!
    
    override func setUp() {
        logStorage = LogStorage()
    }
    
    override func tearDownWithError() throws {
//        let storage = try logStorage.logStorageDirURL()
//        try FileManager.default.removeItem(at: storage)
//        logStorage = nil
    }
    
    func testWrite() {
        let timestamp = Date().timeIntervalSince1970
        logStorage.log(message: "message", timestamp: timestamp)
        var url: URL? = nil
        XCTAssertNoThrow(url = try logStorage.currentLogURL())
        XCTAssertNotNil(url)
        logStorage.forceFlushLog()
        
        sleep(1) /// Sleeping, because write is async.
        
        var savedFile: String? = nil
        XCTAssertNoThrow(savedFile = try String(contentsOf: url!, encoding: .utf8))
        XCTAssertNotNil(savedFile)
        XCTAssertEqual(savedFile, "\(timestamp) message")
    }
    
    func testAutoFlush() {
        let timestamp = Date().timeIntervalSince1970
        for i in 0...21 {
            logStorage.log(message: "\(i)", timestamp: timestamp)
        }
        XCTAssertEqual(logStorage.currentBuffer().count, 1)
    }
    
    func testLoadLatest() {
        logStorage.log(message: "first", timestamp: 111.0)
        logStorage.forceFlushLog()
        
        sleep(1) /// Sleeping, because write is async.
        
        logStorage = LogStorage()
        logStorage.log(message: "second", timestamp: 222.0)
        logStorage.forceFlushLog()
        
        sleep(1) /// Sleeping, because write is async.
        
        let log = logStorage.currentLog()
        XCTAssertNotNil(log)
        XCTAssertEqual(log, "222.0 second")
    }
    
    func testLoadAll() {
        logStorage.log(message: "first", timestamp: 111.0)
        logStorage.forceFlushLog()
        
        sleep(1) /// Sleeping, because write is async.
        
        logStorage = LogStorage()
        logStorage.log(message: "second", timestamp: 222.0)
        logStorage.forceFlushLog()
        
        sleep(1) /// Sleeping, because write is async.
        
        let logsDir = logStorage.directoryWithLogs()
        XCTAssertNotNil(logsDir)
        
        var logs: [String] = []
        XCTAssertNoThrow(logs = try FileManager.default.contentsOfDirectory(atPath: logsDir!.path))
        XCTAssertNotNil(logs)
        for log in logs {
            var reacable: Bool = false
            XCTAssertNoThrow(reacable = try logsDir!.appendingPathComponent(log, isDirectory: false).checkResourceIsReachable())
            XCTAssertTrue(reacable)
        }
    }
    
    static var allTests = [
        ("testWrite", testWrite),
    ]
}
