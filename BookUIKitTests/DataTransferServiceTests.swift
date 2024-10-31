//
//  DataTransferServiceTests.swift
//  BookUIKitTests
//
//  Created by jiin heo on 10/31/24.
//

import XCTest

final class DataTransferDispatchQueueMock: DataTransferDispatchQueue {
    func asyncExecute(work: @escaping () -> Void) {
        work()
    }
}

private struct MockModel: Decodable {
    let name: String
}

class DataTransferServiceTests: XCTestCase {
    
    private enum DataTransferErrorMock: Error {
        case someError
    }
    
    // 유효한 Json Reponse값을 받았을 때 decodeResponse가 decodableObject가 되야함
    func test_whenReceivedValidJsonInResponse_shouldDecodeResponseToDecodableObject() {
        // given - response, decode 객체 필요
        let config = NetworkConfigurableMock()
        var completionCallsCount = 0
        
        // # : Raw String Literal
        // 이 방식으로 문자열을 작성하면 이스케이프 문자를 무시할 수 있음
        // "{"name": "Hello"}" -> Json 형식
        let responsData = #"{"name": "Hello"}"#.data(using: .utf8)
        let networkService = DefaultNetworkService(config: config, sessionManager: NetworkSessionManagerMock(response: nil, data: responsData, error: nil))
        
        let sut = DefaultDataTransferService(with: networkService)
        
        // when - decode 실행
        _ = sut.request(
            with: Endpoint<MockModel>(path: "http://mock.endpoint.com", method: .get),
            on: DataTransferDispatchQueueMock(),
            completion: { result in
                do {
                    let object = try result.get()
                    XCTAssertEqual(object.name, "Hello")
                    completionCallsCount += 1
                } catch {
                    XCTFail("Failed decoding MockObject")
                }
            })
        
        // then - 값이 맞아야함
        XCTAssertEqual(completionCallsCount, 1)
    }
    
    // 유효하지 않은 reponse는 decodeObject가 아니어야함
    func test_whenInvaildResponse_shouldNotDecodeObject() {
        // given
        let config = NetworkConfigurableMock()
        var completionCallsCount = 0
        
        let responseData = #"{"age: 20"}"#.data(using: .utf8)
        let networkService = DefaultNetworkService(config: config, sessionManager: NetworkSessionManagerMock(response: nil, data: responseData, error: nil))
        
        let sut = DefaultDataTransferService(with: networkService)
        
        // when
        _ = sut.request(
            with: Endpoint<MockModel>(path: "http://mock.endpoint.com", method: .get),
            on: DataTransferDispatchQueueMock(),
            completion: { result in
                do {
                    let object = try result.get()
                    XCTFail("should not happen")
                } catch {
                    completionCallsCount += 1
                }
            })
        
        // then
        XCTAssertEqual(completionCallsCount, 1)
    }
    
    // bad Request 받았을때, network error throw 던져야함
    func test_whenBadRequestReceived_shouldRethrowNetworkError() {
        // given
        let config = NetworkConfigurableMock()
        var completionCallsCount = 0
        
        let responseData = #"{"asdf": "Nothing"}"#.data(using: .utf8)!
        let response = HTTPURLResponse(
            url: URL(string: "test_url")!,
            statusCode: 500,
            httpVersion: "1.1",
            headerFields: nil)
        
        let networkService = DefaultNetworkService(config: config, sessionManager: NetworkSessionManagerMock(response: response, data: responseData, error: DataTransferErrorMock.someError))
        
        let sut = DefaultDataTransferService(with: networkService)
        
        // when
        _ = sut.request(
            with: Endpoint(path: "asdfasdf", method: .get),
            on: DataTransferDispatchQueueMock(),
            completion: { result in
                do {
                    _ = try result.get()
                    XCTFail("should not happen")
                } catch let error {
                    // network error 던져야함
                    if case DataTransferError.networkFailure(NetworkError.error(statusCode: 500, data: _)) = error {
                        completionCallsCount += 1
                    } else {
                        XCTFail("Wrong error")
                    }
                }
            })
        
        // then
        XCTAssertEqual(completionCallsCount, 1)
    }
    
    // NoData 받았을 때 NoDataError를 던져야함
    func test_whenNoDataReceived_shouldThrowNoDataError() {
        // given
        let config = NetworkConfigurableMock()
        var completionCallsCount = 0
        let response = HTTPURLResponse(url: URL(string: "test_url")!,
                                       statusCode: 200,
                                       httpVersion: "1.1",
                                       headerFields: [:])
        
        let networkService = DefaultNetworkService(config: config, sessionManager: NetworkSessionManagerMock(response: response, data: nil, error: nil))
        
        let sut = DefaultDataTransferService(with: networkService)
        
        // when
        _ = sut.request(
            with: Endpoint<MockModel>(path: "test.com", method: .get),
            on: DataTransferDispatchQueueMock(),
            completion: { result in
                do {
                    _ = try result.get()
                    XCTFail("Should not happen")
                } catch let error {
                    if case DataTransferError.noResponse = error {
                        completionCallsCount += 1
                    } else {
                        XCTFail("Wrong error")
                    }
                }
                
            })
        
        // then
        XCTAssertEqual(completionCallsCount, 1)
    }
}
