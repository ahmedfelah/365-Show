//
//  AutocompleteCell.swift
//  ShoofCinema
//
//  Created by mac on 3/1/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import UIKit

class AutocompleteCell: UITableViewCell {
    
    

    @IBOutlet weak var title: MainLabel!
    
    var autocomplete : ShoofAPI.Autocomplete?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func configure (autocomplete: ShoofAPI.Autocomplete) {
        self.autocomplete = autocomplete
        self.title.text = autocomplete.title
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        title.textColor = .white
    }

}
