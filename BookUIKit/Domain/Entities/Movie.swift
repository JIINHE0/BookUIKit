//
//  Movie.swift
//  BookUIKit
//
//  Created by jiin heo on 10/27/24.
//

import Foundation

struct Movie: Equatable, Identifiable {
    typealias Identifier = String
    
    enum Genre {
        case adventure
        case scienceFiction
    }
    
    var id: Identifier
    var title: String?
    var genre: Genre?
    var posterPath: String?
    var overview: String?
    var releaseDate: Date?
}

struct MoviesPage: Equatable {
    let page: Int
    let totalPages: Int
    let movies: [Movie]
}


