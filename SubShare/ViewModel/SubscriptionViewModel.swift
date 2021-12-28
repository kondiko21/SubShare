//
//  SubscriptionViewModel.swift
//  SubShare
//
//  Created by Konrad on 24/12/2021.
//

import Foundation
import CoreData

class SubscriptionViewModel : ObservableObject {
    
    var moc: NSManagedObjectContext = PersistenceController.shared.container.viewContext

    @Published var name : String
    @Published var everyMonthPayment : Bool
    @Published var price : Double
    @Published var divideCostEqually : Bool
    @Published var paymentDate : Date
    @Published var familyMembers : [FamilyMemberModel]
    @Published var memberNames : [String] = []
    @Published var memberPrices : [Double] = []
    var subscriptionModel : SubscriptionModel?
    
    
    init(subscription: SubscriptionModel) {
        
        self.name = subscription.name
        self.everyMonthPayment = subscription.everyMonthPayment
        self.price = subscription.price
        self.divideCostEqually = subscription.divideCostEqually
        self.paymentDate = subscription.paymentDate
        self.familyMembers = subscription.familyMemberArray.sorted(by: { $0.order < $1.order })
        self.subscriptionModel = subscription
        
        for member in familyMembers {
            memberNames.append(member.name)
            memberPrices.append(member.value)
        }
    }
    
    init() {
        self.name = ""
        self.everyMonthPayment = true
        self.price = 0.0
        self.divideCostEqually = true
        self.paymentDate = Date()
        self.familyMembers = []
        self.memberNames = ["Me"]
        self.memberPrices = [0]
    }
    
    func save() {
        let model = SubscriptionModel(context: moc)
            model.id = UUID()
            model.name = name
            model.price = price
            model.everyMonthPayment = everyMonthPayment
            model.divideCostEqually = divideCostEqually
            model.paymentDate = paymentDate
        for member in memberNames {
            let id = memberNames.firstIndex(of: member)
            let object = FamilyMemberModel(context: moc)
            object.name = member
            object.value = memberPrices[id!]
            object.order = Int16(id!)
            object.lastPaymentDate = paymentDate
            object.id = UUID()
            object.subscription = model
        }
        do {
            try moc.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func saveEdit() {
        let model = subscriptionModel!
            model.name = name
            model.price = price
            model.everyMonthPayment = everyMonthPayment
            model.divideCostEqually = divideCostEqually
            model.paymentDate = paymentDate
        model.removeFromFamilyMember(model.familyMember)
        for member in memberNames {
            let id = memberNames.firstIndex(of: member)
            let object = FamilyMemberModel(context: moc)
            object.name = member
            object.value = memberPrices[id!]
            object.order = Int16(id!)
            object.lastPaymentDate = paymentDate
            object.id = UUID()
            object.subscription = model
        }
        do {
            try moc.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func generateWarning() -> [DataValidationMessages] {
        
        var warningList : [DataValidationMessages] = []
        
        if name == "" {
            warningList.append(.name)
        }
        if price == 0 {
            warningList.append(.price)
        }
        if memberNames.count <= 0 {
            warningList.append(.family)
        }
        
        return warningList
    }
    
    enum DataValidationMessages : String {
        case name = "You need to set subscription name!"
        case price = "Your price must be diffrent than 0!"
        case family = "You need to add family members!"
    }
}
