//
//  TextFieledView.swift
//  ShoofCinema
//
//  Created by mac on 7/8/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct TextFieldView: View {
    
    @Binding var text: String
    
    var placeholder = ""
    
    var body: some View {
        TextField("\(placeholder)", text: $text)
            .padding()
            .background(.black)
            .foregroundColor(.white)
            .cornerRadius(10)
            
    }
}

struct TextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldView(text: .constant(""))
            
            
    }
}
