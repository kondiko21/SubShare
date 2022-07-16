//
//  SubShareApp.swift
//  SubShare
//
//  Created by Konrad on 23/12/2021.
//

import SwiftUI
import StoreKit
import Firebase

@main
struct SubShareApp: App {
    let persistenceController = PersistenceController.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
    
    @StateObject var storeManager = StoreManager()
    

    var body: some Scene {
        WindowGroup {
            MainView()
                    .environmentObject(storeManager)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .onAppear(perform: {
                                storeManager.getProducts(productIDs: ["com.kondiko.subshare.pro"])
                                SKPaymentQueue.default().add(storeManager)
//                        FirebaseApp.configure()
                            })
        }
    }
}
