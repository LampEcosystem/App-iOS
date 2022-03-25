//
//  MoonLampApp.swift
//  MoonLamp
//

import SwiftUI

@main
struct MoonLampApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            DeviceBroswerView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
