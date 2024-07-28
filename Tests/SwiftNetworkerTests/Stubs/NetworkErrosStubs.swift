import Foundation
@testable import SwiftNetworker


extension NetworkErrorCases {
    static let mockInvalidURL = NetworkErrorCases.invalidURL
    static let mockNoData = NetworkErrorCases.noData
    static let mockTimeOut = NetworkErrorCases.timeOut
    static let mockBadRequest = NetworkErrorCases.badRequest("The request could not be understood by the server.")
    static let mockUnauthorized = NetworkErrorCases.unauthorized("Authentication is required and has failed.")
    static let mockForbidden = NetworkErrorCases.forbidden("The request was valid, but the server is refusing action.")
    static let mockNotFound = NetworkErrorCases.notFound("The requested resource could not be found.")
    static let mockServerError = NetworkErrorCases.serverError("The server encountered an internal error.")
    static let mockParsingError = NetworkErrorCases.parsingError("The response could not be parsed.")
    static let mockRequestCanceled = NetworkErrorCases.requestCanceled("The request was canceled.")
    static let mockDecodingError = NetworkErrorCases.decodingError("The data could not be decoded.")
    static let mockNetworkError = NetworkErrorCases.networkError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Network connection lost."]))
    static let mockUnknownError = NetworkErrorCases.unknown(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "An unknown error occurred."]))
}

extension NetworkError {
    static let mockInvalidURL = NetworkError(errorCase: .mockInvalidURL, apiErrorMessage: nil)
    static let mockNoData = NetworkError(errorCase: .mockNoData, apiErrorMessage: nil)
    static let mockTimeOut = NetworkError(errorCase: .mockTimeOut, apiErrorMessage: nil)
    static let mockBadRequest = NetworkError(errorCase: .mockBadRequest, apiErrorMessage: "Bad request error message from API.")
    static let mockUnauthorized = NetworkError(errorCase: .mockUnauthorized, apiErrorMessage: "Unauthorized error message from API.")
    static let mockForbidden = NetworkError(errorCase: .mockForbidden, apiErrorMessage: "Forbidden error message from API.")
    static let mockNotFound = NetworkError(errorCase: .mockNotFound, apiErrorMessage: "Not found error message from API.")
    static let mockServerError = NetworkError(errorCase: .mockServerError, apiErrorMessage: "Server error message from API.")
    static let mockParsingError = NetworkError(errorCase: .mockParsingError, apiErrorMessage: "Parsing error message from API.")
    static let mockRequestCanceled = NetworkError(errorCase: .mockRequestCanceled, apiErrorMessage: "Request canceled error message from API.")
    static let mockDecodingError = NetworkError(errorCase: .mockDecodingError, apiErrorMessage: "Decoding error message from API.")
    static let mockNetworkError = NetworkError(errorCase: .mockNetworkError, apiErrorMessage: nil)
    static let mockUnknownError = NetworkError(errorCase: .mockUnknownError, apiErrorMessage: nil)
}
