//
//  NetworkServiceTests.swift
//  BookUIKitTests
//
//  Created by jiin heo on 10/30/24.
//

import XCTest

class NetworkServiceTests: XCTestCase {
    
    private struct EndpointMock: Requestable {
        var path: String
        var isFullPath: Bool = false
        var method: HTTPMethodType
        var headerParameters: [String: String] = [:]
        var queryParametersEncodable: Encodable?
        var queryParameters: [String: Any] = [:]
        var bodyParametersEncodable: Encodable?
        var bodyParameters: [String: Any] = [:]
        var bodyEncoder: BodyEncoder = AsciiBodyEncoder()
        
        init(path: String, method: HTTPMethodType) {
            self.path = path
            self.method = method
        }
    }
    
    class NetworkErrorLoggerMock: NetworkErrorLogger {
        var loggedErrors: [Error] = []
        func log(request: URLRequest) { }
        func log(responseData data: Data?, response: URLResponse?) { }
        func log(error: Error) { loggedErrors.append(error) }
    }
    
    private enum NetworkErrorMock: Error {
        case someError
    }
    
    func test_whenMockDataPassed_shouldReturnProperResponse() {
        //given
        let config = NetworkConfigurableMock()
        var completionCallsCount = 0
        
        let expectedResponseData = "Response data".data(using: .utf8)!
        let sut = DefaultNetworkService(
            config: config,
            sessionManager: NetworkSessionManagerMock(
                response: nil,
                data: expectedResponseData,
                error: nil
            )
        )
        //when
        _ = sut.request(endpoint: EndpointMock(path: "http://mock.test.com", method: .get)) { result in
            guard let responseData = try? result.get() else {
                XCTFail("Should return proper response")
                return
            }
            XCTAssertEqual(responseData, expectedResponseData)
            completionCallsCount += 1
        }
        //then
        XCTAssertEqual(completionCallsCount, 1)
    }
    
    func test_whenErrorWithNSURLErrorCancelledReturned_shouldReturnCancelledError() {
        // given
        let config = NetworkConfigurableMock()
        var completionCallsCount = 0
        let cancelledError = NSError(domain: "network", code: NSURLErrorCancelled, userInfo: nil)
        let sut = DefaultNetworkService(config: config, sessionManager: NetworkSessionManagerMock(response: nil, data: nil, error: cancelledError as Error))
        
        // when
        _ = sut.request(endpoint: EndpointMock(path: "http://mock.test.com", method: .get), completion: { result in
            do {
                _ = try result.get()
                XCTFail("Should not happen")
            }catch let error {
                guard case NetworkError.cancelled = error else {
                    XCTFail("NetworkError.cancelled not found")
                    return
                }
                completionCallsCount += 1
            }
        })
        
        // then
        XCTAssertEqual(completionCallsCount, 1)
    }
    
    // statusCode가 500일때 statusCodError를 반환해야함
    func test_whenStatusCodeEqualOrAbove400_shouldReturnhasStatusCodeError() {
        // given
        let config = NetworkConfigurableMock()
        var completionCallsCount = 0
        
        let response = HTTPURLResponse(url: URL(string: "test")!, statusCode: 500, httpVersion: "1.1", headerFields: [:])
        
        let sut = DefaultNetworkService(config: config, sessionManager: NetworkSessionManagerMock(response: response, data: nil, error: NetworkErrorMock.someError))
        
        // when
        _ = sut.request(endpoint: EndpointMock(path: "http://mock.test.com", method: .get), completion: { result in
            do {
                _ = try result.get()
                XCTFail("should not happen")
            } catch let error {
                if case NetworkError.error(let statusCode, _) = error {
                    XCTAssertEqual(statusCode, 500)
                    completionCallsCount += 1
                }
            }
        })
        
        // then
        XCTAssertEqual(completionCallsCount, 1)
    }
    
    func test_whenErrorWithNSURLErrorNotConnectedToInternetReturned_shouldReturnNotConnectedError() {
        // 인터넷 연결 에러일때, not connected error 반환해야함
        
        // give
        let config = NetworkConfigurableMock()
        var competionCallsCount = 0
        let notConnectedError = NSError(domain: "test", code: NSURLErrorNotConnectedToInternet)
        let sut = DefaultNetworkService(config: config, sessionManager: NetworkSessionManagerMock(response: nil, data: nil, error: notConnectedError))
        
        // when
        _ = sut.request(endpoint: EndpointMock(path: "http://mock.test.com", method: .get), completion: { result in
            do {
                _ = try result.get()
                XCTFail("")
            } catch let error {
                guard case NetworkError.notConnetcted = error else {
                    XCTFail("NetworkError.notConnetcted not found")
                    return
                }
                competionCallsCount += 1
            }
        })
        
        // then
        XCTAssertEqual(competionCallsCount, 1)
    }
    
    // NetworkError타입의 notConnected 오류가 특정 HTTP 상태 코드를 가지고 있는지 확인
    func test_whenhasStatusCodeUsedWithWrongError_shouldReturnFalse() {
        
        // when
        let sut = NetworkError.notConnetcted
        
        // then
        XCTAssertFalse(sut.hasStatusCode(200))
        // false가 맞음
    }
    
    func test_whenhasStatusCodeUsed_shouldReturnCorrectStatusCode() {
        // when
        let sut = NetworkError.error(statusCode: 400, data: nil)
        
        // then
        XCTAssertTrue(sut.hasStatusCode(400))
        XCTAssertFalse(sut.hasStatusCode(401))
        XCTAssertFalse(sut.hasStatusCode(399))
    }
    
    
    func test_whenErrorWithNSURLErrorNotConnectedToInternet_shouldLogThisError() {
        
        // given
        let config = NetworkConfigurableMock()
        var completionCallsCount = 0
        
        let error = NSError(domain: "network", code: NSURLErrorNotConnectedToInternet)
        let networkErrorLogger = NetworkErrorLoggerMock()
        let sut = DefaultNetworkService(config: config,
                                        sessionManager: NetworkSessionManagerMock(response: nil, data: nil, error: error),
                                        logger: networkErrorLogger)
        
        // when
        _ = sut.request(endpoint: EndpointMock(path: "http://mock.test.com", method: .get), completion: { result in
            do {
                _ = try result.get()
                XCTFail("Should not happen")
            } catch let error {
                guard case NetworkError.notConnetcted = error else {
                    XCTFail("NetworkError.notConnected not found")
                    return
                }
                completionCallsCount += 1
            }
        })

        // then
        XCTAssertEqual(completionCallsCount, 1)
        XCTAssertTrue(networkErrorLogger.loggedErrors.contains(where: { error in
            guard case NetworkError.notConnetcted = error else { return false }
            return true
        }))
        
        XCTAssertTrue(networkErrorLogger.loggedErrors.contains{
            guard case NetworkError.notConnetcted = $0 else { return false }
            return true
        })
    }
}
