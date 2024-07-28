//
//  File.swift
//  
//
//  Created by Lucas Silva on 28/07/24.
//

import Foundation

public enum NetworkError: Error, CustomStringConvertible {
    case invalidURL
    case noData
    case timeOut
    case badRequest(String)
    case unauthorized(String)
    case forbidden(String)
    case notFound(String)
    case serverError(String)
    case parsingError(String)
    case requestCanceled(String)
    case decodingError(String)
    case networkError(Error)
    case unknown(Error)
    
    public var description: String {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .noData:
            return "No data was received from the server."
        case .timeOut:
            return "The request timed out."
        case .badRequest(let message):
            return "Bad Request: \(message)"
        case .unauthorized(let message):
            return "Unauthorized: \(message)"
        case .forbidden(let message):
            return "Forbidden: \(message)"
        case .notFound(let message):
            return "Not Found: \(message)"
        case .serverError(let message):
            return "Server Error: \(message)"
        case .parsingError(let message):
            return "Parsing Error: \(message)"
        case .requestCanceled(let message):
            return "Request Canceled: \(message)"
        case .decodingError(let message):
            return "Decoding Error: \(message)"
        case .networkError(let error):
            return "Network Error: \(error.localizedDescription)"
        case .unknown(let error):
            return "Unknown Error: \(error.localizedDescription)"

        }
    }
}
