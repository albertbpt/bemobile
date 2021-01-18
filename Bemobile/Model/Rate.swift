//
//  Rate.swift
//  Bemobile
//
//  Created by Albert on 17/1/21.
//

import Foundation


struct Rate {
    let from: String
    let to: String
    let rate: Double
    
    init(from: String, to: String, rate: Double) {
        self.from = from
        self.to = to
        self.rate = rate
    }
}
