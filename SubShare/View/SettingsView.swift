//
//  SetttingsView.swift
//  SubShare
//
//  Created by Konrad on 23/12/2021.
//

import SwiftUI

struct SettingsView: View {
    
    @FetchRequest(
        entity: SubscriptionModel.entity(),
        sortDescriptors: []
    ) var subscriptionData: FetchedResults<SubscriptionModel>
    @FetchRequest(
        entity: FamilyMemberModel.entity(),
        sortDescriptors: []
    ) var members: FetchedResults<FamilyMemberModel>
    @Environment(\.managedObjectContext) var moc
    
    @AppStorage("selectedCurrency") var selectedCurrency : String = "$"
    let currencySymbols = ["AFA", "ALL", "DZD", "AOA", "ARS", "AMD", "AWG", "AUD", "AZN", "BSD", "BHD", "BDT", "BBD", "BYR", "BEF", "BZD", "BMD", "BTN", "BTC", "BOB", "BAM", "BWP", "BRL", "GBP", "BND", "BGN", "BIF", "KHR", "CAD", "CVE", "KYD", "XOF", "XAF", "XPF", "CLP", "CNY", "COP", "KMF", "CDF", "CRC", "HRK", "CUC", "CZK", "DKK", "DJF", "DOP", "XCD", "EGP", "ERN", "EEK", "ETB", "EUR", "FKP", "FJD", "GMD", "GEL", "DEM", "GHS", "GIP", "GRD", "GTQ", "GNF", "GYD", "HTG", "HNL", "HKD", "HUF", "ISK", "INR", "IDR", "IRR", "IQD", "ILS", "ITL", "JMD", "JPY", "JOD", "KZT", "KES", "KWD", "KGS", "LAK", "LVL", "LBP", "LSL", "LRD", "LYD", "LTL", "MOP", "MKD", "MGA", "MWK", "MYR", "MVR", "MRO", "MUR", "MXN", "MDL", "MNT", "MAD", "MZM", "MMK", "NAD", "NPR", "ANG", "TWD", "NZD", "NIO", "NGN", "KPW", "NOK", "OMR", "PKR", "PAB", "PGK", "PYG", "PEN", "PHP", "PLN", "QAR", "RON", "RUB", "RWF", "SVC", "WST", "SAR", "RSD", "SCR", "SLL", "SGD", "SKK", "SBD", "SOS", "ZAR", "KRW", "XDR", "LKR", "SHP", "SDG", "SRD", "SZL", "SEK", "CHF", "SYP", "STD", "TJS", "TZS", "THB", "TOP", "TTD", "TND", "TRY", "TMT", "UGX", "UAH", "AED", "UYU", "USD", "UZS", "VUV", "VEF", "VND", "YER", "ZMK"]
    
    
    
    var body: some View {
        
            VStack {
                Form {
                Picker(selection: $selectedCurrency,label: Text("Default currency")) {
                    ForEach(currencySymbols, id:\.self) { symbol in
                        HStack {
                            Text(symbol).tag(getSymbol(forCurrencyCode:symbol))
                            Spacer()
                            Text(getSymbol(forCurrencyCode:symbol) ?? "").bold()
                        }
                    }
                }
                    Section {
                        Button {
                            DispatchQueue.main.async {
                        for object in subscriptionData {
                            moc.delete(object)
                            NotificationManager.shared.removeNotification(id: "\(object.id)")
                        }
                        for object in members {
                            moc.delete(object)
                        }
                        let center = UNUserNotificationCenter.current()
                        center.getPendingNotificationRequests(completionHandler: { requests in
                        for request in requests {
                            NotificationManager.shared.removeNotification(id: request.identifier)
                        }
                                    })
                        do {
                            try moc.save()
                        } catch {
                            print(error)
                        }
                                
                            }
                    } label: {
                        Text("Reset app").foregroundColor(.red)
                }
                    }
            }
        }
    }
}

struct SetttingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

func getSymbol(forCurrencyCode code: String) -> String? {
    let locale = NSLocale(localeIdentifier: code)
    if locale.displayName(forKey: .currencySymbol, value: code) == code {
        let newlocale = NSLocale(localeIdentifier: code.dropLast() + "_en")
        return newlocale.displayName(forKey: .currencySymbol, value: code)
    }
    return locale.displayName(forKey: .currencySymbol, value: code)
}
