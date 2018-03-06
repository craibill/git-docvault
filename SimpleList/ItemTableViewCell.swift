//
//  ItemTableViewCell.swift
//  SimpleList
//
//  Created by Craig Billings on 2/22/18.
//  Copyright © 2018 Craig Billings. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    
    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
