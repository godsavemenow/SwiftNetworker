import Foundation
/// A protocol for request interceptors that can modify a URLRequest before it is sent.
///
/// ## Overview
/// Request interceptors provide a way to modify `URLRequest` objects before they are sent over the network.
/// This can be used to add authentication headers, log requests, or modify the request in any other way.
///
/// ## Usage
/// Implement the `intercept(_:)` method to modify the request as needed.
///
/// ```swift
/// public class RequestInterceptor: RequestInterceptor {
///     private let token: String
///
///     public init(token: String) {
///         self.token = token
///     }
///
///     public func intercept(_ request: inout URLRequest) {
///         request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
///     }
/// }
/// ```
public protocol RequestInterceptorProtocol {
    /// Intercepts a URLRequest and modifies it as needed.
    ///
    /// - Parameter request: The URLRequest to be modified.
    func intercept(_ request: inout URLRequest)
}
