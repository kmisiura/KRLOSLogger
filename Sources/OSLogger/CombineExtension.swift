import Combine
import Foundation
 
@available(macOS 10.15, iOS 13.0, *)
public extension Publisher {
    
    func log(_ level: Log.Level,
             message: String = "",
             file: String = #file,
             line: Int = #line,
             column: Int = #column,
             funcName: String = #function) -> Publishers.HandleEvents<Self> {
        
        handleEvents(receiveOutput: { (value) in
            switch level {
                case .verbose:
                    Log.verbose(message + " \(value)", file: file, line: line, column: column, funcName: funcName)
                case .debug:
                    Log.debug(message + " \(value)", file: file, line: line, column: column, funcName: funcName)
                case .info:
                    Log.info(message + " \(value)", file: file, line: line, column: column, funcName: funcName)
                case .warning:
                    Log.warning(message + " \(value)", file: file, line: line, column: column, funcName: funcName)
                case .error:
                    Log.error(message + " \(value)", file: file, line: line, column: column, funcName: funcName)
                case .exception:
                    Log.exception(message + " \(value)", file: file, line: line, column: column, funcName: funcName)
            }
        })
    }
    
    func logError(message: String = "",
                  file: String = #file,
                  line: Int = #line,
                  column: Int = #column,
                  funcName: String = #function) -> Publishers.HandleEvents<Self> {
        
        handleEvents ( receiveCompletion: { (completion) in
            if case .failure(let error) = completion {
                Log.error(message + " \(error)", file: file, line: line, column: column, funcName: funcName)
            }
        })
    }
}
