//
//  UserInfoView.swift
//  ShoofCinema
//
//  Created by mac on 8/4/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI
import Kingfisher

struct UserInfoView: View {
    
    
    @StateObject var viewModel: ProfileViewModel
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill()
                    .frame(width: 130, height: 130)
                
                userDefaultAvatar
                
                userAvatar
                
                
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text("\(viewModel.user?.name ?? "")")
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: "qrcode")
                        .padding(5)
                        .background(Color.primaryBrand)
                        .cornerRadius(10)
                }.frame(maxWidth: .infinity)
                
//                NavigationLink(destination: UpdateUserInfoView(viewModel: viewModel), label: {
//                    Text("Edit")
//                        .padding(.horizontal, 25)
//                        .padding(.vertical, 10)
//                        .background(Color.primaryBrand)
//                        .font(.title3)
//                })
            }.padding()
                .font(.title2)
                .bold()
        }.buttonStyle(.plain)
    }
    
    @ViewBuilder private var userDefaultAvatar: some View {
        if viewModel.user?.image == nil {
            Image(systemName: "person.fill")
                .font(.system(size: 60))
                .foregroundColor(Color.primaryBrand)
        }
    }
    
    @ViewBuilder private var userAvatar: some View {
        if let avatar = viewModel.user?.image {
            KFImage.url(nil)
                .placeholder {
                    Color.black
                }
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 150)
                .clipShape(Circle())
        }
    }
    
}

