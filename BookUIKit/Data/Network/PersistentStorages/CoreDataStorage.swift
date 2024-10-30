//
//  CoreDataStorage.swift
//  BookUIKit
//
//  Created by jiin heo on 10/28/24.
//

import CoreData

enum CoreDataStorageError: Error {
    case readError(Error)
    case saveError(Error)
    case deleteError(Error)
}

final class CoreDataStorage {
    
    static let shared = CoreDataStorage()
    
    // MARK: -  Core Data stack
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataStorage")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // TODO: - Log to Crashlytics
                assertionFailure("CoreDataStorage unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                // 메인 스레드에서 저장
                try context.save()
            } catch {
                // TODO: - Log to Crashlytics
                assertionFailure("CoreDataStorage unresolved error \(error), \((error as NSError).userInfo)")
            }
        }
    }

    // 백그라운드에서 작업 수행
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
}
