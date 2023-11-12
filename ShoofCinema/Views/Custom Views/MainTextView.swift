//
//  MainTextView.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 3/14/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import UIKit


class CommentTextView: UITextView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.textColor = Theme.current.tintColor
        self.tintColor = Theme.current.tintColor
        self.isScrollEnabled = true
    }
    

    
}
