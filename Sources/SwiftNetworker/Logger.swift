import Foundation

/// A logger class to log network requests, responses, and errors.
///
/// ## Overview
/// The `Logger` class provides a flexible and configurable mechanism for logging various aspects of network operations, including requests,
/// responses, and errors. It conforms to the `LoggerProtocol` and includes methods for logging network-related activities with different
/// log levels such as info, debug, and error. The logging behavior can be customized using the log level, silent mode, and a custom log output
/// closure.
///
/// This class is designed to help developers monitor and debug network interactions by providing detailed logs of HTTP requests and responses.
/// It can be easily integrated into network-related code and provides a simple API for logging.
///
/// ## Usage
/// To use the `Logger`, create an instance of the class and configure it with the desired log level, silent mode, and log output. Then,
/// call the appropriate logging methods to log requests, responses, and errors.
///
/// ```swift
/// let logger = Logger(logLevel: .debug, isSilent: false) { logMessage in
///     // Custom log output, e.g., write to a file
///     print(logMessage)
/// }
/// logger.logRequest(request)
/// logger.logResponse(response)
/// logger.logError(networkError)
/// ```
///
public class Logger: LoggerProtocol {
    
    /// Enum representing the log level.
    public enum LogLevel {
        case info, debug, error
    }
    
    private let logLevel: LogLevel
    private let isSilent: Bool
    private let logOutput: (String) -> Void
    
    /// Initializes a new logger instance.
    ///
    /// - Parameters:
    ///   - logLevel: The level of logging desired. Default is `.info`.
    ///   - isSilent: Boolean to determine if the logger should print. Default is `false`.
    ///   - logOutput: Closure to handle the log output. Default is `print`.
    public init(logLevel: LogLevel = .debug, isSilent: Bool = false, logOutput: @escaping (String) -> Void = { print($0) }) {
        self.logLevel = logLevel
        self.isSilent = isSilent
        self.logOutput = logOutput
    }

    /// Logs a network request.
    ///
    /// - Parameter request: The URL request to be logged.
    func logRequest(_ request: URLRequest) {
        guard !isSilent else { return }
        guard logLevel == .info || logLevel == .debug else { return }
        var logMessage = "\n--- Request ---\n"
        logMessage += "Method: \(request.httpMethod ?? "Unknown Method")\n"
        logMessage += "URL: \(request.url?.absoluteString ?? "Unknown URL")\n"
        if let headers = request.allHTTPHeaderFields {
            logMessage += "Headers: \(headers)\n"
        }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            logMessage += "Body: \(bodyString)\n"
        }
        logMessage += "---------------\n"
        logOutput(logMessage)
    }
    
    /// Logs a network response.
    ///
    /// - Parameter response: The network response to be logged.
    func logResponse(_ response: NetworkResponse) {
        guard !isSilent else { return }
        guard logLevel == .info || logLevel == .debug else { return }
        var logMessage = "\n--- Response ---\n"
        logMessage += "URL: \(response.URLResponse.url?.absoluteString ?? "Unknown URL")\n"
        if let httpResponse = response.URLResponse as? HTTPURLResponse {
            logMessage += "Status Code: \(httpResponse.statusCode)\n"
            logMessage += "Headers: \(httpResponse.allHeaderFields)\n"
        }
        if let responseString = String(data: response.data, encoding: .utf8) {
            logMessage += "Body: \(responseString)\n"
        }
        logMessage += "----------------\n"
        logOutput(logMessage)
    }
    
    func logResponse(_ title: String, message: String) {
        guard !isSilent else { return }
        guard logLevel != .error else { return }
        var logMessage = "\n--- \(title) ---\n"
        logMessage += "---- "
        logMessage += "\(message)"
        logMessage += " ----\n"
        logOutput(logMessage)
    }
    
    /// Logs a network error.
    ///
    /// - Parameter error: The network error to be logged.
    func logError(_ error: NetworkError) {
        guard !isSilent else { return }
        guard logLevel == .error || logLevel == .debug else { return }
        var logMessage = "\n--- Error ---\n"
        logMessage += "Description: \(error.detailedDescription)\n"
        logMessage += "-------------\n"
        logOutput(logMessage)
    }
}
