//
//  SlaskApp.swift
//  Slask WatchKit Extension
//
//  Created by Johan Sellström on 2020-11-08.
//

import SwiftUI
import CareKit
import CareKitStore
import WatchConnectivity
import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    private lazy var peer = OCKWatchConnectivityPeer()
    private lazy var store = OCKStore(name: "catalog-store", type: .inMemory, remote: OCKWatchConnectivityPeer())

    private(set) lazy var storeManager = OCKSynchronizedStoreManager(wrapping: store)

    private lazy var sessionManager: SessionManager = {
        let delegate = SessionManager()
        delegate.peer = peer
        delegate.store = store
        return delegate
    }()

    func applicationDidFinishLaunching() {
        print("applicationDidFinishLaunching")
        peer.automaticallySynchronizes = true

        WCSession.default.delegate = sessionManager
        WCSession.default.activate()
    }

    func applicationDidBecomeActive() {
        print("applicationDidBecomeActive")
        store.synchronize { error in
            print(error?.localizedDescription ?? "Successful sync!")
        }
    }

}

@main
struct SlaskApp: App {

    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var extensionDelegate

    @Environment(\.scenePhase) private var scenePhase

    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                if #available(watchOS 7, *) {
                    VStack(spacing: 16) {
                        SimpleTaskView(taskID: "doxylamine", eventQuery: .init(for: Date()), storeManager: extensionDelegate.storeManager)
                        //InstructionsTaskView(taskID: "doxylamine", eventQuery: .init(for: Date()), storeManager: storeManager)
                    }
                }
            }
        }.onChange(of: scenePhase) { phase in
            print("phase \(phase)")
            if phase == .background {
               //perform cleanup
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }

}

class SessionManager: NSObject, WCSessionDelegate {

    fileprivate(set) var peer: OCKWatchConnectivityPeer!
    fileprivate(set) var store: OCKStore!

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?) {

        print("New session state: \(activationState)")
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void) {

        print("Received message from peer!")

        peer.reply(to: message, store: store) { reply in
            replyHandler(reply)
        }
    }
}


