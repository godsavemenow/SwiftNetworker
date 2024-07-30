import XCTest
@testable import SwiftNetworker

class NetworkCacheTests: XCTestCase {
    
    var networkCache: NetworkCache!
    var testURL: String!
    var testResponse: NetworkResponse!
    
    override func setUp() {
        super.setUp()
        networkCache = NetworkCache(expirationInterval: 1) // Set a short expiration interval for testing
        testURL = "https://example.com"
        let data = "Test Data".data(using: .utf8)!
        let url = URL(string: testURL)!
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        testResponse = NetworkResponse(data: data, URLResponse: urlResponse)
    }

    override func tearDown() {
        networkCache = nil
        testURL = nil
        testResponse = nil
        super.tearDown()
    }

    func testCacheResponse() {
        networkCache.cacheResponse(testResponse, for: testURL)
        
        let cachedResponse = networkCache.getCachedResponse(for: testURL)
        XCTAssertNotNil(cachedResponse)
        XCTAssertEqual(cachedResponse?.data, testResponse.data)
        XCTAssertEqual(cachedResponse?.URLResponse.url, testResponse.URLResponse.url)
    }
    
    func testCacheResponseExpiration() {
        networkCache.cacheResponse(testResponse, for: testURL)
        
        // Wait for the expiration interval to pass
        sleep(2)
        
        let cachedResponse = networkCache.getCachedResponse(for: testURL)
        XCTAssertNil(cachedResponse)
    }
    
    func testCacheResponseWithoutExpiration() {
        networkCache = NetworkCache(expirationInterval: 3600) // Set a longer expiration interval
        
        networkCache.cacheResponse(testResponse, for: testURL)
        
        let cachedResponse = networkCache.getCachedResponse(for: testURL)
        XCTAssertNotNil(cachedResponse)
        XCTAssertEqual(cachedResponse?.data, testResponse.data)
        XCTAssertEqual(cachedResponse?.URLResponse.url, testResponse.URLResponse.url)
    }
}

