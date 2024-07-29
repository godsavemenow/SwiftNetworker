import Foundation

/// A protocol defining the methods for a networker.
public protocol NetworkerProtocol {
    func perform(_ request: NetworkRequest, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void)
    @available(iOS 15.0, macOS 12.0, *)
    func performAsync(_ request: NetworkRequest) async -> Result<NetworkResponse, NetworkError>
    func perform<T: Decodable>(_ request: NetworkRequest, responseModel: T.Type, completion: @escaping (Result<Response<T>, NetworkError>) -> Void)
    @available(iOS 15.0, macOS 12.0, *)
    func performAsync<T: Decodable>(_ request: NetworkRequest, responseModel: T.Type) async -> Result<Response<T>, NetworkError>
    func performUpload(_ request: NetworkRequest, data: Data, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void)
    @available(iOS 15.0, macOS 12.0, *)
    func performUploadAsync(_ request: NetworkRequest, data: Data) async -> Result<NetworkResponse, NetworkError>
    func performDownload(_ request: NetworkRequest, completion: @escaping (Result<URL, NetworkError>) -> Void)
    @available(iOS 15.0, macOS 12.0, *)
    func performDownloadAsync(_ request: NetworkRequest) async -> Result<URL, NetworkError>
}
