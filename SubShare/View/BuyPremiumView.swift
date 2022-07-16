//
//  BuyPremiumView.swift
//  SubShare
//
//  Created by Konrad on 02/03/2022.
//

import SwiftUI

struct BuyPremiumView: View {
    
    @AppStorage("appTheme") var systemTheme : String = "theme_yellow"
    @State var cost : String = ""
    @EnvironmentObject var storeManager : StoreManager
    @Binding var presentationMode : Bool
    @AppStorage("com.kondiko.subshare.pro") var premiumUser : Bool = false

    var body: some View {
        VStack {
            Image("pro_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(20)
                .padding(.leading, 90)
                .padding(.trailing, 90)
                .padding(.top, 90)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("SubShare Pro").font(.largeTitle).bold().foregroundColor(Color("theme_yellow"))
                .padding(.top, 40)
            Text("SubShare Pro offers you non limited amount of subscription added. \n Lifetime.").font(.title2).bold().padding().multilineTextAlignment(.center)
            Spacer()
            Button {
                if let product = storeManager.products.first {
                    storeManager.purchaseProduct(product: product)
                } else {
                    fatalError("Couldn't find product.")
                }
                if premiumUser {
                    presentationMode = false
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .foregroundColor(Color(systemTheme))
                    Text("Buy for \(cost)").bold().padding().foregroundColor(Color.black)
                }
                .frame(height: 50)
                .padding()
                .padding(.leading, 30)
                .padding(.trailing, 30)
            }
            .navigationBarItems(trailing: Button(action: {
                presentationMode = false
            }, label: {
                Text("Back")
            }))
//            Text(cost).font(.title).bold().foregroundColor(Color("theme_yellow"))
        }
        .onAppear {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = storeManager.products.first!.priceLocale
            cost = formatter.string(from: storeManager.products.first!.price)!
        }
    }
}
