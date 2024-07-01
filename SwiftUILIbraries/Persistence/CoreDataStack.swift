//
//  CoreDataStack.swift
//  SwiftLibraries
//
//  Created by Allan Evans on 5/16/24.
//  Copyright © 2024 AGE Software Consulting, LLC. All rights reserved.
//

import CoreData
import Foundation

class CoreDataStack {
    static let shared = CoreDataStack()
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ChiLibsDataModel")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("failed to load persisten stores: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}

extension CoreDataStack {
    func saveContext() {
        guard viewContext.hasChanges else { return }
        do {
            try viewContext.save()
        } catch {
            let error = error as NSError
            NSLog("error saving context: \(error), \(error.userInfo)")
        }
    }
    
    func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) -> [T] {
        do {
            return try viewContext.fetch(request)
        } catch {
            return []
        }
    }
}
