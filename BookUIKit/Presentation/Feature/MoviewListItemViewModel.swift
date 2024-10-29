//
//  MoviewListItemViewModel.swift
//  BookUIKit
//
//  Created by jiin heo on 10/29/24.
//

import Foundation

struct MoviesListItemViewModel: Equatable {
    let title: String
    let overvies: String
    let releaseDate: String
    let posterImagePath: String?
}

extension MoviesListItemViewModel {
    
    init (movie: Movie) {
        self.title = movie.title ?? ""
        self.overvies = movie.overview ?? ""
        self.posterImagePath = movie.posterPath
        if let releaseDate = movie.releaseDate {
            self.releaseDate = "\(NSLocalizedString("Release Date", comment: "")): \(dateFormatter.string(from: releaseDate))"
        } else {
            self.releaseDate = NSLocalizedString("To be announced", comment: "")
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
