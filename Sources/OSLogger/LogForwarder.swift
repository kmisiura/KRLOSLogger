import Foundation

public class LogForwarder {
    internal static var shared: LogForwarder? = nil
    
    internal var listeners: [LogListener]
    
    init(listeners: [LogListener]) {
        self.listeners = listeners
    }
    
    public static func setup(listeners: [LogListener]) {
        let forwarder = LogForwarder(listeners: listeners)
        LogForwarder.shared = forwarder
    }
}

public protocol LogListener {
    func log(object: Any?, level: Log.Level, file: String, line: Int, column: Int, funcName: String)
}
