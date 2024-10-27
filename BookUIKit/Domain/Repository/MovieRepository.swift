//
//  MovieRepository.swift
//  BookUIKit
//
//  Created by jiin heo on 10/27/24.
//

import Foundation

protocol MovieRepository {
    @discardableResult
    func fetchVoviesList(
        query: MovieQuery,
        page: Int,
        cached: @escaping (MoviesPage) -> Void,
        completion: @escaping (Result<MoviesPage, Error>) -> Void)
    -> Cancellable?
}
