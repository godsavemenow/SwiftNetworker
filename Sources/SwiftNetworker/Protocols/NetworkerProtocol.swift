import Foundation

/// A protocol defining the methods for a networker.
public protocol NetworkerProtocol {
    func perform(_ request: NetworkRequest, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void)
    func perform<T: Decodable>(_ request: NetworkRequest, responseModel: T.Type, completion: @escaping (Result<Response<T>, NetworkError>) -> Void)
    func performUpload(_ request: NetworkRequest, data: Data, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void)
    func performDownload(_ request: NetworkRequest, completion: @escaping (Result<URL, NetworkError>) -> Void)
}
