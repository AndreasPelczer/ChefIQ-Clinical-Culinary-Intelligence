//
//  ChefIQApp.swift
//  ChefIQApp
//
//  Created by Andreas Pelczer on 03.01.26.
//


import SwiftUI

@main
struct ChefIQApp: App {
    // Wir laden den PersistenceController (Core Data)
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                // Der managedObjectContext wird hier in die Umgebung (Environment) 
                // eingeschleust, damit alle Views darauf zugreifen können.
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}