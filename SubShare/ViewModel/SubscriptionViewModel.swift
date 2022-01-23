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
    let notificationManager = NotificationManager.shared

    @Published var name : String
    @Published var everyMonthPayment : Bool
    @Published var price : Double
    @Published var divideCostEqually : Bool
    @Published var paymentDate : Date
    @Published var familyMembers : [FamilyMemberModel]
    @Published var memberNames : [String] = []
    @Published var memberPrices : [Double] = []
    @Published var familyCount : Int
    @Published var id : UUID
    var subscriptionModel : SubscriptionModel?
    
    
    init(subscription: SubscriptionModel) {
        
        self.name = subscription.name
        self.everyMonthPayment = subscription.everyMonthPayment
        self.price = subscription.price
        self.divideCostEqually = subscription.divideCostEqually
        self.paymentDate = subscription.paymentDate
        self.familyMembers = subscription.familyMemberArray.sorted(by: { $0.order < $1.order })
        self.subscriptionModel = subscription
        self.familyCount = subscription.familyMemberArray.count-1
        self.id = UUID()

        
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
        self.familyCount = 0
        self.id = UUID()
    }
    
    func save() {
        let model = SubscriptionModel(context: moc)
            model.id = id
            model.name = name
            model.price = price
            model.everyMonthPayment = everyMonthPayment
            model.divideCostEqually = divideCostEqually
            model.paymentDate = paymentDate
        for id in 0...familyCount {
            let object = FamilyMemberModel(context: moc)
            object.name = memberNames[id]
            object.value = memberPrices[id]
            object.order = Int16(id)
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
        notificationManager.addNotificationFor(subscription: model)
    }
    
    func saveEdit() {
        let model = subscriptionModel!
            model.name = name
            model.price = price
            model.everyMonthPayment = everyMonthPayment
            model.divideCostEqually = divideCostEqually
            model.paymentDate = paymentDate
            for member in model.familyMemberArray {
                moc.delete(member)
            }
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
        if memberNames.count <= 1 {
            warningList.append(.family)
        }
        if paymentDate > Date() {
            warningList.append(.date)
        }
        
        return warningList
    }
    
    enum DataValidationMessages : String {
        case name = "You need to set subscription name!"
        case price = "Your price must be diffrent than 0!"
        case family = "You need to add family members!"
        case date = "You can't subscription date for future!"
    }
}
