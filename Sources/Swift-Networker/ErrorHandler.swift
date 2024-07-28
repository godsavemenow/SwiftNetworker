//
//  File.swift
//  
//
//  Created by Lucas Silva on 28/07/24.
//

import Foundation

public class ErrorHandler {
    
    public init() {}
    
    func handle(_ error: Error?, response: URLResponse?) -> NetworkError {
        if let error = error as? URLError {
            switch error.code {
            case .timedOut:
                return .timeOut
            case .cannotFindHost, .cannotConnectToHost, .unsupportedURL, .badURL:
                return .invalidURL
            case .cancelled:
                return .requestCanceled("The request was canceled.")
            default:
                return .networkError(error)
            }
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            if HTTPStatusCode.isClientError(httpResponse.statusCode) {
                return handleClientError(httpResponse.statusCode)
            } else if HTTPStatusCode.isServerError(httpResponse.statusCode) {
                return handleServerError(httpResponse.statusCode)
            }
        }

        if let error = error {
            return .unknown(error)
        } else {
            return .unknown(NSError(domain: "", code: -1, userInfo: nil))
        }
    }

    
    func handleClientError(_ statusCode: Int) -> NetworkError {
        if let status = HTTPStatusCode.from(statusCode) {
            switch status {
            case .badRequest:
                return .badRequest("The request was malformed or contained invalid parameters.")
            case .unauthorized:
                return .unauthorized("Authentication is required and has failed or has not yet been provided.")
            case .forbidden:
                return .forbidden("The server understood the request but refuses to authorize it.")
            case .notFound:
                return .notFound("The requested resource could not be found.")
            default:
                return .unknown(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Client error with status code \(statusCode)."]))
            }
        }
        return .unknown(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Client error with status code \(statusCode)."]))
    }

    func handleServerError(_ statusCode: Int) -> NetworkError {
        if let status = HTTPStatusCode.from(statusCode) {
            switch status {
            case .internalServerError:
                return .serverError("The server encountered an internal error and was unable to complete your request.")
            case .notImplemented:
                return .serverError("The server does not support the functionality required to fulfill the request.")
            case .badGateway:
                return .serverError("The server received an invalid response from the upstream server.")
            case .serviceUnavailable:
                return .serverError("The server is currently unable to handle the request due to temporary overload or maintenance.")
            default:
                return .unknown(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error with status code \(statusCode)."]))
            }
        }
        return .unknown(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error with status code \(statusCode)."]))
    }

    
}
