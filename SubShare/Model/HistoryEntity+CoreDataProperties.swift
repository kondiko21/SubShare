//
//  HistoryEntity+CoreDataProperties.swift
//  SubShare
//
//  Created by Konrad on 18/02/2022.
//
//

import Foundation
import CoreData


extension HistoryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistoryEntity> {
        return NSFetchRequest<HistoryEntity>(entityName: "HistoryEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var creationDate: Date
    @NSManaged public var operation: String
    @NSManaged public var subscription: SubscriptionModel
    @NSManaged public var member: FamilyMemberModel
    

}

extension HistoryEntity : Identifiable {

}
