//
//  SubscriptionModel+CoreDataProperties.swift
//  SubShare
//
//  Created by Konrad on 18/02/2022.
//
//

import Foundation
import CoreData


extension SubscriptionModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubscriptionModel> {
        return NSFetchRequest<SubscriptionModel>(entityName: "SubscriptionModel")
    }

    @NSManaged public var divideCostEqually: Bool
    @NSManaged public var everyMonthPayment: Bool
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var paymentDate: Date
    @NSManaged public var price: Double
    @NSManaged public var familyMember: NSSet
    @NSManaged public var historyEntity: NSSet
    
    public var familyMemberArray: [FamilyMemberModel] {
               let set = familyMember as? Set<FamilyMemberModel> ?? []
               return set.sorted {
                $0.order < $1.order
               }
           }
    public var historyArray: [HistoryEntity] {
               let set = historyEntity as? Set<HistoryEntity> ?? []
               return set.sorted {
                $0.creationDate < $1.creationDate
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

// MARK: Generated accessors for historyEntity
extension SubscriptionModel {

    @objc(addHistoryEntityObject:)
    @NSManaged public func addToHistoryEntity(_ value: HistoryEntity)

    @objc(removeHistoryEntityObject:)
    @NSManaged public func removeFromHistoryEntity(_ value: HistoryEntity)

    @objc(addHistoryEntity:)
    @NSManaged public func addToHistoryEntity(_ values: NSSet)

    @objc(removeHistoryEntity:)
    @NSManaged public func removeFromHistoryEntity(_ values: NSSet)

}

extension SubscriptionModel : Identifiable {

}
