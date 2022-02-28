//
//  NotficationManager.swift
//  SubShare
//
//  Created by Konrad on 30/12/2021.
//

import Foundation
import NotificationCenter
import CoreData

final class NotificationManager : NotificationCenter {
    
    static var shared = NotificationManager()
    let subscriptionManager = SubscriptionManager()
    var moc: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    
    private override init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted == true && error == nil {
                print("Notifications permitted")
            } else {
                print("Notifications not permitted")
            }
        }
    }
    
    func addNotificationFor(subscription: SubscriptionModel) {
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.title = "New subscription payment"
        content.body = "You have new payment for \(subscription.name) subscription. Tap to nitify your family about new payment!"
        content.userInfo = ["subscription" : subscriptionManager.addOneDay(to: subscription.paymentDate)]
        
        let notificationDate = subscriptionManager.addOneDay(to: subscription.paymentDate)
        var dateComponent = DateComponents()
        var request : UNNotificationRequest?
        
        print(subscription.everyMonthPayment)
        if subscription.everyMonthPayment {
            dateComponent.hour = Calendar.current.component(.hour, from: notificationDate )
            dateComponent.minute = Calendar.current.component(.minute, from: notificationDate )
            
            dateComponent.day = Calendar.current.component(.day, from: notificationDate )
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
            request  = UNNotificationRequest(identifier: "\(subscription.id)", content: content, trigger: trigger)
        }

        if subscription.everyMonthPayment == false {
            
            dateComponent.hour = 10
            dateComponent.minute = 0
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (24*60*60), repeats: true)
            request  = UNNotificationRequest(identifier: "\(subscription.id)", content: content, trigger: trigger)
        }
        UNUserNotificationCenter.current().add(request!, withCompletionHandler: nil)
    }
    
    func nextNotification(for object: UNNotification, date : Date) {
        let previousContent = object.request.content
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.title = previousContent.title
        content.body = previousContent.body
        content.userInfo = ["subscription" : date]
        
        
        let notificationDate = date
        var dateComponent = DateComponents()
        
        dateComponent.hour = Calendar.current.component(.hour, from: notificationDate )
        dateComponent.minute = Calendar.current.component(.minute, from: notificationDate )
        
        dateComponent.day = Calendar.current.component(.day, from: notificationDate )
        dateComponent.month = Calendar.current.component(.month, from: notificationDate )
        dateComponent.year = Calendar.current.component(.year, from: notificationDate )

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        let request  = UNNotificationRequest(identifier: "\(object.request.identifier)", content: content, trigger: trigger)
        print("Next notification request \(request)")
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func removeNotification(id identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
}
