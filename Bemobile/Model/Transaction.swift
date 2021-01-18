//
//  Transaction.swift
//  Bemobile
//
//  Created by Albert on 17/1/21.
//

import Foundation

struct Transaction: Hashable {
    let sku: String
    let amount: Double
    let currency: String
    
    init(sku: String, amount: Double, currency: String) {
        self.sku = sku
        self.amount = amount
        self.currency = currency
    }
}
