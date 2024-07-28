//
//  File.swift
//  
//
//  Created by Lucas Silva on 28/07/24.
//

import Foundation

public struct Response <T: Decodable> {
    let networkResponse: NetworkResponse
    let decodedResponse: T
}
