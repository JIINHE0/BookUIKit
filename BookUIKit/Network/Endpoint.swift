//
//  Endpoint.swift
//  BookUIKit
//
//  Created by jiin heo on 10/26/24.
//

import Foundation
 
enum HTTPMethodType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
}

enum RequestGenerationError: Error {
    case components
}

// MARK: - Enpoint Class

class Endpoint<R>: ResponseRequestable {
    typealias Response = R
    

    let path: String
    let isFullPath: Bool
    let method: HTTPMethodType
    let headerParameters: [String: String]
    let queryParametersEncodable: Encodable?
    let queryParameters: [String: Any]
    let bodyParametersEncodable: Encodable?
    let bodyParameters: [String: Any]
    let bodyEncoder: BodyEncoder
    let responseDecoder: ResponseDecoder
    
    init(path: String,
         isFullPath: Bool = false,
         method: HTTPMethodType,
         headerParameters: [String: String] = [:],
         queryParametersEncodable: Encodable? = nil,
         queryParameters: [String: Any] = [:],
         bodyParametersEncodable: Encodable? = nil,
         bodyParameters: [String: Any] = [:],
         bodyEncoder: BodyEncoder = JSONBodyEncoder(),
         responseDecoder: ResponseDecoder = JSONResponseDecoder()) {
        self.path = path
        self.isFullPath = isFullPath
        self.method = method
        self.headerParameters = headerParameters
        self.queryParametersEncodable = queryParametersEncodable
        self.queryParameters = queryParameters
        self.bodyParametersEncodable = bodyParametersEncodable
        self.bodyParameters = bodyParameters
        self.bodyEncoder = bodyEncoder
        self.responseDecoder = responseDecoder
    }
}

// MARK: - Request / Response

protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}

protocol BodyEncoder {
    func encode(_ parameters: [String: Any]) -> Data?
}

struct JSONBodyEncoder: BodyEncoder {
    func encode(_ parameters: [String : Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: parameters)
    }
}

protocol ResponseRequestable: Requestable {
    associatedtype Response
    
    var responseDecorder: ResponseDecoder { get }
}

protocol Requestable {
    var path: String { get }
    var isFullPath: Bool { get }
    var method: HTTPMethodType { get }
    var headerParameters: [String: String] { get }
    var queryParameters: [String: String] { get }
    var queryParametersEncodable: Encodable? { get }
    var bodyParametersEncodable: Encodable? { get }
    var bodyParameters: [String: Any] { get }
    var bodyEncorder: BodyEncorder { get }
    
    func urlRequest(with networkConfig: NetworkConfigurable) throws -> URLRequest
}

extension Requestable {
    
    func url(with config: NetworkConfigurable) throws -> URL {
        
        let baseURL = config.baseURL.absoluteString.last != "/"
        ? config.baseURL.absoluteString + "/"
        : config.baseURL.absoluteString
        
        let endpoint = isFullPath ? path: baseURL.appending(path)

        guard var urlComponents = URLComponents(string: endpoint) else {
            throw RequestGenerationError.components
        }
        
        var urlQueryItems = [URLQueryItem]()
        
        let queryParameters = try queryParametersEncodable?.toDictionary() ?? self.queryParameters
        
        config.queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: $0.value))
        }
        
        urlComponents.queryItems = !urlQueryItems.isEmpty ? urlQueryItems : nil
        
        guard let url = urlComponents.url else { throw RequestGenerationError.components }
        
        return url
    }
    
    func urlRequest(with config: NetworkConfigurable) throws -> URLRequest {
        
        let url = try self.url(with: config)
        var urlRequest = URLRequest(url: url)
        var allHeader: [String: String] = config.header
        headerParameters.forEach {
            allHeader.updateValue($1, forKey: $0)
        }
        
        let bodyParameters = try bodyParametersEncodable?.toDictionary() ?? self.bodyParameters
        
        if !bodyParameters.isEmpty {
            urlRequest.httpBody = bodyEncorder.encode(bodyParameters)
        }
        
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = allHeader
        return urlRequest
    }
}

// MARK: - Extension

// dic.queryString -> String
private extension Dictionary {
    var queryString: String {
        return self.map { "\($0.key)=\($0.value)"}
            .joined(separator: "&")
            .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? ""
    }
}

// object.toDictionary -> [String: Any]?
private extension Encodable {
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        return jsonData as? [String: Any]
    }
}
