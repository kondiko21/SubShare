//
//  HomeView.swift
//  SubShare
//
//  Created by Konrad on 23/12/2021.
//

import SwiftUI

struct HomeView: View {
    
    @FetchRequest(
        entity: FamilyMemberModel.entity(),
        sortDescriptors: []
    ) var members: FetchedResults<FamilyMemberModel>
    @Environment(\.managedObjectContext) var moc
    let subscriptionManager = SubscriptionManager.shared
    @AppStorage("appTheme") var systemTheme : String = "theme_yellow"

    var body: some View {
        if members.count != 0 {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(),spacing: 20), GridItem(.flexible(), spacing: 20)],alignment: .leading, spacing: 20) {
                    ForEach(members, id: \.id) { member in
                        if subscriptionManager.countMissingPayments(for: member) > 0 && member.order != 0 {
                                PersonShortcutView(person: member)
                                    .aspectRatio(1, contentMode: .fill)
                        }
                    }
            }
            .padding(10)
            .padding(.top, 10)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    LinearGradient(gradient: Gradient(colors: [Color(systemTheme), Color("\(systemTheme)_reversed")]),
                                   startPoint: .bottomTrailing,
                                   endPoint: .topLeading)
                        .mask(Text("SubShare").bold().font(.largeTitle).font(.system(size: 35)))
                    .accessibilityAddTraits(.isHeader)
                }
            }
        }
        } else {
            HStack(alignment: .center) {
                Text("Any subscriptions added yet.\nGo to subscription section and add your first subscription!").font(.headline).multilineTextAlignment(.center)
            }
                .padding()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        LinearGradient(gradient: Gradient(colors: [Color(systemTheme), Color("\(systemTheme)_reversed")]),
                                       startPoint: .bottomTrailing,
                                       endPoint: .topLeading)
                            .mask(Text("SubShare").bold().font(.largeTitle).font(.system(size: 35)))
                        .accessibilityAddTraits(.isHeader)
                    }
                }
        }
            
    }
}

struct PersonShortcutView: View {
    
    var person : FamilyMemberModel
    let manager = SubscriptionManager()
    let numberFormatter = NumberFormatter()
    @State var paymentAmount : Double
    @State var paymentCount : Int
    @AppStorage("selectedCurrency") var currencyCode : String = "USD"
    @Environment(\.managedObjectContext) var moc
    @AppStorage("appTheme") var systemTheme : String = "theme_yellow"

 
    init(person : FamilyMemberModel) {
        self.person = person
        numberFormatter.maximumIntegerDigits = 2
        _paymentCount = State(initialValue: manager.countMissingPayments(for: person))
        _paymentAmount = State(initialValue: (Double(manager.countMissingPayments(for: person)) * person.value))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(Color(systemTheme))
                VStack(alignment: .leading) {
                    Text(person.name).font(.largeTitle).foregroundColor(.black).bold()
                    Text("Value of payments:").foregroundColor(.black)
                        .font(.headline)
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.white)
                        HStack {
                            Text("\(paymentAmount, specifier: "%0.2f \(getSymbol(forCurrencyCode: currencyCode)!)")").foregroundColor(.black)
                                .font(.headline)
                                .padding(.leading, 10)
                                .padding([.top, .bottom], 5)
                            .padding(1)
                            Spacer()
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.black)
                                Text("\(paymentCount)")
                                    .foregroundColor(.white)
                                    .padding([.leading, .trailing], 10)
                            }.padding(0)
                            .fixedSize(horizontal: true, vertical: false)

                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    Button {
                        if paymentCount > 0 {
                            paymentCount -= 1
                            paymentAmount -=  person.value
                            person.lastPaymentDate = manager.addPaymentInterval(for: person)
                            do {
                                try moc.save()
                            } catch {
                                print(error)
                            }
                            print(person.lastPaymentDate)
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.white)
                            Text("PAY ONE")
                                .foregroundColor(.black)
                                .bold()
                        }
                    }

                }.padding()
            }
        }
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
