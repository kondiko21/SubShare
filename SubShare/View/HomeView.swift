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
    
    var body: some View {
        
        ScrollView {
            VStack {
                ForEach(members, id: \.id) { member in
                    if subscriptionManager.countMissingPayments(for: member) > 0 {
                        Text(member.name)
                    }
                }
            }
        }
        .navigationBarItems(leading: Image("logo_wide").resizable().aspectRatio(contentMode: .fit)
)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
