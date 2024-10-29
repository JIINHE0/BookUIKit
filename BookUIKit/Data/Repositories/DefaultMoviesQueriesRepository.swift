//
//  DefaultMoviesQueriesRepository.swift
//  BookUIKit
//
//  Created by jiin heo on 10/29/24.
//

import Foundation

final class DefaultMoviesQueriesRepository {
    
    private var moviesQueriesPersistentStorage: MoviesQueriesStorage
    
    init(moviesQueriesPersistentStorage: MoviesQueriesStorage) {
        self.moviesQueriesPersistentStorage = moviesQueriesPersistentStorage
    }
}

extension DefaultMoviesQueriesRepository: MoviesQueriesRepository {
    
    func fetchRecentsQueries(maxCount: Int, completion: @escaping (Result<[MovieQuery], any Error>) -> Void) {
        return moviesQueriesPersistentStorage.fetchRecentsQueries(maxCount: maxCount, completion: completion)
    }
    
    func saveRecentQuery(query: MovieQuery, completion: @escaping (Result<MovieQuery, any Error>) -> Void) {
        moviesQueriesPersistentStorage.saveRecentQuery(query: query, completion: completion)
    }
    
    
}
