//
//  FamilyMemberModel+CoreDataProperties.swift
//  SubShare
//
//  Created by Konrad on 24/12/2021.
//
//

import Foundation
import CoreData


extension FamilyMemberModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FamilyMemberModel> {
        return NSFetchRequest<FamilyMemberModel>(entityName: "FamilyMemberModel")
    }

    @NSManaged public var name: String
    @NSManaged public var value: Double
    @NSManaged public var lastPaymentDate: Date
    @NSManaged public var id: UUID
    @NSManaged public var order: Int16
    @NSManaged public var subscription: SubscriptionModel

}

extension FamilyMemberModel : Identifiable {

}
