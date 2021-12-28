//
//  SubShareApp.swift
//  SubShare
//
//  Created by Konrad on 23/12/2021.
//

import SwiftUI

@main
struct SubShareApp: App {
    let persistenceController = PersistenceController.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
