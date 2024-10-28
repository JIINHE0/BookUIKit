//
//  CoreDataMoviesResponseStorage.swift
//  BookUIKit
//
//  Created by jiin heo on 10/28/24.
//

import Foundation
import CoreData

final class CoreDataMoviesResponseStorage {
    
    private let coreDataStorage: CoreDataStorage
    
    init(coreDataStorage: CoreDataStorage = CoreDataStorage.shared) {
        self.coreDataStorage = coreDataStorage
    }
        
    // MARK: - Private
    private func fetchRequest(for requestDto: MoviesRequestDTO) -> NSFetchRequest<MoviesRequestEntity> {
        let request: NSFetchRequest = MoviesRequestEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@ AND %K = %d",
                                        #keyPath(MoviesRequestEntity.query), requestDto.query,
                                        #keyPath(MoviesRequestEntity.page), requestDto.page)
        return request
    }
    
    private func deletReponse(for requestDto: MoviesRequestDTO, in context: NSManagedObjectContext) {
        let request = fetchRequest(for: requestDto)
        
        do {
            if let result = try context.fetch(request).first {
                context.delete(result)
            }
        } catch {
            print(error)
        }
    }
}

extension CoreDataMoviesResponseStorage: MoviesResponseStorage {
    
    func getResponse(for requestDto: MoviesRequestDTO, completion: @escaping (Result<MoviesResponseDTO, any Error>) -> Void) {
        coreDataStorage.performBackgroundTask { context in
            do {
                let fetchRequest = self.fetchRequest(for: requestDto)
                let requestEntity = try context.fetch(fetchRequest).first
                
                completion(.success(requestEntity?.response?.toDTO()))
            }
        }
    }
    
    func save(response: MoviesResponseDTO, for requestDto: MoviesRequestDTO) {
        <#code#>
    }
    
    
}

