//
//  NetworkConfigurableMock.swift
//  BookUIKitTests
//
//  Created by jiin heo on 10/30/24.
//

import Foundation

class NetworkConfigurableMock: NetworkConfigurable {
    var baseURL: URL = URL(string: "https://mock.test.com")!
    var headers: [String: String] = [:]
    var queryParameters: [String: String] = [:]
}
