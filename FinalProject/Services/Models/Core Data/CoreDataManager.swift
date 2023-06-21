//
//  CoreDataManager.swift
//  homework-7
//
//  Created by sergey on 08.06.2023.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Data")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    lazy var mainContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    func saveContext() {
        mainContext.perform { [self] in
            do {
                try mainContext.save()
            } catch let error as NSError {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
}
