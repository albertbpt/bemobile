//
//  ProductCell.swift
//  Bemobile
//
//  Created by Albert on 17/1/21.
//

import UIKit

class SimpleCell: UITableViewCell {
    
    // MARK: - OUTLETS
    @IBOutlet weak var label: UILabel!
    
    // MARK: - FUNCTIONS
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        label.text = nil
    }
    
}
