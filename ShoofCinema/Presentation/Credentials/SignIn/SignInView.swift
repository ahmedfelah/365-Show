//
//  SignInView.swift
//  ShoofCinema
//
//  Created by mac on 7/8/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct SignInView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel = SignInViewModel()
    
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            NavigationStack {
                VStack(alignment: .center) {
                    Image("360-show")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                        .padding(.bottom)
                    
                    
                    TextFieldView(text: $email, placeholder: "Username")
                        .padding()
                    
                    SecureTextFieldView(text: $password, isSecured: .constant(true))
                        .padding(.horizontal)
                    
                    NavigationLink(destination: {
                        ForgotPasswordView()
                            
                    }, label: {
                        Text("Forgot password?")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white)
                            .padding()
                    })
                    
                    Button(action: {
                        viewModel.submit(email: email, password: password)
                    }) {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                            .padding()
                        
                    }.onReceive(viewModel.$isLogged) { isLogged in
                        if isLogged {
                            dismiss()
                        }
                    }
                    .background(.black)
                    .clipShape(Capsule())
                    .padding()
                    .foregroundColor(.primaryText)
                    
                    Text("or use")
                        .font(.caption)
                        .bold(false)
                        .foregroundColor(.gray)
                    
                    
                    signInWithGoogleView
                    
                    NavigationLink(destination: SignUpView()) {
                        Text("Don't have an account? Join")
                            .foregroundColor(.white)
                    }
                    
                    
                }.frame(maxHeight: .infinity)
                    .background(Color.primaryBrand)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Login")
                    .fontWeight(.bold)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {dismiss()}) {
                                Image(systemName: "xmark")
                            }
                        }
                    }.buttonStyle(.plain)
                
            }
        }.overlay {
            if viewModel.isLoading {
                VStack {
                    LoadingView()
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black.opacity(0.2))
            }
        }
    }
    
    
    
    @ViewBuilder private var signInWithGoogleView: some View {
        if !isOutsideDomain {
            Button(action: {
                viewModel.signInWithGoogle()
            }) {
                HStack(spacing: 0){
                    Image("google")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        
                    Text("Continue with Google")
                        .padding(.vertical)
                }.frame(maxWidth: .infinity)
                
                
            }
            .background(Color.primaryText)
            .foregroundColor(.secondaryText)
            .clipShape(Capsule())
            .padding()
        }
    }
}
