//
//  PosterImagesRepository.swift
//  BookUIKit
//
//  Created by jiin heo on 10/27/24.
//

import Foundation

protocol PosterImagesRepository {
    func fetchImage(
        with imagePath: String,
        width: Int,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> Cancellable?
}
