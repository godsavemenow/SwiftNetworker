import XCTest
@testable import SwiftNetworker

class NetworkResponseTests: XCTestCase {

    func testNetworkResponseInitialization() {
        let data = "Test Data".data(using: .utf8)!
        let url = URL(string: "https://example.com")!
        let urlResponse = URLResponse(url: url, mimeType: nil, expectedContentLength: data.count, textEncodingName: nil)
        
        let networkResponse = NetworkResponse(data: data, URLResponse: urlResponse)
        
        XCTAssertEqual(networkResponse.data, data)
        XCTAssertEqual(networkResponse.URLResponse.url, url)
        XCTAssertEqual(Int(networkResponse.URLResponse.expectedContentLength) as Int, data.count)
    }
    
    func testNetworkResponseInitializationWithDifferentURLResponse() {
        let data = "Another Test Data".data(using: .utf8)!
        let url = URL(string: "https://example.org")!
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        let networkResponse = NetworkResponse(data: data, URLResponse: urlResponse)
        
        XCTAssertEqual(networkResponse.data, data)
        XCTAssertEqual(networkResponse.URLResponse.url, url)
        XCTAssertEqual((networkResponse.URLResponse as? HTTPURLResponse)?.statusCode, 200)
    }
}
