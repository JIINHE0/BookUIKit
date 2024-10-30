//
//  NetworkConfig.swift
//  BookUIKit
//
//  Created by jiin heo on 10/26/24.
//

import Foundation

// 레이어를 나누는 이유?
// 유지보수를 쉽게 하기위해, 문제가 어디서 생겼는지 빨리 파악하기 위해

protocol NetworkConfigurable {
    var baseURL: URL { get }
    var headers: [String: String] { get }
    var queryParameters: [String: String] { get }
}

struct ApiDataNetworkConfig: NetworkConfigurable {
    
    var baseURL: URL
    var headers: [String : String]
    var queryParameters: [String : String]
    
    init(
        baseURL: URL,
        header: [String: String] = [:],
        queryParameters: [String: String] = [:]
    ) {
        self.baseURL = baseURL
        self.headers = header
        self.queryParameters = queryParameters
    }
}
