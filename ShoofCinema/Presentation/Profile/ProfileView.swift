//
//  ProfileView.swift
//  ShoofCinema
//
//  Created by mac on 7/8/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct UserProfileView: View {
    
    @State private var isPresented = false
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAccountAlert = false
    
    @StateObject var viewModel = ProfileViewModel()
    
    private var languageHelper = LanguageHelper()
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                userInfoView
                
                VStack {
                    loginView
                    
                    downloadView
                    
                }
                
                if !isOutsideDomain {
                    VStack {
                        //settingsView
                        
                        userListView
                        
                        HStack {
                            Text("Help and Support")
                            
                            Spacer()
                            
                            Image(systemName: "chevron.forward")
                        }.padding()
                        
                        
                        
                        Divider()
                            .frame(minHeight: 2)
                            .overlay(.black)
                        
                        Text("Enjoying the app?")
                            .padding()
                        
                        Text("Tell your friends about it.")
                            .foregroundColor(.gray)
                            .font(.caption)
                            .padding(.bottom)
                        
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                
                                Text("Share the app")
                                    .font(.callout)
                                
                                
                            }.padding()
                                .padding(.horizontal, 20)
                        }
                        .background(Color.primaryText)
                        .clipShape(Capsule())
                        .padding(.bottom)
                        .foregroundColor(.secondaryText)
                        
                    }
                }
                
                logoutView
                
                deleteAccountView
                
                Text("version 1.0.1")
                    .foregroundColor(.gray)
                    .font(.caption)
                    .frame(maxWidth: .infinity)
            }
            .background(Color.primaryBrand)
            .foregroundColor(.primaryText)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("User Profile")
            
        }.onAppear {
            viewModel.user = ShoofAPI.User.current
        }
        
    }
    
    @ViewBuilder private var userListView: some View {
        NavigationLink(destination: {
            UserListView()
        }, label: {
            HStack {
                Text("User list")
                
                Spacer()
                
                Image(systemName: "chevron.forward")
            }
        }).padding()
        
        Divider()
            .frame(minHeight: 2)
            .overlay(.black)
    }
    
    @ViewBuilder private var logoutView: some View {
        if let _ = ShoofAPI.User.current {
            Divider()
                .frame(minHeight: 2)
                .overlay(.black)
            
            Button(action: {showingLogoutAlert.toggle()}, label: {
                Text("Logout")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.primaryBrand)
            })
            .alert("Logout", isPresented: $showingLogoutAlert) {
                Button("Yes") {
                    viewModel.loagout()
                }
                Button("No", role: .cancel) {}
            } message: {
                Text("Are you sure you want to logout")
            }
        }
    }
    
    @ViewBuilder private var deleteAccountView: some View {
        if let _ = ShoofAPI.User.current {
            Divider()
                .frame(minHeight: 2)
                .overlay(.black)
            
            Button(action: {showingDeleteAccountAlert.toggle()}, label: {
                Text("Delete account")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.primaryBrand)
            })
            .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
                Button("Yes") {
                    viewModel.deleteAccount()
                }
                Button("No", role: .cancel) {}
            } message: {
                Text("Deleting your account will permanently remove all your data and cannot be undone. This action is irreversible. Are you sure you want to proceed?")
            }
            
            Divider()
                .frame(minHeight: 2)
                .overlay(.black)
        }
        
        
    }
    
    @ViewBuilder private var settingsView: some View {
        NavigationLink(destination: {
            SettingsView()
        }, label: {
            HStack {
                Text("Settings")
                
                Spacer()
                
                Image(systemName: "chevron.forward")
            }
        }).padding()
        
        Divider()
            .frame(minHeight: 2)
            .overlay(.black)
    }
    
    @ViewBuilder private var downloadView: some View {
        if !isOutsideDomain {
            Divider()
                .frame(minHeight: 2)
                .overlay(.black)
            
            NavigationLink(destination: DownloadsView(), label: {
                HStack {
                    Text("Downloads")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.forward")
                }
                
            }).padding()
            
            Divider()
                .frame(minHeight: 2)
                .overlay(.black)
        }
    }
    
    @ViewBuilder private var userInfoView: some View {
        if viewModel.user != nil {
            UserInfoView(viewModel: viewModel)
                .padding()
        }
    }
    
    @ViewBuilder private var loginView: some View {
        if viewModel.user == nil {
            Text("Have an account?")
                .padding()
            
            Text("Log in and get more.")
                .foregroundColor(.gray)
                .font(.caption)
                .padding(.bottom)
            
            Button(action: {isPresented.toggle()}) {
                HStack {
                    Text("Login")
                        .font(.callout)
                    
                        .padding()
                        .padding(.horizontal, 10)
                }
            }
            .background(Color.primaryText)
            .clipShape(Capsule())
            .foregroundColor(Color.secondaryText)
            .padding(.bottom)
            .fullScreenCover(isPresented: $isPresented, onDismiss: {
                viewModel.user = ShoofAPI.User.current
            }) {
                SignInView(dismiss: $isPresented)
            }
        }
    }
}
