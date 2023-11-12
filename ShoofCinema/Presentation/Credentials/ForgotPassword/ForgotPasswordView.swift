//
//  ForgotPassword.swift
//  ShoofCinema
//
//  Created by mac on 7/8/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            TextFieldView(text: .constant(""), placeholder: "E-mail address")
                .padding(.top)
            
            Text("Enter your email address above and we'll send you a link to reset your password.")
                .font(.caption)
                .padding(.horizontal, 5)
                .padding(.bottom)
            
            Button(action: {}) {
                Text("Reset Password")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                
            }
            .background(Color("red"))
            .cornerRadius(10)
            .padding(.top)
            .foregroundColor(.white)
            
            
                
            
            
            Spacer()
            
            
            
        }.padding()
            .frame(maxHeight: .infinity)
            .background(Color("denim"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Forgot Password")
            .fontWeight(.bold)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {dismiss()}) {
                        Image(systemName: "xmark")
                    }
                }
            }.buttonStyle(.plain)
            .font(.caption)
    }
}
