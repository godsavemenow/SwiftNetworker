import XCTest
@testable import SwiftNetworker

class MockLogger: LoggerProtocol {
    var loggedRequests = [URLRequest]()
    var loggedResponses = [NetworkResponse]()
    var loggedMessages = [(title: String, message: String)]()
    var loggedErrors = [NetworkError]()

    func logRequest(_ request: URLRequest) {
        loggedRequests.append(request)
    }

    func logResponse(_ response: NetworkResponse) {
        loggedResponses.append(response)
    }

    func logResponse(_ title: String, message: String) {
        loggedMessages.append((title: title, message: message))
    }

    func logError(_ error: NetworkError) {
        loggedErrors.append(error)
    }
}

class MockErrorHandler: ErrorHandlerProtocol {
    func handle(_ error: Error?, data: Data?, response: URLResponse?) -> NetworkError {
        return NetworkError(errorCase: .unknown(error ?? NSError(domain: "", code: 0, userInfo: nil)), apiErrorMessage: nil)
    }
}

class CommonsTests: XCTestCase {
    
    var mockLogger: MockLogger!
    var mockErrorHandler: MockErrorHandler!

    override func setUp() {
        super.setUp()
        mockLogger = MockLogger()
        mockErrorHandler = MockErrorHandler()
    }

    override func tearDown() {
        mockLogger = nil
        mockErrorHandler = nil
        super.tearDown()
    }

    func testHandleResponseSuccess() {
        let data = "Test Data".data(using: .utf8)!
        let url = URL(string: "https://example.com")!
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        let result = Commons.handleResponse(data: data, response: urlResponse, logger: mockLogger, errorHandler: mockErrorHandler)
        
        switch result {
        case .success(let networkResponse):
            XCTAssertEqual(networkResponse.data, data)
            XCTAssertEqual(networkResponse.URLResponse.url, url)
        case .failure:
            XCTFail("Expected success, got failure")
        }
    }
    
    func testHandleResponseFailure() {
        let data = "Test Data".data(using: .utf8)!
        let url = URL(string: "https://example.com")!
        let urlResponse = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)!
        
        let result = Commons.handleResponse(data: data, response: urlResponse, logger: mockLogger, errorHandler: mockErrorHandler)
        
        switch result {
        case .success:
            XCTFail("Expected failure, got success")
        case .failure(let error):
            XCTAssertEqual(error.errorCase, .unknown(NSError(domain: "", code: 0, userInfo: nil)))
        }
    }
    
    func testHandleDownloadResponseSuccess() {
        let url = URL(string: "file:///path/to/downloaded/file")!
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        let result = Commons.handleDownloadResponse(url: url, response: urlResponse, logger: mockLogger, errorHandler: mockErrorHandler)
        
        switch result {
        case .success(let fileURL):
            XCTAssertEqual(fileURL, url)
        case .failure:
            XCTFail("Expected success, got failure")
        }
    }
    
    func testHandleDownloadResponseFailure() {
        let result = Commons.handleDownloadResponse(url: nil, response: nil, logger: mockLogger, errorHandler: mockErrorHandler)
        
        switch result {
        case .success:
            XCTFail("Expected failure, got success")
        case .failure(let error):
            XCTAssertEqual(error.errorCase, .noData)
        }
    }
    
    func testDecodeResponseSuccess() {
        let data = """
        {
            "id": 1,
            "name": "Test"
        }
        """.data(using: .utf8)!
        
        let url = URL(string: "https://example.com")!
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let networkResponse = NetworkResponse(data: data, URLResponse: urlResponse)
        
        let result: Result<Response<TestModel>, NetworkError> = Commons.decodeResponse(networkResponse, to: TestModel.self, logger: mockLogger, errorHandler: mockErrorHandler)
        
        switch result {
        case .success(let response):
            XCTAssertEqual(response.decodedResponse.id, 1)
            XCTAssertEqual(response.decodedResponse.name, "Test")
        case .failure:
            XCTFail("Expected success, got failure")
        }
    }
    
    func testDecodeResponseFailure() {
        let data = "Invalid Data".data(using: .utf8)!
        
        let url = URL(string: "https://example.com")!
        let urlResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let networkResponse = NetworkResponse(data: data, URLResponse: urlResponse)
        
        let result: Result<Response<TestModel>, NetworkError> = Commons.decodeResponse(networkResponse, to: TestModel.self, logger: mockLogger, errorHandler: mockErrorHandler)
        
        switch result {
        case .success:
            XCTFail("Expected failure, got success")
        case .failure(let error):
            XCTAssertEqual(error.errorCase.description, "Unknown Error: The data couldn’t be read because it isn’t in the correct format.")
        }
    }
    
    func testMakeURLRequest() {
        let urlString = "https://example.com"
        let headers = ["Content-Type": "application/json"]
        let body = TestModel(id: 1, name: "Test")
        
        let request = NetworkRequest(urlString: urlString, method: .post, headers: headers, body: body)
        let urlRequest = Commons.makeURLRequest(from: request)
        
        XCTAssertEqual(urlRequest?.url?.absoluteString, urlString)
        XCTAssertEqual(urlRequest?.httpMethod, "POST")
        XCTAssertEqual(urlRequest?.allHTTPHeaderFields?["Content-Type"], "application/json")
    }
    
    func testHandleRequestError() {
        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Test Error"])
        let data = "Test Data".data(using: .utf8)
        let url = URL(string: "https://example.com")!
        let urlResponse = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        
        let expectation = self.expectation(description: "Completion handler invoked")
        var result: Result<NetworkResponse, NetworkError>?
        
        Commons.handleRequestError(error, data: data, response: urlResponse, logger: mockLogger, errorHandler: mockErrorHandler) { res in
            result = res
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        switch result {
        case .failure(let customError):
            XCTAssertEqual(customError.errorCase, .unknown(error))
        default:
            XCTFail("Expected failure, got success")
        }
    }
    
    func testHandleError() {
        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Test Error"])
        let customError = Commons.handleError(error, logger: mockLogger, errorHandler: mockErrorHandler)
        
        XCTAssertEqual(customError.errorCase, .unknown(error))
    }
}

