//
//  PaymentManagerView.swift
//  SubShare
//
//  Created by Konrad on 28/12/2021.
//

import SwiftUI
import CoreData

struct PaymentManagerView: View {
    
    @Environment(\.managedObjectContext) var moc
    @State var familymember : FamilyMemberModel
    @Binding var presentationMode : Bool
    @Binding var outstangingPayments : Int
    @State var paymentList : [String] = []
    let manager = SubscriptionManager.shared
    @AppStorage("appTheme") var systemTheme : String = "theme_yellow"

    init(familyMember: FamilyMemberModel, outstangingPayments: Binding<Int>, presentationModel : Binding<Bool>) {
        
        self._familymember = State(initialValue: familyMember)
        self._presentationMode = presentationModel
        self._outstangingPayments = outstangingPayments
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM y"
        let dateList = manager.generatePaymentList(for: familymember)
        _paymentList = State(initialValue: dateList.map {
            formatter.string(from: $0)
        })
    }
    
    var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Button {
                        if paymentList.count > 0 {
                            familymember.lastPaymentDate = manager.addPaymentInterval(for: familymember)
                            paymentList.removeFirst()
                            outstangingPayments = outstangingPayments - 1
                            let historyEntity = HistoryEntity(context: moc)
                            historyEntity.operation = "new_payment"
                            historyEntity.creationDate = Date()
                            historyEntity.member = familymember
                            historyEntity.subscription = familymember.subscription
                            historyEntity.id = UUID()
                            do {
                                try moc.save()
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10).stroke(Color(systemTheme), lineWidth: 3)
                            Text("Pay one").foregroundColor(Color(systemTheme)).bold()
                        }.frame(height: 50)
                    }.buttonStyle(PlainButtonStyle())
                    
                    Button {
                        if paymentList.count > 0 {
                            
                            familymember.lastPaymentDate = familymember.subscription.paymentDate
                            paymentList.removeAll()
                            outstangingPayments = 0
                            
                            let historyEntity = HistoryEntity(context: moc)
                            historyEntity.operation = "new_payment"
                            historyEntity.creationDate = Date()
                            historyEntity.member = familymember
                            historyEntity.subscription = familymember.subscription
                            historyEntity.id = UUID()
                            
                            do {
                                try moc.save()
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10).foregroundColor(Color(systemTheme))
                            Text("Pay all").foregroundColor(.black).bold()
                        }.frame(height: 50)
                    }
                    
                }
                Text("Missing payments:").font(.title2).bold().offset( y: 10)
                ScrollView {
                    ForEach(paymentList, id: \.self) { date in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color(systemTheme))
                                .opacity(0.9)
                            Text(date).bold().padding()
                        }
                    }
                }
            
        }.padding()
            .navigationBarTitle(familymember.name, displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                presentationMode = false
            }, label: {
                Text("Back")
            }))
    }
}

//struct PaymentManagerView_Previews: PreviewProvider {
//    static var previews: some View {
//        PaymentManagerView(familymember: FamilyMemberModel())
//    }
//}
