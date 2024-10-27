//
//  MovieQueriesRepository.swift
//  BookUIKit
//
//  Created by jiin heo on 10/27/24.
//

import Foundation

protocol MovieQueriesRepository {
    func fetchRecentsQueries(
        maxCount: Int,
        comletion: @escaping (Result<[MovieQuery], Error>) -> Void
    )
    
    func saveRecentQuery(
        query: MovieQuery,
        completion: @escaping (Result<MovieQuery, Error>) -> Void
    )
}
