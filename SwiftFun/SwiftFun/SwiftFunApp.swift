//
//  SwiftFunApp.swift
//  SwiftFun
//
//  Created by Johan Sellström on 2020-09-26.
//

import SwiftUI

@main
struct SwiftFunApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
