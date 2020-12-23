//
//  MessApp.swift
//  Shared
//
//  Created by Johan Sellström on 2020-10-19.
//

import SwiftUI

@main
struct MessApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
