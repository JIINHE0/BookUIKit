//
//  FetchRecentMovieQueriesUseCase.swift
//  BookUIKit
//
//  Created by jiin heo on 10/27/24.
//

import Foundation

// 더 일반적인 방법을 사용하여 UseCase를 생성하는 옵션
final class FetchRecentMovieQueriesUseCase: UseCase {
    
    struct RequestValue {
        let maxCoun: Int
    }
    
    typealias ResultValue = (Result<[MovieQuery], Error>)
    
    private let requestValue: RequestValue
    private let completion: (ResultValue) -> Void
    private let moviesQueriesRepository: MovieQueriesRepository
    
    init(
        requestValue: RequestValue,
        completion: @escaping (ResultValue) -> Void,
        moviesQueriesRepository: MovieQueriesRepository
    ) {
        self.requestValue = requestValue
        self.completion = completion
        self.moviesQueriesRepository = moviesQueriesRepository
    }
    
    func start() -> Cancellable? {
        moviesQueriesRepository.fetchRecentsQueries(maxCount: requestValue.maxCoun, comletion: completion)
        return nil
    }
}
