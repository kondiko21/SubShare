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
    @Binding var familymember : FamilyMemberModel
    @Binding var presentationMode : Bool
    @Binding var outstangingPayments : Int
    @State var paymentList : [String] = []
    let manager = SubscriptionManager.shared
    
    init(familyMember: Binding<FamilyMemberModel>, outstangingPayments: Binding<Int>, presentationModel : Binding<Bool>) {
        
        self._familymember = familyMember
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
                            do {
                                try moc.save()
                            } catch {
                                print(error)
                            }
                    }
                    
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).stroke(Color.yellow, lineWidth: 3)
                        Text("Pay one").foregroundColor(.black).bold()
                    }.frame(height: 50)
                }
                Button {
                    if paymentList.count > 0 {
                        familymember.lastPaymentDate = familymember.subscription.paymentDate
                            paymentList.removeAll()
                            outstangingPayments = 0
                            do {
                                try moc.save()
                            } catch {
                                print(error)
                            }
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).foregroundColor(.yellow)
                        Text("Pay all").foregroundColor(.black).bold()
                    }.frame(height: 50)
                }

            }
            Text("Missing payments:").font(.title2).bold().offset( y: 10)
            ScrollView {
                ForEach(paymentList, id: \.self) { date in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.yellow)
                        .opacity(0.9)
                        Text(date).bold().padding()
                    }
                }
            }
        }.padding()
            .navigationTitle("Hubert")
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
