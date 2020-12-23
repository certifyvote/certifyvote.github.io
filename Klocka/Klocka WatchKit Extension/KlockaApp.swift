//
//  KlockaApp.swift
//  Klocka WatchKit Extension
//
//  Created by Johan Sellström on 2020-11-07.
//

import SwiftUI

@main
struct KlockaApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
