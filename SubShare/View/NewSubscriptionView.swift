//
//  NewSubscriptionView.swift
//  SubShare
//
//  Created by Konrad on 23/12/2021.
//

import SwiftUI
import CoreData

struct NewSubscriptionView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("selectedCurrency") var currencyCode : String = "USD"
    @State  var selectedCurrency = ""
    
    @State var displayWarning = false
    @State private var warningString = ""
    @ObservedObject var subscription = SubscriptionViewModel()
    var numberFormatter = NumberFormatter()
    @AppStorage("appTheme") var systemTheme : String = "theme_yellow"

    
    init() {
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 2
        _selectedCurrency = State(initialValue: currencyCode)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Service").bold().font(.title3).offset(x: -15, y: 0).foregroundColor(.black)) {
                TextField("e.g Spotify, Netflix", text: $subscription.name)
            }
            
            //Primary information
            Section(header: Text("Primary informations").offset(x: -15, y: 0).foregroundColor(.black)) {
                HStack {
                    Text("Price")
                    Spacer()
                    TextField("30", value: $subscription.price, formatter: numberFormatter)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 60)
                        .multilineTextAlignment(.trailing)
                    Text(selectedCurrency)
                }.onChange(of: subscription.price) { newValue in
                    let newPrice = subscription.price / Double(subscription.familyCount+1)
                    if subscription.divideCostEqually {
                        subscription.memberPrices = subscription.memberPrices.map {_ in newPrice}
                    }
                }
                DatePicker(selection: $subscription.paymentDate, displayedComponents: .date) {
                    Text("Start date")
                }
                Toggle(isOn: $subscription.divideCostEqually) {
                    Text("Divide cost equally")
                }
                VStack (alignment: .leading) {
                    Text("Payment renewal")
                    Picker("Strength", selection: $subscription.everyMonthPayment) {
                        Text("Every month").tag(true)
                        Text("Every 30 days").tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                }
            }
            
            //Family part
            Section(header: Text("Family").offset(x: -15, y: 0).foregroundColor(.black)) {
                VStack {
                    ForEach(0...subscription.familyCount, id:\.self) { index in
                        HStack {
                            if index != 0 {
                                TextField("Name", text: $subscription.memberNames[index])
                            } else {
                                TextField("Name", text: $subscription.memberNames[index]).disabled(true)
                            }
                            TextField("Amount", value: $subscription.memberPrices[index], formatter: numberFormatter)
                                .disabled(subscription.divideCostEqually)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .frame(width:60)
                                .multilineTextAlignment(.trailing)
                            Text(selectedCurrency)
                        }
                    }
                    HStack {
                        Button {
                                if subscription.familyCount + 1 > subscription.memberNames.count - 1 {
                                subscription.memberNames.append("")
                                subscription.memberPrices.append(0)
                            }
                            subscription.familyCount += 1
                            let newPrice = subscription.price / Double(subscription.familyCount+1)
                            if subscription.divideCostEqually {
                                subscription.memberPrices = subscription.memberPrices.map {_ in newPrice}
                            }
                        } label: {
                            Text("Add")
                                .foregroundColor(Color(systemTheme))
                                .bold()
                        }.buttonStyle(BorderlessButtonStyle())
                        Spacer()
                        Button {
                            if subscription.familyCount > 0 {
                                subscription.memberNames[subscription.familyCount] = ""
                                subscription.memberPrices[subscription.familyCount] = 0
                                subscription.familyCount -= 1
                            }
                            
                            let newPrice = subscription.price / Double(subscription.familyCount)
                            if subscription.divideCostEqually {
                                subscription.memberPrices = subscription.memberPrices.map {_ in newPrice}
                            }
                            
                        } label: {
                            Text("Remove")
                                .foregroundColor(Color(systemTheme))
                                .bold()
                        }.buttonStyle(BorderlessButtonStyle())
                        
                    }.padding([.leading, .trailing])
                }
                
            }
            Button {
                let warningList = subscription.generateWarning()
                if warningList.isEmpty {
                    subscription.save()
                    presentationMode.wrappedValue.dismiss()
                } else {
                    warningString = ""
                    for item in warningList {
                        warningString += "\(item.rawValue)\n"
                    }
                    displayWarning = true
                }
                
            } label: {
                Text("Submit").foregroundColor(Color(systemTheme)).bold()
            }
            
            .navigationTitle(subscription.name != "" ? "Adding \(subscription.name)" : "Add subscription")
        }
        .alert(isPresented: $displayWarning) {
            Alert(
                title: Text("Incorrect data"),
                message: Text(warningString),
                dismissButton: .default(Text("Got it!"))
            )
        }
        .onAppear {
            subscription.moc = moc  // << set up context here
        }
    }
    
    
    struct NewSubscriptionView_Previews: PreviewProvider {
        static var previews: some View {
            NewSubscriptionView()
        }
    }
    
    enum DataValidationMessages : String {
        case name = "You need to set subscription name!"
        case price = "Your price must be diffrent than 0!"
        case family = "You need to add family members!"
        case date = "You can't subscription date for future!"
    }
    
}
