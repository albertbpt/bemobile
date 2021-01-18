//
//  NetworkManager.swift
//  Bemobile
//
//  Created by Albert on 17/1/21.
//

import Foundation
import SwiftyJSON


class NetworkManager {
    
    
    func getRates(_ completionHandler: @escaping ([Rate]?, Error?) -> Void) {
        
        let urlSession = URLSession(configuration: .default)
        
        guard let url = URL(string: Api.url.base + Api.url.rates)  else { return }
        
        var request = URLRequest.init(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completionHandler(nil, error)
                return
            }
            
            do {
                var rates: [Rate] = []
                let ratesJSON = try JSON(data: data).arrayValue
                
                for rate in ratesJSON {
                    rates.append(Rate(from: rate["from"].stringValue, to: rate["to"].stringValue, rate: rate["rate"].doubleValue))
                }
                
                completionHandler(rates, nil)
                
            } catch let error {
                completionHandler(nil, error)
            }
            
        }.resume()
    }
    
    
    func getTransactions(_ completionHandler: @escaping ([Transaction]?, Error?) -> Void) {
        
        let urlSession = URLSession(configuration: .default)
        
        guard let url = URL(string: Api.url.base + Api.url.transactions)  else { return }
        
        var request = URLRequest.init(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completionHandler(nil, error)
                return
            }
            
            do {
                var transactions: [Transaction] = []
                let transactionsJSON = try JSON(data: data).arrayValue
                
                for transaction in transactionsJSON {
                    transactions.append(Transaction(sku: transaction["sku"].stringValue, amount: transaction["amount"].doubleValue, currency: transaction["currency"].stringValue))
                }
                
                completionHandler(transactions, nil)
                
            } catch let error {
                completionHandler(nil, error)
            }
            
        }.resume()
    }
    
}
