//
//  DataTransferSercive.swift
//  BookUIKit
//
//  Created by jiin heo on 10/27/24.
//

import Foundation

// MARK: - Error
enum DataTransferError: Error {
    case noResponse
    case parsing(Error)
    case networkFailure(NetworkError)
    case resolvedNetworkFailure(Error)
}

protocol DataTransferErrorResolver {
    func resolve(error: NetworkError) -> Error
}

protocol DataTransferErrorLogger {
    func log(error: Error)
}

// MARK: - Transfer Service

/// 네트워크 요청의 고수준 추상화 역할을 함
/// NetworkService를 사용하여 네트워크 요청을 수행하지만, 더 높은 수준의 인터페이스를 제공
/// NetworkService의 기능을 래핑하여, 네트워크 요청의 처리 로직을 더 간편하고 유연하게 사용할 수 있게 만든것
/// Result 타입으로 응답을 처리
/// 요청을 별도의 디스패치 큐에서 처리할 수 있도록 두 가지 메서드를 제공 (동시성 처리와 베인 스레드 부하르 줄이기 위한 유연성 제공)
protocol DataTransferService {
    
    typealias CompletionHandler<T> = (Result<T, DataTransferError>) -> Void
    
    // @discardableResult
    // 결과값을 버릴 수 있다. return값을 discadable 시킬 수 있음.
    // return 값을 사용하지 않아도 warning 메세지가 나오지 않음
    @discardableResult
    func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E, on queue: DataTransferDispatchQueue, completion: @escaping CompletionHandler<T>
    ) -> NetworkCancellable? where E.Response == T
    
    @discardableResult
    func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E, completion: @escaping CompletionHandler<T>
    ) -> NetworkCancellable? where E.Response == T
    
    @discardableResult
    func request<E: ResponseRequestable>(
        with endpoint: E, on queue: DataTransferDispatchQueue, completion: @escaping CompletionHandler<Void>
    ) -> NetworkCancellable? where E.Response == Void
    
    @discardableResult
    func request<E: ResponseRequestable>(
        with endpoint: E, completion: @escaping CompletionHandler<Void>
    ) -> NetworkCancellable? where E.Response == Void
}

final class DefaultDataTransferService {
    
    private let networkService: NetworkService
    private let errorResolver: DataTransferErrorResolver
    private let errorLogger: DataTransferErrorLogger
    
    init(
        with networkService: NetworkService,
        errorResolver: DataTransferErrorResolver = DefaultDataTransferErrorResolver(),
        errorLogger: DataTransferErrorLogger = DefaultDataTransferErrorLogger()
    ) {
        self.networkService = networkService
        self.errorResolver = errorResolver
        self.errorLogger = errorLogger
    }
}

extension DefaultDataTransferService: DataTransferService {
    func request<T, E>(with endpoint: E, on queue: any DataTransferDispatchQueue, completion: @escaping CompletionHandler<T>) -> (any NetworkCancellable)? where T : Decodable, T == E.Response, E : ResponseRequestable {
        
        self.networkService.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                let result: Result<T, DataTransferError> = self.decode(data: data, decoder: endpoint.responseDecorder)
                queue.asyncExecute {
                    completion(result)
                }
                
            case .failure(let error):
                self.errorLogger.log(error: error)
                let error = self.resolve(networkError: error)
                queue.asyncExecute {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func request<T, E>(with endpoint: E, completion: @escaping CompletionHandler<T>) -> (any NetworkCancellable)? where T : Decodable, T == E.Response, E : ResponseRequestable {
        request(with: endpoint, on: DispatchQueue.main, completion: completion)
    }
    
    func request<E>(with endpoint: E, on queue: any DataTransferDispatchQueue, completion: @escaping CompletionHandler<Void>) -> (any NetworkCancellable)? where E : ResponseRequestable, E.Response == () {
        networkService.request(endpoint: endpoint) { result in
            switch result {
            case .success:
                queue.asyncExecute {
                    completion(.success(()))
                }
            case .failure(let error):
                self.errorLogger.log(error: error)
                let error = self.resolve(networkError: error)
                queue.asyncExecute {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func request<E>(with endpoint: E, completion: @escaping CompletionHandler<Void>) -> (any NetworkCancellable)? where E : ResponseRequestable, E.Response == () {
        request(with: endpoint, on: DispatchQueue.main, completion: completion)
    }
    
    // MARK: - Private
    private func decode<T: Decodable>(data: Data?, decoder: ResponseDecoder) -> Result<T, DataTransferError> {
        do {
            guard let data = data else {
                return .failure(.noResponse)
            }
            let result: T = try decoder.decode(data)
            return .success(result)
        } catch {
            self.errorLogger.log(error: error)
            return .failure(.parsing(error))
        }
    }
    
    private func resolve(networkError error: NetworkError) -> DataTransferError {
        let resolvedError = self.errorResolver.resolve(error: error)
        return resolvedError is NetworkError
        ? . networkFailure(error)
        : .resolvedNetworkFailure(resolvedError)
    }
    
}

// MARK: - Logger
final class DefaultDataTransferErrorLogger: DataTransferErrorLogger {
    init() { }
    func log(error: any Error) {
        printIfDebug("--------")
        printIfDebug("error: \(error)")
    }
}

// MARK: - Error Resolver
final class DefaultDataTransferErrorResolver: DataTransferErrorResolver {
    init() { }
    func resolve(error: NetworkError) -> any Error {
        return error
    }
}

// MARK: - Response Decoders
class JSONResponseDecoder: ResponseDecoder {
    private let jsonDecoder = JSONDecoder()
    init() { }
    func decode<T: Decodable>(_ data: Data) throws -> T {
        return try jsonDecoder.decode(T.self, from: data)
    }
}

class RawDataResponseDecoder: ResponseDecoder {
    init() { }
    
    enum CodingKeys: String, CodingKey {
        case `default` = ""
    }
    func decode<T: Decodable>(_ data: Data) throws -> T {
        if T.self is Data.Type, let data = data as? T {
            return data
        } else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.default],
                debugDescription: "Expected Data type"
            )
            throw Swift.DecodingError.typeMismatch(T.self, context)
        }
    }
}

// MARK: - Queue
protocol DataTransferDispatchQueue {
    func asyncExecute(work: @escaping () -> Void)
}

extension DispatchQueue: DataTransferDispatchQueue {
    func asyncExecute(work: @escaping () -> Void) {
        async(group: nil, execute: work)
    }
}
