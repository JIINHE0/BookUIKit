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
        // predicate: 검색 조건
        request.predicate = NSPredicate(format: "%K = %@ AND %K = %d", // 문자열 비교 "%K = %@, 정수비교 %K = %d K는 Key Path자리로, CoreData 엔티티의 특정 프로퍼티 이름을 나타냄
                                        #keyPath(MoviesRequestEntity.query), requestDto.query,
                                        #keyPath(MoviesRequestEntity.page), requestDto.page)
        /*
         MoviesRequestEntity.query가 requestDto.query와 일치해야 함
         MoviesRequestEntity.page가 requestDto.page와 일치해야 함
         
         #keyPath는 컴파일 시점에 속성 이름의 정확성을 검증합니다.
         오타나 존재하지 않는 속성 이름을 사용할 경우 컴파일 에러를 발생시킵니다.
         
         장점:
         문자열 리터럴을 직접 사용하는 것보다 안전합니다.
         코드 리팩토링 시 속성 이름 변경이 용이합니다.
         
         동작:
         MoviesRequestEntity.query와 MoviesRequestEntity.page라는 속성 경로를 문자열로 변환합니다.
         이 문자열은 NSPredicate에서 사용되어 Core Data 쿼리의 조건을 지정합니다.
         
         대안:
         Swift 5.0 이상에서는 \MoviesRequestEntity.query와 같은 키 경로(key path) 문법도 사용할 수 있습니다.
         #keyPath를 사용함으로써, 개발자는 타입 안전성을 유지하면서 동적으로 속성에 접근할 수 있는 문자열을 생성할 수 있습니다. 이는 특히 Core Data와 같은 프레임워크에서 유용하게 사용됩니다
         */
        return request
    }
    
    private func deleteReponse(for requestDto: MoviesRequestDTO, in context: NSManagedObjectContext) {
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
    
    func getResponse(
        for requestDto: MoviesRequestDTO,
        completion: @escaping (Result<MoviesResponseDTO?, any Error>) -> Void
    ) {
        coreDataStorage.performBackgroundTask { context in
            do {
                let fetchRequest = self.fetchRequest(for: requestDto)
                let requestEntity = try context.fetch(fetchRequest).first
                
                completion(.success(requestEntity?.response?.toDTO()))
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
    
    func save(
        response responseDto: MoviesResponseDTO,
        for requestDto: MoviesRequestDTO
    ) {
        coreDataStorage.performBackgroundTask { context in
            do {
                self.deleteReponse(for: requestDto, in: context)
                
                let requestEntity = requestDto.toEntity(in: context)
                requestEntity.response = responseDto.toEntity(in: context)
                
                try context.save()
            } catch {
                debugPrint("CoreDataMoviesResponseStorage Unresolved error \(error), \((error as NSError).userInfo)")
            }
        }
    }
    
    
}

