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
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    var hasDownloads = realm.objects(RDownload.self)
        .filter { $0.status == DownloadStatus.downloaded.rawValue }.count > 0
    
    @StateObject var viewModel = ProfileViewModel()
    
    private var languageHelper = LanguageHelper()
    
    
    var body: some View {
        NavView {
            ScrollView {
                userInfoView
                
                VStack {
                    loginView
                    
                    Divider()
                        .frame(minHeight: 2)
                        .overlay(.black)
                    
                    downloadView
                    
                }
                
                if !isOutsideDomain {
                    VStack {
                        //settingsView
                        
                        userListView
                        
                        HStack {
                            Text("help and support")
                            
                            Spacer()
                            
                            Image(systemName: "chevron.forward")
                        }.padding()
                        
                        
                        
                        Divider()
                            .frame(minHeight: 2)
                            .overlay(.black)
                        
                        Text("enjoying the app?")
                            .padding()
                        
                        Text("tell your friends about it.")
                            .foregroundColor(.gray)
                            .font(.caption)
                            .padding(.bottom)
                        
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                
                                Text("share the app")
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
                
                favouritaView
                
                watchLaterView
                
                
                
                                
                languageView
                
                logoutView
                
                deleteAccountView
                
                Divider()
                    .frame(minHeight: 2)
                    .overlay(.black)
                
                Text("Version \(appVersion ?? "")")
                    .foregroundColor(.gray)
                    .font(.caption)
                    .frame(maxWidth: .infinity)
            }
            .background(Color.primaryBrand)
            .foregroundColor(.primaryText)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("user profile")
            
        }.onAppear {
            viewModel.user = ShoofAPI.User.current
        }
        
    }
    
    @ViewBuilder private var userListView: some View {
        NavigationLink(destination: {
            UserListView()
        }, label: {
            HStack {
                Text("user list")
                
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
                Text("logout")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.primaryBrand)
            })
            .alert("logout", isPresented: $showingLogoutAlert) {
                Button("yes") {
                    viewModel.loagout()
                }
                Button("no", role: .cancel) {}
            } message: {
                Text("are you sure you want to logout")
            }
        }
    }
    
    @ViewBuilder private var languageView: some View {
        if !isOutsideDomain {
            Divider()
                .frame(minHeight: 2)
                .overlay(.black)

            Button(action: {languageHelper.changeLanguageForIOS13()}, label: {
                Text("language")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.primaryBrand)
            })
        }
    }
    
    @ViewBuilder private var watchLaterView: some View {
        if isOutsideDomain {
            NavigationLink(destination: {
                WatchLaterView()
            }, label: {
                Text("watch later")
                
                Spacer()
                
                Image(systemName: "chevron.forward")
            }).padding()
        }
    }
    
    @ViewBuilder private var favouritaView: some View {
        if isOutsideDomain {
            NavigationLink(destination: {
                FavouriteListView()
            }, label: {
                Text("favourite")
                
                Spacer()
                
                Image(systemName: "chevron.forward")
            }).padding()
            
            Divider()
                .frame(minHeight: 2)
                .overlay(.black)
        }
    }
    
    @ViewBuilder private var deleteAccountView: some View {
        if let _ = ShoofAPI.User.current {
            Divider()
                .frame(minHeight: 2)
                .overlay(.black)
            
            Button(action: {showingDeleteAccountAlert.toggle()}, label: {
                Text("delete account")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.primaryBrand)
            })
            .alert("delete Account", isPresented: $showingDeleteAccountAlert) {
                Button("yes") {
                    viewModel.deleteAccount()
                }
                Button("no", role: .cancel) {}
            } message: {
                Text("deleteAccountConfirmMessage")
            }
        }
        
        
    }
    
    @ViewBuilder private var settingsView: some View {
        NavigationLink(destination: {
            SettingsView()
        }, label: {
            HStack {
                Text("settings")
                
                Spacer()
                
                Image(systemName: "chevron.forward")
            }
        }).padding()
        
        Divider()
            .frame(minHeight: 2)
            .overlay(.black)
    }
    
    @ViewBuilder private var downloadView: some View {
        if !isOutsideDomain || self.hasDownloads {
            NavigationLink(destination: DownloadsView(), label: {
                HStack {
                    Text("downloads")
                    
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
            Text("have an account?")
                .padding()
            
            Text("log in and get more.")
                .foregroundColor(.gray)
                .font(.caption)
                .padding(.bottom)
            
            Button(action: {isPresented.toggle()}) {
                HStack {
                    Text("login")
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
