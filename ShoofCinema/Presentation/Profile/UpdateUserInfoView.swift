//
//  UpdateUserInfoView.swift
//  ShoofCinema
//
//  Created by mac on 8/7/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI
import PhotosUI
import Kingfisher

struct UpdateUserInfoView: View {
    @State private var selectedAvatar: Image?
    @State private var avatarItem: PhotosPickerItem?
    @StateObject var viewModel: ProfileViewModel
    var body: some View {
        ScrollView {
            HStack {
                avatarView
                
                VStack(alignment: .leading) {
                    fullNameView
                        .font(.title2)
                    
                    updateImageView
                        .font(.title3)
                }
                
                Spacer()
            }.padding()
            
            genralView
            
            securityView
                .padding(.top)
            
        }.frame(maxWidth: .infinity)
            .background(Color("denim"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("User Profile")
            .background(Color.primaryBrand)
            .buttonStyle(.plain)
            .onChange(of: avatarItem) { _ in
                Task {
                    if let data = try? await avatarItem?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            self.viewModel.changeAvatar(avatar: uiImage)
                            return
                        }
                    }
                    
                    print("Failed")
                }
            }
            .overlay {
                if viewModel.status == .loading {
                    VStack {
                        LoadingView()
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.black.opacity(0.2))
                }
            }
    }
    
    
    
    
    @ViewBuilder private var avatarView: some View {
        ZStack {
            KFImage.url(viewModel.user?.image)
                .placeholder {
                    Image(systemName: "person.fill")
                        .font(.system(size: 70))
                        .foregroundColor(Color.primaryBrand)
                }
                .resizable()
                .resizable()
                .fade(duration: 0.25)
                .scaledToFill()
            
        }.frame(width: 150, height: 150)
            .background(.white)
            .clipShape(Circle())
            
    }
    
    @ViewBuilder private var fullNameView: some View {
        Text("Ahmed Felah")
            .lineLimit(1)
    }
    
    @ViewBuilder private var updateImageView: some View {
        PhotosPicker("Select avatar", selection: $avatarItem, matching: .images)
            .font(.caption2)
            .padding(5)
            .background(Color.primaryBrand)
    }
    
    @ViewBuilder private var genralView: some View {
        VStack(alignment:  .leading, spacing: 25) {
            Text("Genral")
                .font(.title)
                .padding(.horizontal)
            
            textFieldView(labal: "First name", text: $viewModel.fullName)
            
            textFieldView(labal: "Email", text: $viewModel.email)
            
            textFieldView(labal: "Phone", text: $viewModel.phone)
            
            buttonView(action: {viewModel.changePassword()}, title: "Save change")
        }
    }
    
    @ViewBuilder private var securityView: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Security")
                .font(.title)
                .padding(.horizontal)
            
            textFieldSecureView(labal: "New password", text: $viewModel.newPassword)
            
            buttonView(action: {viewModel.changePassword()}, title: "Change password")
        }
    }
    
    @ViewBuilder private func buttonView(action: @escaping () -> Void, title: String) ->  some View {
        Button(action: action) {
            Text("\(title)")
                .frame(maxWidth: .infinity)
                .padding()
            
        }
        .background(.white)
        .cornerRadius(10)
        .padding()
        .foregroundColor(Color.primaryBrand)
    }
    
    @ViewBuilder private func textFieldView(palceHolder: String = "", labal: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            Label {
                Text("\(labal)")
            } icon: {}
            
            TextFieldView(text: text, placeholder: palceHolder)
        }.padding(.horizontal)

    }
    
    @ViewBuilder private func textFieldSecureView(palceHolder: String = "", labal: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            Label {
                Text("\(labal)")
            } icon: {}
            
            SecureTextFieldView(text: text, isSecured: .constant(true))
        }.padding(.horizontal)

    }
}
