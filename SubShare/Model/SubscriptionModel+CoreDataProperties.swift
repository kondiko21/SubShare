//
//  SubscriptionModel+CoreDataProperties.swift
//  SubShare
//
//  Created by Konrad on 25/12/2021.
//
//

import Foundation
import CoreData


extension SubscriptionModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubscriptionModel> {
        return NSFetchRequest<SubscriptionModel>(entityName: "SubscriptionModel")
    }

    @NSManaged public var name: String
    @NSManaged public var paymentDate: Date
    @NSManaged public var everyMonthPayment: Bool
    @NSManaged public var id: UUID
    @NSManaged public var price: Double
    @NSManaged public var divideCostEqually: Bool
    @NSManaged public var familyMember: NSSet
    
    public var familyMemberArray: [FamilyMemberModel] {
               let set = familyMember as? Set<FamilyMemberModel> ?? []
               return set.sorted {
                $0.order < $1.order
               }
           }

}

// MARK: Generated accessors for familyMember
extension SubscriptionModel {

    @objc(addFamilyMemberObject:)
    @NSManaged public func addToFamilyMember(_ value: FamilyMemberModel)

    @objc(removeFamilyMemberObject:)
    @NSManaged public func removeFromFamilyMember(_ value: FamilyMemberModel)

    @objc(addFamilyMember:)
    @NSManaged public func addToFamilyMember(_ values: NSSet)

    @objc(removeFamilyMember:)
    @NSManaged public func removeFromFamilyMember(_ values: NSSet)

}

extension SubscriptionModel : Identifiable {

}
