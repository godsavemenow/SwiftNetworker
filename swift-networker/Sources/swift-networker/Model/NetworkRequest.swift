//
//  File.swift
//  
//
//  Created by Lucas Silva on 28/07/24.
//

import Foundation

public struct NetworkRequest {
    public let url: URL
    public let method: HTTPMethod
    public let headers: [String: String]?
    public let body: Data?
    
    public init(url: URL, method: HTTPMethod, headers: [String: String]? = nil, body: Data? = nil) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }
}
