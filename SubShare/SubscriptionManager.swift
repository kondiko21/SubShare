//
//  SubscriptionManager.swift
//  SubShare
//
//  Created by Konrad on 28/12/2021.
//

import Foundation

class SubscriptionManager {
    
    static var shared = SubscriptionManager()
    
    func addMonth(to currentDate: Date) -> Date {
        let nextDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)
        return nextDate!
    }
    
    func addThirtyDays(to currentDate: Date) -> Date {
        let nextDate = Calendar.current.date(byAdding: .day, value: 30, to: currentDate)
        return nextDate!
    }
    
    func addOneDay(to currentDate: Date) -> Date {
        let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)
        return nextDate!
    }
    
    func countMissingPayments(for member: FamilyMemberModel) -> Int {
       
        let list = generatePaymentList(for: member)
        return list.count
    }
    
    func generatePaymentList(for member: FamilyMemberModel) -> [Date] {
        print(member.subscription.name)
        let everyMonthPayment = member.subscription.everyMonthPayment
        let paymentDate = member.subscription.paymentDate
        var lastPaymentDate = member.lastPaymentDate
        var list : [Date] = []
        
        if addPaymentInterval(for: member) < paymentDate {
            list.append(lastPaymentDate)
        }

        if everyMonthPayment {
            while addMonth(to: lastPaymentDate) <= paymentDate {
                lastPaymentDate = addMonth(to: lastPaymentDate)
                list.append(lastPaymentDate)
            }
        } else {
            while addThirtyDays(to: lastPaymentDate) <= paymentDate {
                lastPaymentDate = addThirtyDays(to: lastPaymentDate)
                list.append(lastPaymentDate)
            }
        }
        print("List \(member.name),\n paymentDate: \(member.lastPaymentDate)")
        print(list.sorted(by: {$0 < $1}))
        return list.sorted(by: {$0 < $1})
    }
    
    func addPaymentInterval(for member: FamilyMemberModel) -> Date {
        let paymentDate = member.lastPaymentDate
        let everyMonthPayment = member.subscription.everyMonthPayment
        if everyMonthPayment {
            return addMonth(to: paymentDate)
        } else {
            return addThirtyDays(to: paymentDate)
        }
    }
    
    func addPaymentInterval(for subscription: SubscriptionModel) -> Date {
        let paymentDate = subscription.paymentDate
        let everyMonthPayment = subscription.everyMonthPayment
        if everyMonthPayment {
            return addMonth(to: paymentDate)
        } else {
            return addThirtyDays(to: paymentDate)
        }
    }
}
