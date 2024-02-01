//
//  SignUpView.swift
//  ShoofCinema
//
//  Created by mac on 7/8/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct SignUpView: View {
    
    @Binding var dismiss: Bool
    
    @StateObject var viewModel = SignUpViewModel()
    
    var body: some View {
        ScrollView {
            ZStack {
                
                
                VStack {
                    Image("360-show")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                        .padding(.bottom)
                    
                    Text("\(viewModel.errors)")
                        .font(.caption)
                        .foregroundColor(.red)
                    
                    TextFieldView(text: $viewModel.name, placeholder: "Name")
                        .padding([.top, .horizontal])
                        
                    
                    TextFieldView(text: $viewModel.email, placeholder: "E-mail address")
                        .padding([.top, .horizontal])
                    
                    TextFieldView(text: $viewModel.username, placeholder: "Username")
                        .padding()
                    
                    SecureTextFieldView(text: $viewModel.password, isSecured: .constant(true))
                        .padding(.horizontal)
                    
                    Button(action: {viewModel.signUp()}) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .padding()
                        
                    }.onReceive(viewModel.$isLogged) { isLogged in
                        if isLogged {
                            dismiss.toggle()
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
                            Button(action: {dismiss.toggle()}) {
                                Image(systemName: "xmark")
                            }
                        }
                    }.buttonStyle(.plain)
                    .font(.caption)
                    
            }
        }.background(Color.primaryBrand)
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
