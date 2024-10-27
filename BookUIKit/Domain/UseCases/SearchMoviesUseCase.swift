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
    func excute(
        requestValue: SearchMoviesUseCaseRequestValue,
        cached: @escaping (MoviesPage) -> Void,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultSearchMoviesUseCase: SearchMoviesUseCase {
    
    private let moviewRepository: MoviesRepository
    private let moviewQueriesRepository: MoviewQueriesRepository
    
    init(
        moviewRepository: MoviesRepository,
        moviewQueriesRepository: MoviewQueriesRepository
    ) {
        self.moviewRepository = moviewRepository
        self.moviewQueriesRepository = moviewQueriesRepository
    }
    
    func excute(
        requestValue: SearchMoviesUseCaseRequestValue,
        cached: @escaping (MoviesPage) -> Void,
        completion: @escaping (Result<MoviesPage, any Error>) -> Void) -> (any Cancellable)? {
            
            return moviewRepository.fetchVoviesList(
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
