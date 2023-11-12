//
//  SignUpView.swift
//  ShoofCinema
//
//  Created by mac on 7/8/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct SignUpView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel = SignUpViewModel()
    
    var body: some View {
        ZStack {
            Color.primaryBrand.edgesIgnoringSafeArea(.all)
            
            VStack {
                Image("360-show")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                    .padding(.bottom)
                
                TextFieldView(text: $viewModel.email, placeholder: "E-mail address")
                    .padding([.top, .horizontal])
                
                TextFieldView(text: $viewModel.name, placeholder: "Name")
                    .padding()
                
                SecureTextFieldView(text: $viewModel.password, isSecured: .constant(true))
                    .padding(.horizontal)
                
                Button(action: {viewModel.signUp()}) {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .padding()
                    
                }.onReceive(viewModel.$isLogged) { isLogged in
                    if isLogged {
                        dismiss()
                    }
                }

                .background(Color.primaryText)
                .clipShape(Capsule())
                .padding()
                .foregroundColor(.secondaryText)
                .padding(.top)
            }.padding(.top)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Sign Up")
                .fontWeight(.bold)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {dismiss()}) {
                            Image(systemName: "xmark")
                        }
                    }
                }.buttonStyle(.plain)
                .font(.caption)
                .overlay {
                    if viewModel.isLoading {
                        VStack {
                            LoadingView()
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.black.opacity(0.2))
                    }
                }
        }
    }
}
