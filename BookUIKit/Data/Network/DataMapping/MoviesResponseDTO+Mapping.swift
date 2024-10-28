//
//  MoviesResponseDTO+Mapping.swift
//  BookUIKit
//
//  Created by jiin heo on 10/27/24.
//

import Foundation

// 디코딩
struct MoviesResponseDTO: Decodable {
    private enum codingKeys: String, CodingKey {
        case page
        case totlaPages = "total_pages"
        case movies = "results"
    }
    
    let page: Int
    let totalPages: Int
    let movies: [MovieDTO]
}

extension MoviesResponseDTO {
    
    struct MovieDTO: Decodable {
        private enum CodingKeys: String, CodingKey {
            case id
            case title
            case genre
            case posterPath = "poster_path"
            case overview
            case releaseDate = "release_date"
        }
        
        enum GenreDTO: String, Decodable {
            case adventure
            case scienceFiction = "science_fiction"
        }
        
        let id: Int
        let title: String?
        let genre: GenreDTO?
        let posterPath: String?
        let overview: String?
        let releaseDate: String?
    }
    
}
