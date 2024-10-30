//
//  SearchMoviesUseCase.swift
//  BookUIKit
//
//  Created by jiin heo on 10/27/24.
//

import Foundation

struct SearchMoviesUseCaseRequestValue {
    let query: MovieQuery
    let page: Int
}

protocol SearchMoviesUseCase {
    func execute(
        requestValue: SearchMoviesUseCaseRequestValue,
        cached: @escaping (MoviesPage) -> Void,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultSearchMoviesUseCase: SearchMoviesUseCase {
    
    private let moviewRepository: MoviesRepository
    private let moviewQueriesRepository: MoviesQueriesRepository
    
    init(
        moviesRepository: MoviesRepository,
        moviesQueriesRepository: MoviesQueriesRepository
    ) {
        self.moviewRepository = moviesRepository
        self.moviewQueriesRepository = moviesQueriesRepository
    }
    
    func execute(
        requestValue: SearchMoviesUseCaseRequestValue,
        cached: @escaping (MoviesPage) -> Void,
        completion: @escaping (Result<MoviesPage, any Error>) -> Void) -> (any Cancellable)? {
            
            return moviewRepository.fetchMoviesList(
                query: requestValue.query,
                page: requestValue.page,
                cached: cached) { result in
                    if case .success = result {
                        self.moviewQueriesRepository.saveRecentQuery(query: requestValue.query) { _ in }
                    }
                    completion(result)
                }
        }
}
