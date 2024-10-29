//
//  MoviewResponseStorage.swift
//  BookUIKit
//
//  Created by jiin heo on 10/28/24.
//

import Foundation

protocol MoviesResponseStorage {
    
    func getResponse(for request: MoviesRequestDTO, completion: @escaping (Result<MoviesResponseDTO?, Error>) -> Void)
    
    func save(response: MoviesResponseDTO, for requestDto: MoviesRequestDTO)
}
