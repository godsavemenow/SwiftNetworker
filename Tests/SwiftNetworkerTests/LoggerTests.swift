import XCTest
@testable import SwiftNetworker

class LoggerTests: XCTestCase {

    func testLogRequest() {
        let expectation = self.expectation(description: "LogOutput")
        let logger = Logger(logLevel: .info, isSilent: false) { logMessage in
            XCTAssertTrue(logMessage.contains("--- Request ---"))
            XCTAssertTrue(logMessage.contains("Method: GET"))
            XCTAssertTrue(logMessage.contains("URL: https://example.com"))
            expectation.fulfill()
        }
        
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.httpMethod = "GET"
        logger.logRequest(request)
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testLogRequestSilent() {
        let logger = Logger(logLevel: .info, isSilent: true) { logMessage in
            XCTFail("Log should not be produced in silent mode")
        }
        
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.httpMethod = "GET"
        logger.logRequest(request)
        
        // Wait for a short period to ensure no log is produced
        let exp = expectation(description: "Silent")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.2)
    }
    
    func testLogResponse() {
        let expectation = self.expectation(description: "LogOutput")
        let logger = Logger(logLevel: .info, isSilent: false) { logMessage in
            XCTAssertTrue(logMessage.contains("--- Response ---"))
            XCTAssertTrue(logMessage.contains("URL: https://example.com"))
            XCTAssertTrue(logMessage.contains("Status Code: 200"))
            XCTAssertTrue(logMessage.contains("Body: Test Response Body"))
            expectation.fulfill()
        }
        
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let response = NetworkResponse(data: "Test Response Body".data(using: .utf8)!, URLResponse: urlResponse)
        logger.logResponse(response)
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testLogResponseSilent() {
        let logger = Logger(logLevel: .info, isSilent: true) { logMessage in
            XCTFail("Log should not be produced in silent mode")
        }
        
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let response = NetworkResponse(data: "Test Response Body".data(using: .utf8)!, URLResponse: urlResponse)
        logger.logResponse(response)
        
        // Wait for a short period to ensure no log is produced
        let exp = expectation(description: "Silent")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.2)
    }

    func testLogError() {
        let expectation = self.expectation(description: "LogOutput")
        let logger = Logger(logLevel: .error, isSilent: false) { logMessage in
            XCTAssertTrue(logMessage.contains("--- Error ---"))
            XCTAssertTrue(logMessage.contains("Description: Bad Request: The request could not be understood by the server. - Bad request error message from API."))
            
            expectation.fulfill()
        }
        
        let error = NetworkError.mockBadRequest
        logger.logError(error)
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testLogErrorSilent() {
        let logger = Logger(logLevel: .error, isSilent: true) { logMessage in
            XCTFail("Log should not be produced in silent mode")
        }
        
        let error = NetworkError.mockBadRequest
        logger.logError(error)
        
        // Wait for a short period to ensure no log is produced
        let exp = expectation(description: "Silent")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.2)
    }
}
