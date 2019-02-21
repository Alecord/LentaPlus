//
//  NewsCellController.swift
//  LentaPlus
//
//  Created by Alex Cord on 2/7/19.
//  Copyright © 2019 Alex Cord. All rights reserved.
//

import UIKit

class NewsCellController: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var rubricLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descrLabel: UILabel!
    @IBOutlet weak var favoriteIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        //let bgColorView = UIView()
        //bgColorView.backgroundColor =  .red
        //self.selectedBackgroundView = bgColorView
        // Configure the view for the selected state
    }

}
