import SwiftUI
import CoreData
import LinkPresentation

struct SubscriptionView: View {
    
    @FetchRequest(
        entity: SubscriptionModel.entity(),
        sortDescriptors: []
    ) var subscriptions: FetchedResults<SubscriptionModel>
    @Environment(\.managedObjectContext) var moc
    @AppStorage("appTheme") var systemTheme : String = "theme_yellow"
    @AppStorage("com.kondiko.subshare.pro") var premiumUser : Bool = false
    @State var isBuyPremiumPresented = false
    @EnvironmentObject var storeManager : StoreManager
    
    
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
                if subscriptions.count >= 1 && !premiumUser {
                    Button {
                        isBuyPremiumPresented = true
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundColor(Color(systemTheme))
                            Text("Add new").bold().padding().foregroundColor(Color.black)
                        }
                        .padding()
                        .padding(.leading, 30)
                        .padding(.trailing, 30)
                    }
                    
                } else {
                    NavigationLink {
                        NewSubscriptionView()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundColor(Color(systemTheme))
                            Text("Add new").bold().padding().foregroundColor(Color.black)
                        }
                        .padding(.top)
                        .padding(.leading, 30)
                        .padding(.trailing, 30)
                    }
                    //                    }
                    Spacer()
                }
                Spacer()
                if premiumUser {
                    Text("You own Premium version").font(.footnote).fontWeight(.light)
                }
            }
            .sheet(isPresented: $isBuyPremiumPresented) {
                NavigationView {
                    BuyPremiumView(presentationMode: $isBuyPremiumPresented).environmentObject(storeManager)
                }
            }
            .toolbar {
                NavigationLink {
                    HistoryView()
                        .navigationTitle(Text("History"))
                    
                } label: {
                    Text("History")
                }
                
            }
        }
    }
    
    struct SingleSubscription: View {
        
        @State var subscription : SubscriptionModel
        let subscriptionManager = SubscriptionManager.shared
        var formatter = DateFormatter()
        var nextPaymentDate = ""
        @Environment(\.managedObjectContext) var moc
        @AppStorage("appTheme") var systemTheme : String = "theme_yellow"
        
        
        init(_ subscription: SubscriptionModel) {
            self.subscription = subscription
            formatter.dateFormat = "d MMM YYYY"
            if !subscription.isFault {
                if subscription.paymentDate <= Date() {
                    while subscriptionManager.addPaymentInterval(for: subscription) < Date() {
                        subscription.paymentDate = subscriptionManager.addPaymentInterval(for: subscription)
                        do {
                            try moc.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            nextPaymentDate = formatter.string(from: subscriptionManager.addPaymentInterval(for: subscription))
        }
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .foregroundColor(.gray)
                    .opacity(0.15)
                VStack(alignment: .leading) {
                    HStack {
                        Text(subscription.name).font(.title).bold()
                        Spacer()
                        NavigationLink {
                            EditSubscriptionView(subscriptionData: $subscription)
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(Color(systemTheme))
                                .font(.system(size: 30))
                        }
                        
                    }
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(Color(systemTheme))
                        VStack(alignment: .leading) {
                            Text("Last payment: \(formatter.string(from: subscription.paymentDate))").foregroundColor(.black)
                            Text("Next payment: \(nextPaymentDate)").foregroundColor(.black)
                        }.padding(5)
                    }.frame(height:30, alignment: .leading).padding(.bottom)
                    Text("Family:").bold()
                    ForEach(subscription.familyMemberArray, id: \.id) { member in
                        if member.order != 0 {
                            PersonSubscriptionView(member).padding(.bottom, 5)
                        }
                    }
                    Spacer()
                }.padding()
            }
        }
    }
    
    
    struct PersonSubscriptionView: View {
        
        @State var member : FamilyMemberModel
        let subscriptionManager = SubscriptionManager.shared
        @State var outstandingPaymentAmount : Int
        @State var isPresented : Bool = false
        @AppStorage("appTheme") var systemTheme : String = "theme_yellow"
        @State private var isSharePresented: Bool = false
        @AppStorage("selectedCurrency") var currencyCode : String = "USD"
        
        
        init(_ member: FamilyMemberModel) {
            _member = State(initialValue: member)
            _outstandingPaymentAmount = State(initialValue: subscriptionManager.countMissingPayments(for: member))
        }
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color(systemTheme), lineWidth: 2)
                HStack{
                    VStack(alignment: .leading) {
                        Text(member.name)
                            .bold()
                            .padding(.leading)
                            .padding(.top, 8)
                        Text("Outstanding payments: \(outstandingPaymentAmount)").padding(.leading)
                            .padding(.bottom, 8)
                    }
                    Spacer()
                    Menu {
                        Button(action: {
                            isPresented = true
                        }) {
                            Label("Manage", systemImage: "creditcard.circle")
                        }
                        Button(action: {
                            isSharePresented = true
                        }) {
                            Label("Reminder", systemImage: "message")
                        }
                    } label: {
                        Image(systemName: "info.circle").padding(.trailing)
                    }
                }
                .sheet(isPresented: $isPresented) {
                    NavigationView {
                        PaymentManagerView(familyMember: $member, outstangingPayments: $outstandingPaymentAmount, presentationModel: $isPresented)
                    }
                }
                .sheet(isPresented: $isSharePresented, content: {
                    ActivityViewController(activityItems: ["Hi! You owe me \(member.value) \(currencyCode) for next month of \(member.subscription.name) subscription. \nSent with SubShare", Image("logo_wide")])
                })
                .onAppear {
                    outstandingPaymentAmount = subscriptionManager.countMissingPayments(for: member)
                }
            }
            .frame(height:50)
        }
    }
    
    struct ActivityViewController: UIViewControllerRepresentable {
        
        var activityItems: [Any]
        var applicationActivities: [UIActivity]? = nil
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
            let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
            return controller
        }
        
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
        
    }
}
