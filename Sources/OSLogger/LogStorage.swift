import Foundation

class LogStorage {
    
    static internal let bundleId = (Bundle.main.bundleIdentifier ?? "OSLogger")
    
    internal indirect enum Error: Swift.Error {
        case writeError(reason: String)
    }
    
    internal let workQueue = DispatchQueue(label: LogStorage.bundleId + ".LogStorage.BackgroundQueue", qos: .utility)
    internal let ioQueue = DispatchQueue(label: LogStorage.bundleId + ".LogStorage.IOQueue", qos: .utility)
    
    internal let currentLogName = "\(Date().timeIntervalSince1970).log"
    
    internal let dateFormatter = ISO8601DateFormatter()
    
    internal var flushTimer: Timer?
    
    private var logBuffer: [String] = []
    
    init() {
        ioQueue.async {
            self.rotateLogs()
        }
    }
    
    deinit {
        self.forceFlushLog()
    }
    
    func log(message: String, timestamp: Date) {
        setupTimerIfNeeded()
        workQueue.async { self.appendLog(message: message, timestamp: timestamp) }
    }
    
    func currentBuffer() -> [String] {
        var buffer: [String] = []
        workQueue.sync { buffer = self.logBuffer }
        return buffer
    }
    
    func currentLog() -> String? {
        var currentLog: String? = nil
        workQueue.sync {
            self.flushLog()
            do {
                let logUrl = try self.currentLogURL()
                try self.ioQueue.sync {
                    currentLog = try String(contentsOf: logUrl, encoding: .utf8)
                }
            } catch {
                Log.error("Failed to load current log with error \(error)")
            }
        }
        return currentLog
    }
    
    func directoryWithLogs() -> URL? {
        var logsDir: URL? = nil
        workQueue.sync {
            self.flushLog()
            self.ioQueue.sync {
                do {
                    logsDir = try self.logStorageDirURL()
                } catch {
                    Log.error("Failed to load log storage direcotry with error \(error)")
                }
            }
        }
        
        return logsDir
    }
    
    internal func setupTimerIfNeeded() {
        if flushTimer == nil {
            flushTimer = Timer(timeInterval: 3.0, repeats: true, block: { _ in
                self.workQueue.async {
                    self.flushLog()
                }
            })
        }
    }
    
    internal func appendLog(message: String, timestamp: Date) {
        self.logBuffer.append(dateFormatter.string(from: timestamp) + " " + message)
        if self.logBuffer.count > 20 {
            workQueue.async {
                self.flushLog()
            }
        }
    }
    
    internal func forceFlushLog() {
        workQueue.sync { [unowned self] in
            flushLog()
        }
    }
    
    private func flushLog() {
        guard !self.logBuffer.isEmpty else { return }
        let logs = self.logBuffer
        self.logBuffer.removeAll()
        self.ioQueue.sync {
            do {
                let writeUrl = try self.currentLogURL()
                try self.writeLog(logs, into: writeUrl)
            } catch {
                Log.error("Error while writing log \(error)")
            }
        }
    }
    
    internal func writeLog(_ log: [String], into fileURL: URL) throws {
        guard let data = log.joined(separator: "\n").data(using: String.Encoding.utf8) else {
            throw Error.writeError(reason: "Failed to create data out of log.")
        }
        
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer { fileHandle.closeFile() }
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
        } else {
            try data.write(to: fileURL, options: .atomic)
        }
    }
    
    internal func currentLogURL() throws -> URL {
        return try logStorageDirURL().appendingPathComponent(currentLogName, isDirectory: false)
    }
    
    internal func logStorageDirURL() throws -> URL {
        let fm = FileManager.default
        guard var appSupportURL = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw Error.writeError(reason: "Failed to get application support directory")
        }
        
        appSupportURL.appendPathComponent(LogStorage.bundleId, isDirectory: true)
        appSupportURL.appendPathComponent("LogStorage", isDirectory: true)
        
        try fm.createDirectory(at: appSupportURL,
                               withIntermediateDirectories: true,
                               attributes: nil)
        return appSupportURL
    }
    
    internal func rotateLogs() {
        do {
            let logStorageDirURL = try logStorageDirURL()
            let logs = try FileManager.default.contentsOfDirectory(at: logStorageDirURL,
                                                                   includingPropertiesForKeys: nil,
                                                                   options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
            let sorted = logs.sorted { lh, rh in
                return Double(lh.deletingPathExtension().lastPathComponent) ?? 0.0 >
                Double(rh.deletingPathExtension().lastPathComponent) ?? 0.0
            }
            
            if sorted.count > 20 {
                let markedForDeletion = sorted.suffix(from: 20)
                for url in markedForDeletion {
                    try FileManager.default.removeItem(at: url)
                }
            }
        } catch {
            Log.error("Failed to rotate logs with error \(error)")
        }
    }
}
