//
//  StoreManager.swift
//  SubShare
//
//  Created by Konrad on 28/02/2022.
//

import Foundation
import StoreKit

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @Published var products = [SKProduct]()
    @Published var transactionState: SKPaymentTransactionState?

    var request: SKProductsRequest!

    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        if !response.products.isEmpty {
            for fetchedProduct in response.products {
                DispatchQueue.main.async {
                    self.products.append(fetchedProduct)
                }
            }
        }
        for invalidIdentifier in response.invalidProductIdentifiers {
            print("Invalid identifiers found: \(invalidIdentifier)")
        }
        
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Request did fail: \(error)")
    }
    
    func getProducts(productIDs: [String]) {
        print("Start requesting products ...")
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
                switch transaction.transactionState {
                case .purchasing:
                    transactionState = .purchasing
                case .purchased:
                    UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier)
                    queue.finishTransaction(transaction)
                    transactionState = .purchased
                case .restored:
                    UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier)
                    queue.finishTransaction(transaction)
                    transactionState = .restored
                case .failed, .deferred:
                    print("Payment Queue Error: \(String(describing: transaction.error))")
                        queue.finishTransaction(transaction)
                        transactionState = .failed
                        default:
                        queue.finishTransaction(transaction)
                }
            }
    }
    
    func purchaseProduct(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            print("User can't make payment.")
        }
    }
    
    func restoreProducts() {
        print("Restoring products ...")
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}
