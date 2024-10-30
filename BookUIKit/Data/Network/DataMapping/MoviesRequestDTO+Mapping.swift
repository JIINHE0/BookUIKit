//
//  MoviesRequestDTO+Mapping.swift
//  BookUIKit
//
//  Created by jiin heo on 10/27/24.
//

import Foundation

// 인코딩
struct MoviesRequestDTO: Encodable {
    let query: String
    let page: Int
}
