//
//  Extensions.swift
//  Bemobile
//
//  Created by Albert on 18/1/21.
//

import Foundation

extension String {
    func fromFile(_ tableName: String) -> String {
        return NSLocalizedString(self, tableName: tableName, comment: "")
    }
}
