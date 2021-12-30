//
//  NewSubscriptionView.swift
//  SubShare
//
//  Created by Konrad on 23/12/2021.
//

import SwiftUI
import CoreData

struct EditSubscriptionView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    var numberFormatter = NumberFormatter()
    
    @State var displayWarning = false
    @State private var warningString = ""
    var subscriptionData : SubscriptionModel?
    @ObservedObject var subscription : SubscriptionViewModel
    
    init(subscriptionData: SubscriptionModel) {
        self.subscription = SubscriptionViewModel(subscription: subscriptionData)
        self.subscriptionData = subscriptionData
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 2
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
                    TextField("30", value: $subscription.price, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 60)
                        .multilineTextAlignment(.trailing)
                    Text("zl")
                }.onChange(of: subscription.price) { newValue in
                    let newPrice = subscription.price / Double(subscription.memberNames.count)
                    if subscription.divideCostEqually {
                        subscription.memberPrices = subscription.memberPrices.map {_ in newPrice}
                    }
                }
                .onChange(of: subscription.divideCostEqually) { newValue in
                    let newPrice = subscription.price / Double(subscription.memberNames.count)
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
                    ForEach($subscription.memberNames.indices, id:\.self) {index in
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
                            Text("zł")
                        }
                    }
                    HStack {
                        Button {
                            subscription.memberNames.append("")
                            subscription.memberPrices.append(0)
                            let newPrice = subscription.price / Double(subscription.memberNames.count)
                            if subscription.divideCostEqually {
                                subscription.memberPrices = subscription.memberPrices.map {_ in newPrice}
                            }
                        } label: {
                            Text("Add")
                                .foregroundColor(.yellow)
                                .bold()
                        }.buttonStyle(BorderlessButtonStyle())
                        Spacer()
                        Button {
                            if subscription.memberPrices.count > 1 {
                                subscription.memberNames.removeLast()
                                subscription.memberPrices.removeLast()
                            }
                            let newPrice = subscription.price / Double(subscription.memberNames.count)
                            if subscription.divideCostEqually {
                                subscription.memberPrices = subscription.memberPrices.map {_ in newPrice}
                            }
                            
                        } label: {
                            Text("Remove")
                                .foregroundColor(.yellow)
                                .bold()
                        }.buttonStyle(BorderlessButtonStyle())

                    }.padding([.leading, .trailing])
                }
                
        }
        Button {
            let warningList = subscription.generateWarning()
            if warningList.isEmpty {
                subscription.saveEdit()
                presentationMode.wrappedValue.dismiss()
            } else {
                warningString = ""
                for item in warningList {
                    warningString += "\(item.rawValue)\n"
                }
                displayWarning = true
            }
            
        } label: {
            Text("Edit").foregroundColor(.yellow).bold()
        }
        .navigationTitle(subscription.name != "" ? "Adding \(subscription.name)" : "Add subscription")
                .navigationBarItems(trailing: Button(action: {
                    moc.delete(subscriptionData!)
                    do {
                        try moc.save()
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        print(error)
                    }
                }, label: {
                    Text("Delete").foregroundColor(.red).bold()
                }))
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
