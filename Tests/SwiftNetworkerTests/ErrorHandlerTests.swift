import XCTest
@testable import SwiftNetworker

class ErrorHandlerTests: XCTestCase {
    
    var errorHandler: ErrorHandler!
    
    override func setUp() {
        super.setUp()
        errorHandler = ErrorHandler()
    }
    
    override func tearDown() {
        errorHandler = nil
        super.tearDown()
    }
    
    func testHandleDecodingError() {
        let decodingError = DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Test error"))
        let result = errorHandler.handle(decodingError, data: nil, response: nil)
        
        XCTAssertEqual(result.errorCase, .decodingError("Data corrupted: Test error"))
        XCTAssertNil(result.apiErrorMessage)
    }
    
    func testHandleURLError() {
        let urlError = URLError(.cannotFindHost)
        let result = errorHandler.handle(urlError, data: nil, response: nil)
        
        XCTAssertEqual(result.errorCase, .invalidURL)
        XCTAssertNil(result.apiErrorMessage)
    }
    
    func testHandleUnknownError() {
        let unknownError = NSError(domain: "test", code: -1, userInfo: nil)
        let result = errorHandler.handle(unknownError, data: nil, response: nil)
        
        XCTAssertEqual(result.errorCase, .unknown(unknownError))
        XCTAssertNil(result.apiErrorMessage)
    }
    
    func testHandleClientError() {
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)
        let result = errorHandler.handle(nil, data: nil, response: response)
        
        XCTAssertEqual(result.errorCase, .notFound("The requested resource could not be found."))
        XCTAssertNil(result.apiErrorMessage)
    }
    
    func testHandleServerError() {
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 500, httpVersion: nil, headerFields: nil)
        let result = errorHandler.handle(nil, data: nil, response: response)
        
        XCTAssertEqual(result.errorCase, .serverError("The server encountered an internal error and was unable to complete your request."))
        XCTAssertNil(result.apiErrorMessage)
    }
    
    func testHandleRedirectionError() {
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 302, httpVersion: nil, headerFields: nil)
        let result = errorHandler.handle(nil, data: nil, response: response)
        
        XCTAssertEqual(result.errorCase, .found("The resource has been found at a different location."))
        XCTAssertNil(result.apiErrorMessage)
    }
    
    func testHandleClientErrorWithApiErrorMessage() {
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 400, httpVersion: nil, headerFields: nil)
        let data = "Bad Request".data(using: .utf8)
        let result = errorHandler.handle(nil, data: data, response: response)
        
        XCTAssertEqual(result.errorCase, .badRequest("The request was malformed or contained invalid parameters."))
        XCTAssertEqual(result.apiErrorMessage, "Bad Request")
    }
    
    func testHandleServerErrorWithApiErrorMessage() {
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 500, httpVersion: nil, headerFields: nil)
        let data = "Internal Server Error".data(using: .utf8)
        let result = errorHandler.handle(nil, data: data, response: response)
        
        XCTAssertEqual(result.errorCase, .serverError("The server encountered an internal error and was unable to complete your request."))
        XCTAssertEqual(result.apiErrorMessage, "Internal Server Error")
    }
    
    func testHandleRedirectionErrorWithApiErrorMessage() {
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 302, httpVersion: nil, headerFields: nil)
        let data = "Found".data(using: .utf8)
        let result = errorHandler.handle(nil, data: data, response: response)
        
        XCTAssertEqual(result.errorCase, .found("The resource has been found at a different location."))
        XCTAssertEqual(result.apiErrorMessage, "Found")
    }
    
    func testHandleUnauthorizedWithCustomMessage() {
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 401, httpVersion: nil, headerFields: nil)
        let data = "Unauthorized access".data(using: .utf8)
        let result = errorHandler.handle(nil, data: data, response: response)
        
        XCTAssertEqual(result.errorCase, .unauthorized("Authentication is required and has failed or has not yet been provided."))
        XCTAssertEqual(result.apiErrorMessage, "Unauthorized access")
    }
    
    func testHandleForbiddenWithCustomMessage() {
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 403, httpVersion: nil, headerFields: nil)
        let data = "Forbidden resource".data(using: .utf8)
        let result = errorHandler.handle(nil, data: data, response: response)
        
        XCTAssertEqual(result.errorCase, .forbidden("The server understood the request but refuses to authorize it."))
        XCTAssertEqual(result.apiErrorMessage, "Forbidden resource")
    }
    
    func testHandleURLErrorTimeout() {
        let urlError = URLError(.timedOut)
        let result = errorHandler.handle(urlError, data: nil, response: nil)
        
        XCTAssertEqual(result.errorCase, .timeOut)
        XCTAssertNil(result.apiErrorMessage)
    }
    
    func testHandleBadGatewayWithCustomMessage() {
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 502, httpVersion: nil, headerFields: nil)
        let data = "Bad gateway error".data(using: .utf8)
        let result = errorHandler.handle(nil, data: data, response: response)
        
        XCTAssertEqual(result.errorCase, .serverError("The server received an invalid response from the upstream server."))
        XCTAssertEqual(result.apiErrorMessage, "Bad gateway error")
    }
    
    func testHandleServiceUnavailableWithCustomMessage() {
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 503, httpVersion: nil, headerFields: nil)
        let data = "Service unavailable".data(using: .utf8)
        let result = errorHandler.handle(nil, data: data, response: response)
        
        XCTAssertEqual(result.errorCase, .serverError("The server is currently unable to handle the request due to temporary overload or maintenance."))
        XCTAssertEqual(result.apiErrorMessage, "Service unavailable")
    }
    
    func testHandleUnexpectedHTTPStatusCode() {
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 418, httpVersion: nil, headerFields: nil)
        let data = "I'm a teapot".data(using: .utf8)
        let result = errorHandler.handle(nil, data: data, response: response)
        
        XCTAssertEqual(result.errorCase, .unknown(NSError(domain: "", code: 418, userInfo: [NSLocalizedDescriptionKey: "Client error with status code 418."])))
        XCTAssertEqual(result.apiErrorMessage, "I'm a teapot")
        XCTAssertEqual(result.detailedDescription, "Unknown Error: Client error with status code 418. - I'm a teapot")
    }
    
    func testHandleUnexpectedErrorType() {
        struct UnexpectedError: Error {}
        let unexpectedError = UnexpectedError()
        let result = errorHandler.handle(unexpectedError, data: nil, response: nil)
        
        XCTAssertEqual(result.errorCase, .unknown(unexpectedError))
        XCTAssertNil(result.apiErrorMessage)
    }
}

extension NetworkErrorCases: Equatable {
    public static func == (lhs: NetworkErrorCases, rhs: NetworkErrorCases) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.noData, .noData),
             (.timeOut, .timeOut):
            return true
        case (.badRequest(let lhsMessage), .badRequest(let rhsMessage)),
             (.unauthorized(let lhsMessage), .unauthorized(let rhsMessage)),
             (.forbidden(let lhsMessage), .forbidden(let rhsMessage)),
             (.notFound(let lhsMessage), .notFound(let rhsMessage)),
             (.serverError(let lhsMessage), .serverError(let rhsMessage)),
             (.parsingError(let lhsMessage), .parsingError(let rhsMessage)),
             (.requestCanceled(let lhsMessage), .requestCanceled(let rhsMessage)),
             (.decodingError(let lhsMessage), .decodingError(let rhsMessage)),
             (.multipleChoices(let lhsMessage), .multipleChoices(let rhsMessage)),
             (.movedPermanently(let lhsMessage), .movedPermanently(let rhsMessage)),
             (.found(let lhsMessage), .found(let rhsMessage)),
             (.seeOther(let lhsMessage), .seeOther(let rhsMessage)),
             (.notModified(let lhsMessage), .notModified(let rhsMessage)),
             (.useProxy(let lhsMessage), .useProxy(let rhsMessage)),
             (.temporaryRedirect(let lhsMessage), .temporaryRedirect(let rhsMessage)),
             (.permanentRedirect(let lhsMessage), .permanentRedirect(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.networkError(let lhsError), .networkError(let rhsError)),
             (.unknown(let lhsError), .unknown(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
