import SwiftUI
import CoreData

struct SubscriptionView: View {
    
    @FetchRequest(
        entity: SubscriptionModel.entity(),
        sortDescriptors: []
    ) var subscriptions: FetchedResults<SubscriptionModel>
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
            ScrollView {
                VStack {
                    ForEach(subscriptions, id: \.id) { subscription in
                        if !subscription.isFault {
                            SingleSubscription(subscription).padding()
                        } else {
                            EmptyView()
                        }
                    }
                }
            }
    }
}

struct SingleSubscription: View {
    
    var subscription : SubscriptionModel
    let subscriptionManager = SubscriptionManager.shared
    var formatter = DateFormatter()
    var nextPaymentDate = ""
    
    init(_ subscription: SubscriptionModel) {
        self.subscription = subscription
        formatter.dateFormat = "DD MMM YYYY"
        nextPaymentDate = formatter.string(from: subscriptionManager.addPaymentInterval(for: subscription))
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .foregroundColor(.gray)
                .opacity(0.15)
            VStack(alignment: .leading) {
                HStack {
                    Text(subscription.name).font(.title).bold()
                    Spacer()
                }
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.yellow)
                    VStack(alignment: .leading) {
                        Text("Last payment: \(formatter.string(from: subscription.paymentDate))").foregroundColor(.black)
                        Text("Next payment: \(nextPaymentDate)").foregroundColor(.black)
                    }.padding(5)
                }.frame(height:30, alignment: .leading).padding(.bottom)
                Text("Family:").bold()
                ForEach(subscription.familyMemberArray, id: \.id) { member in
                    PersonSubscriptionView(member).padding(.bottom, 5)
                }
                Spacer()
            }.padding()
        }
    }
}

//struct MyView_Previews: PreviewProvider {
//    static var previews: some View {
//        SingleSubscription()
//    }
//}

struct PersonSubscriptionView: View {
    
    var member : FamilyMemberModel
    let subscriptionManager = SubscriptionManager.shared
    @State var outstandingPaymentAmount : State<Int>
    
    init(_ member: FamilyMemberModel) {
        self.member = member
        outstandingPaymentAmount = State(initialValue: subscriptionManager.countMissingPayments(for: member))
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.yellow, lineWidth: 2)
            HStack{
                VStack(alignment: .leading) {
                    Text(member.name)
                        .bold()
                        .padding(.leading)
                        .padding(.top, 8)
                    Text("Outstanding payments: \(outstandingPaymentAmount.wrappedValue)").padding(.leading)
                        .padding(.bottom, 8)
                }
                Spacer()
                Image(systemName: "info.circle").padding(.trailing)
            }
        }.frame(height:50)
    }
}

//struct PersonSubscriptionView_Previews: PreviewProvider {
//    static var previews: some View {
//        PersonSubscriptionView()
//    }
//}
