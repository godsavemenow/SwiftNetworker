import Foundation

/// A protocol defining the methods for logging network requests, responses, and errors.
protocol LoggerProtocol {
    func logRequest(_ request: URLRequest)
    func logResponse(_ response: NetworkResponse)
    func logResponse(_ title: String, message: String)
    func logError(_ error: NetworkError)
}
