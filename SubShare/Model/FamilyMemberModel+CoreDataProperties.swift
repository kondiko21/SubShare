//
//  FamilyMemberModel+CoreDataProperties.swift
//  SubShare
//
//  Created by Konrad on 18/02/2022.
//
//

import Foundation
import CoreData


extension FamilyMemberModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FamilyMemberModel> {
        return NSFetchRequest<FamilyMemberModel>(entityName: "FamilyMemberModel")
    }

    @NSManaged public var id: UUID
    @NSManaged public var lastPaymentDate: Date
    @NSManaged public var name: String
    @NSManaged public var order: Int16
    @NSManaged public var value: Double
    @NSManaged public var subscription: SubscriptionModel
    @NSManaged public var historyEntity: NSSet

}

// MARK: Generated accessors for historyEntity
extension FamilyMemberModel {

    @objc(addHistoryEntityObject:)
    @NSManaged public func addToHistoryEntity(_ value: HistoryEntity)

    @objc(removeHistoryEntityObject:)
    @NSManaged public func removeFromHistoryEntity(_ value: HistoryEntity)

    @objc(addHistoryEntity:)
    @NSManaged public func addToHistoryEntity(_ values: NSSet)

    @objc(removeHistoryEntity:)
    @NSManaged public func removeFromHistoryEntity(_ values: NSSet)

}

extension FamilyMemberModel : Identifiable {

}
