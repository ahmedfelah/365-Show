//
//  MessageTableViewCell.swift
//  SuperCell
//
//  Created by Husam Aamer on 6/17/19.
//  Copyright © 2019 AppChief. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = Theme.current.backgroundColor
        dateLabel.textColor = Theme.current.captionsColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
