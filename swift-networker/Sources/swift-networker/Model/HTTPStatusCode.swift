//
//  HTTPStatusCode.swift
//  
//
//  Created by Lucas Silva on 28/07/24.
//

import Foundation

enum HTTPStatusCode: Int {
    case ok = 200
    case created = 201
    case accepted = 202
    case noContent = 204
    
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    
    case internalServerError = 500
    case notImplemented = 501
    case badGateway = 502
    case serviceUnavailable = 503

    static func from(_ statusCode: Int) -> HTTPStatusCode? {
        return HTTPStatusCode(rawValue: statusCode)
    }
    
    static func isSuccessful(_ statusCode: Int) -> Bool {
        return (200...299).contains(statusCode)
    }

    static func isClientError(_ statusCode: Int) -> Bool {
        return (400...499).contains(statusCode)
    }

    static func isServerError(_ statusCode: Int) -> Bool {
        return (500...599).contains(statusCode)
    }
}
