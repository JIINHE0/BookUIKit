//
//  Endpoint.swift
//  BookUIKit
//
//  Created by jiin heo on 10/26/24.
//

import Foundation

// 레이어를 나누는 이유?
// 유지보수를 쉽게 하기위해, 문제가 어디서 생겼는지 빨리 파악하기 위해

// MARK: - Endpoint
protocol Requestable {
    var baseURL: String { get }
    var path: String { get }
    var methdo: String { get }
    var queryParameter: Encodable? { get }
    var bodyparamaters: Encodable? { get }
    var header: [String: String]? { get }
    var sampleData: Data? { get }
}

