//
//  AppDelegate.swift
//  SubShare
//
//  Created by Konrad on 26/12/2021.
//

import Foundation
import UIKit
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var moc: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    var subscriptionManager = SubscriptionManager.shared
    var notificationManager = NotificationManager.shared
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        print("NOT")
        let center = UNUserNotificationCenter.current()
                center.getPendingNotificationRequests(completionHandler: { requests in
                    for request in requests {
                        print("NOTIFICATION: \(String(describing: request.trigger)) \(request.content.body)")
                    }
                })
        return true
    }
    
    private func userNotificationCenter(_ center: UNUserNotificationCenter, didRecive notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification received with identifier \(notification.request.identifier)")
//        var date = notification.request.content.userInfo["subscription"] as! Date
//        print("Before date \(date)")
//        date = subscriptionManager.addOneDay(to: date)
//        print("After date \(date)")
//        do {
//            try moc.save()
//        } catch {
//            print(error)
//        }

//        notificationManager.nextNotification(for: notification, date: date)

        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification
        print("Notification received with identifier \(notification.request.identifier)")
        var date = notification.request.content.userInfo["subscription"] as! Date
        print("Before date \(date)")
        date = subscriptionManager.addOneDay(to: date)
        print("After date \(date)")
        do {
            try moc.save()
        } catch {
            print(error)
        }
        
        notificationManager.nextNotification(for: notification, date: date)
        
    }
    
}
