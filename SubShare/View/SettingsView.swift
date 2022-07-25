//
//  SetttingsView.swift
//  SubShare
//
//  Created by Konrad on 23/12/2021.
//

import SwiftUI
import AlertToast

struct SettingsView: View {
    
    @FetchRequest(
        entity: SubscriptionModel.entity(),
        sortDescriptors: []
    ) var subscriptionData: FetchedResults<SubscriptionModel>
    @FetchRequest(
        entity: FamilyMemberModel.entity(),
        sortDescriptors: []
    ) var members: FetchedResults<FamilyMemberModel>
    @Environment(\.managedObjectContext) var moc
    @State var deleteWarning = false
    @State var restoreAlert = false
    
    @AppStorage("selectedCurrency") var selectedCurrency : String = "$"
    @AppStorage("appTheme") var systemTheme : String = "theme_yellow"
    let themeList = ["theme_yellow", "theme_pink", "theme_green", "theme_blue"]
    var columns = [GridItem(.adaptive(minimum: 50, maximum: 200))]
    
    var body: some View {
        
            VStack {
                Form {
                    HStack {
                        Text("Currency symbol")
                        Spacer()
                        TextField("$", text: $selectedCurrency, onCommit: {
                            if selectedCurrency == "" {
                                selectedCurrency = "$"
                            }
                            if selectedCurrency.count > 3 {
                                selectedCurrency = String(selectedCurrency.prefix(3))
                            }
                        })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width:60)
                            .multilineTextAlignment(.trailing)
                    }
                Section(header: Text("Main app theme")) {
                    LazyVGrid(columns: columns) {
                        ForEach(themeList, id:\.self) { color in
                            if systemTheme == color {
                                Circle()
                                    .strokeBorder(Color.red, lineWidth: 4)
                                    .aspectRatio(1, contentMode: .fill)
                                    .background(
                                        Circle()
                                            .foregroundColor(Color(color))
                                    )
                            } else {
                                Circle()
                                    .foregroundColor(Color(color))
                                    .aspectRatio(1, contentMode: .fill)
                                    .onTapGesture {
                                        systemTheme = color
                                    }
                            }
                        }
                    }
                }
                    Section {
                        Button {
                            StoreManager().restoreProducts()
                            restoreAlert = true
                            
                        } label: {
                            Text("Restore Premium")
                        }
                    }
                    Section {
                        Button {
                            deleteWarning = true
                        } label: {
                            Text("Reset app").foregroundColor(.red)
                        }
                    }
                .alert(isPresented: $deleteWarning) {
                    Alert(
                        title: Text("Are you sure you want to delete?"),
                        primaryButton: .destructive(Text("Cancel")),
                        secondaryButton: .default(Text("Delete"), action: {
                            resetApp()
                        })
                        
                    )
                }
            }
        }
            .toast(isPresenting: $restoreAlert, duration: 2, tapToDismiss: true, alert: {
                
                AlertToast(type: .complete(Color("theme_yellow")), title: "Restored successfully", subTitle: "")

             })
    }
    
    func resetApp() {
        DispatchQueue.main.async {
            for object in subscriptionData {
                moc.delete(object)
                NotificationManager.shared.removeNotification(id: "\(object.id)")
            }
            for object in members {
                moc.delete(object)
            }
            let center = UNUserNotificationCenter.current()
            center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                NotificationManager.shared.removeNotification(id: request.identifier)
            }
                        })
            do {
                try moc.save()
            } catch {
                print(error)
            }
        }
    }
}

struct SetttingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
