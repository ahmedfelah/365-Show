//
//  SecureTextFieldView.swift
//  ShoofCinema
//
//  Created by mac on 7/8/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct SecureTextFieldView: View {
    
    @Binding var text: String
    @Binding var isSecured: Bool
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isSecured {
                    SecureField("Password", text: $text)
                } else {
                    TextField("Password", text: $text)
                }
            }.padding(.trailing, 32)
            
            Button(action: {
                isSecured.toggle()
            }) {
                Text(isSecured ? "Hide" : "Show")
                    .foregroundColor(.gray)
            }
        }.padding()
            .background(.black)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

struct SecureTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        SecureTextFieldView(text: .constant(""), isSecured: .constant(true))
    }
}
