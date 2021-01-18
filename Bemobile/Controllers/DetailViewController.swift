//
//  DetailViewController.swift
//  Bemobile
//
//  Created by Albert on 17/1/21.
//

import UIKit

class DetailViewController: UIViewController {
    
    // MARK: - PROPERTIES
    let transactions: [Transaction]
    let rates: [Rate]
    
    // MARK: - OUTLETS
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var transactionsTableView: UITableView! {
        didSet {
            transactionsTableView.delegate = self
            transactionsTableView.dataSource = self
            transactionsTableView.allowsSelection = false
            transactionsTableView.separatorStyle = .none
        }
    }
    
    @IBOutlet weak var separatorView: UIView! {
        didSet {
            separatorView.backgroundColor = .darkGray
        }
    }
    
    @IBOutlet weak var totalLabel: UILabel! {
        didSet {
            totalLabel.text = "total".fromFile("Detail")
        }
    }
    
    @IBOutlet weak var totalValueLabel: UILabel! {
        didSet {
            totalValueLabel.text = nil
        }
    }
    
    // MARK: - FUNCTIONS
    init(rates: [Rate], transactions: [Transaction]) {
        self.transactions = transactions
        self.rates = rates
        super.init(nibName: "DetailViewController", bundle: Bundle.main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell
        let nib = UINib(nibName: "SimpleCell", bundle: Bundle.main)
        transactionsTableView.register(nib, forCellReuseIdentifier: "SimpleCell")
        
        titleLabel.text = String(format: "product".fromFile("Detail"), transactions.first?.sku ?? "")
        
        totalValueLabel.text = String(format: "%.2f €" , calculateTotalInEuros(rates: rates, transactions: transactions))
    }
    
    private func calculateTotalInEuros(rates: [Rate], transactions: [Transaction]) -> Double {
        var total = 0.0
        for transaction in transactions {
            switch transaction.currency {
            case "EUR":
                total += transaction.amount
            case "USD", "CAD", "AUD":
                if let rate = rates.filter({ (r) -> Bool in
                    r.from == transaction.currency && r.to == "EUR"
                }).first {
                    total += transaction.amount * rate.rate                    
                }
                
            default:
                ()
            }
        }
        return total
    }
    
}

// MARK: - EXTENSIONS
extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleCell", for: indexPath) as! SimpleCell
        cell.label.text = "\(transactions[indexPath.row].amount) \(transactions[indexPath.row].currency)"
        return cell
    }
    
}

extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
