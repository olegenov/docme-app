import Foundation
import OSLog


enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

final class AppLogger {
    static let shared = AppLogger()

    
    private let logger = Logger()
    
    private init() { }
    
    func debug(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            message,
            level: .debug,
            file: file,
            function: function,
            line: line
        )
    }
    
    func info(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            message,
            level: .info,
            file: file,
            function: function,
            line: line
        )
    }
    
    func warning(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(
            message,
            level: .warning,
            file: file,
            function: function,
            line: line
        )
    }
    
    func error(
        _ message: String,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        var fullMessage = message
        
        if let error = error {
            fullMessage += " - Error: \(error.localizedDescription)"
        }
        
        log(
            fullMessage,
            level: .error,
            file: file,
            function: function,
            line: line
        )
    }
    
    private func log(
        _ message: String,
        level: LogLevel,
        file: String,
        function: String,
        line: Int
    ) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(level.rawValue)] [\(fileName):\(line)] \(function): \(message)"
        
        #if DEBUG
        print(logMessage)
        #endif
    }
}
