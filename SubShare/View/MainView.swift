//
//  MainView.swift
//  SubShare
//
//  Created by Konrad on 23/12/2021.
//

import SwiftUI

struct MainView: View {
    
    @AppStorage("appTheme") var systemTheme : String = "theme_yellow"
    var hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
    @State var isActive : Bool
    @EnvironmentObject var storeManager : StoreManager
    
    init() {
        if !hasLaunchedBefore {
            _isActive = State(initialValue: true)
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        } else {
            _isActive = State(initialValue: false)
        }
    }

    var body: some View {
//        Text("\(storeManager.products.count)")
            TabView {
                NavigationView {
                    HomeView()
                }
                .navigationBarHidden(true)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                NavigationView {
                    SubscriptionView()
                        .navigationTitle("Subscriptions")
                }
                .navigationBarHidden(true)
                .navigationTitle(Text(""))
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
                    .accentColor(Color(systemTheme))
            }
            .accentColor(Color(systemTheme))
            .sheet(isPresented: $isActive, content: {
                OnboardingView(isActive: $isActive)
            })
            .navigationBarBackButtonHidden(true)
        }
}

//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
