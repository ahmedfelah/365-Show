//
//  NavView.swift
//  365Show
//
//  Created by ممم on 17/02/2024.
//  Copyright © 2024 AppChief. All rights reserved.
//

import SwiftUI

struct NavView<Content: View>: View {
    
    var content: Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
            self.content = content()
    }
    
    var body: some View {
        if #available(iOS 16, *) {
            NavigationStack {
               content
            }
        }
        
        else {
            NavigationView {
                content
            }
        }
    }
}
