//
//  HistoryEntity+CoreDataProperties.swift
//  
//
//  Created by Konrad on 03/04/2022.
//
//

import Foundation
import CoreData


extension HistoryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistoryEntity> {
        return NSFetchRequest<HistoryEntity>(entityName: "HistoryEntity")
    }

    @NSManaged public var creationDate: Date
    @NSManaged public var id: UUID
    @NSManaged public var operation: String
    @NSManaged public var member: FamilyMemberModel
    @NSManaged public var subscription: SubscriptionModel

}
