//
//  PersistenceController.swift
//  ChefIQApp
//
//  Created by Andreas Pelczer on 03.01.26.
//


import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // Preview für den SwiftUI-Designer (Simuliert Daten)
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // Hier könnten wir Test-Items für die Preview erstellen
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // WICHTIG: Der Name muss exakt wie deine .xcdatamodeld Datei sein
        container = NSPersistentContainer(name: "ChefIQ") 
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // In einer produktiven App sollte man hier einen sauberen Error-Dialog zeigen
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}