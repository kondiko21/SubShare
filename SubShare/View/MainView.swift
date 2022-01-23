//
//  MainView.swift
//  SubShare
//
//  Created by Konrad on 23/12/2021.
//

import SwiftUI

struct MainView: View {
    var body: some View {
            TabView {
                NavigationView {
                    HomeView()
                }
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                NavigationView {
                    SubscriptionView()
                        .navigationTitle("Subscriptions")
                }
                .tabItem {
                    Label("Subscriptions", systemImage: "book.fill")
                }
                NavigationView {
                    SettingsView()
                        .navigationTitle("Settings")
                }
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                    .accentColor(.yellow)
            }
            .accentColor(.yellow)
        }
}

//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
