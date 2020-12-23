//
//  PatientApp.swift
//  Shared
//
//  Created by Johan Sellström on 2020-10-18.
//

import SwiftUI

@main
struct PatientApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
