//
//  MoviesQueryListItemViewModel.swift
//  BookUIKit
//
//  Created by jiin heo on 10/30/24.
//

import Foundation

class MoviesQueryListItemViewModel {
    let query: String

    init(query: String) {
        self.query = query
    }
}

extension MoviesQueryListItemViewModel: Equatable {
    static func == (lhs: MoviesQueryListItemViewModel, rhs: MoviesQueryListItemViewModel) -> Bool {
        return lhs.query == rhs.query
    }
}
