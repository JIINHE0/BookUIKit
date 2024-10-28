//
//  MovieQueryEntity+Mapping.swift
//  BookUIKit
//
//  Created by jiin heo on 10/28/24.
//

import Foundation
import CoreData

extension MovieQueryEntity {
    convenience init(movieQuery: MovieQuery, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        query = movieQuery.query
        createsAt = Date()
    }
}

extension MovieQueryEntity {
    func toDomain() -> MovieQuery {
        return .init(query: query ?? "")
    }
}
