//
//  CustomCellTableViewCell.swift
//  ShoofCinema
//
//  Created by mac on 3/17/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = Theme.current.backgroundColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
