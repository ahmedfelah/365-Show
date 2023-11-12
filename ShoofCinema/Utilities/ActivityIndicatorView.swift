//
//  ActivityIndicatorView.swift
//  ShoofCinema
//
//  Created by mac on 4/30/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import Foundation
import SwiftUI

struct ActivityIndicatorView : UIViewRepresentable {
  
    typealias UIViewType = UIActivityIndicatorView
    let style : UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicatorView>) -> ActivityIndicatorView.UIViewType {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: ActivityIndicatorView.UIViewType, context: UIViewRepresentableContext<ActivityIndicatorView>) {
        uiView.startAnimating()
    }
  
}
