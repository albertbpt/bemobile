//
//  MainViewController.swift
//  Bemobile
//
//  Created by Albert on 14/1/21.
//

import UIKit
import Lottie

class MainViewController: UIViewController {
    
    // MARK: - PROPERTIES
    private let nm = NetworkManager()
    private var animationView: AnimationView?
    
    private var transactions = [Transaction]()
    private var uncompleteRates = [Rate]()
    private var completeRates = [Rate]()
    private var skuCodes = [String]()
    
    // MARK: - OUTLETS
    @IBOutlet weak var productTableView: UITableView! {
        didSet {
            productTableView.delegate = self
            productTableView.dataSource = self
            productTableView.separatorStyle = .none
        }
    }
    
    @IBOutlet weak var loadingView: UIView!
    
    
    // MARK: - FUNCTIONS
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell
        let nib = UINib(nibName: "SimpleCell", bundle: Bundle.main)
        productTableView.register(nib, forCellReuseIdentifier: "SimpleCell")
        
        configureLoadingAnimation()
        
        getRates()
    }

    private func configureLoadingAnimation() {
        animationView = .init(name: "loading")
        if let animationView = animationView {
            showLoadingView(false)
            animationView.frame = loadingView.bounds
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .loop
            loadingView.addSubview(animationView)
        }
    }
    
    private func showLoadingView(_ show: Bool) {
        DispatchQueue.main.async {
            self.loadingView.isHidden = !show
            if show {
                self.animationView?.play()
            } else {
                self.animationView?.stop()
            }
        }
    }
    
    private func getTransactions() {
        
        nm.getTransactions { (transactions, error) in
            if let transactions = transactions, error == nil {
                self.transactions = transactions
                self.skuCodes = Array(Set(transactions.map{ $0.sku }))
                DispatchQueue.main.async {
                    self.productTableView.reloadData()
                }
            }
            self.showLoadingView(false)
        }
    }
    
    private func getRates() {
        showLoadingView(true)
        
        nm.getRates { (rates, error) in
            if let rates = rates, error == nil {
                self.uncompleteRates = rates
                
                
                // get missing conversions to euro
                self.completeRates = self.getCompleteRates()
                
                self.getTransactions()

            }
        }
    }
    
    
    func getCompleteRates() -> [Rate] {
        var notEuroCurrencies = Array(Set(uncompleteRates.map{ $0.from }))
        notEuroCurrencies.removeAll{$0 == "EUR"}
       
        // The rates that DON'T have conversion to euro
        var missingRates: [String] = []
        for cur in notEuroCurrencies {
            if !uncompleteRates.contains(where: { (r) -> Bool in
                r.from == cur && r.to == "EUR"
            }) {
                missingRates.append(cur)
            }
        }
        
        // The rates that have conversion to euro
        let canConvertToEuro = notEuroCurrencies.filter { (cur) -> Bool in
            !missingRates.contains { (mr) -> Bool in
                mr == cur
            }
        }
        var allCanConvertToEuro = false
        var appendRates: [Rate] = []
        while !allCanConvertToEuro {
            // for every missing rate we loop if it can convert to another currency which already can convert to EUR
            // when found a coincidence, the new rate will be the product of the [missing->intermediate] * [intermediate->eur]
            for mr in missingRates {
                for cc in canConvertToEuro {
                    for r in uncompleteRates {
                        if r.from == cc && r.to == "EUR" {
                            for s in uncompleteRates {
                                if cc == s.to && mr == s.from {
                                    appendRates.append(Rate(from: mr, to: "EUR", rate: r.rate * s.rate))
                                }
                            }
                        }
                    }
                }
            }
            allCanConvertToEuro = appendRates.count == missingRates.count

        }
        return uncompleteRates + appendRates
    }

}


// MARK: - EXTENSIONS
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return skuCodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sku = skuCodes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleCell", for: indexPath) as! SimpleCell
        
        cell.prepareForReuse()
        
        cell.label.text = sku
        
        return cell
    }
    
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sku = skuCodes[indexPath.row]
        
        // Get all transactions for the specific sku
        let filteredTransactions = Array(Set(self.transactions.filter{ $0.sku == sku }))
        let detailVC = DetailViewController(rates: completeRates, transactions: filteredTransactions)
        
        showDetailViewController(detailVC, sender: self)
    }
}
