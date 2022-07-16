//
//  HistoryView.swift
//  SubShare
//
//  Created by Konrad on 03/04/2022.
//

import SwiftUI

struct HistoryView: View {
    @FetchRequest(
        entity: HistoryEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \HistoryEntity.creationDate, ascending: false)]
    ) var historyObjects: FetchedResults<HistoryEntity>
    @Environment(\.managedObjectContext) var moc
    let subscriptionManager = SubscriptionManager.shared
    @AppStorage("appTheme") var systemTheme : String = "theme_yellow"
    
    var body: some View {
        ScrollView {
            ForEach(historyObjects, id: \.self) { (object: HistoryEntity) in
                HistoryElementView(element: object)
            }.padding()
        }
    }
}

struct HistoryElementView: View {
    
    @State var element : HistoryEntity
    var formatter = DateFormatter()
    @AppStorage("appTheme") var systemTheme : String = "theme_yellow"
    
    init(element: HistoryEntity) {
        _element = State(initialValue: element)
        formatter.dateFormat = "d MMM YYYY"
    }
    
    var body: some View {
        
        ZStack{
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(Color(systemTheme).opacity(2))
            VStack(alignment: .trailing) {
                HStack(alignment: .top) {
                    Text(element.subscription.name).bold().font(Font.title).foregroundColor(.black)
                    Spacer()
                    Text(formatter.string(from: element.creationDate)).foregroundColor(.black)
                }
                if element.operation == "new_payment" {
                                        Text("Added new payment \(element.member.name)").foregroundColor(.black)
                                    }
            }.padding(5)
        }
    }
}
