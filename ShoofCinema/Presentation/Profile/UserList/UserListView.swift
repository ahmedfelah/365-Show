//
//  UserListView.swift
//  ShoofCinema
//
//  Created by mac on 8/11/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct UserListView: View {
    var body: some View {
        VStack {
            HStack(spacing: 5) {
                NavigationLink(destination: WatchLaterView(), label: {
                    VStack(spacing: 10) {
                        Image(systemName: "rectangle.stack.badge.play.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Color.primaryText)
                        
                        Text("watch later")
                            .font(.title)
                            .fontWeight(.semibold)
                    }.frame(maxWidth: .infinity, maxHeight: 100)
                        .padding(.vertical, 50)
                        .background(Color.primaryBrand)
                })
                
                Spacer()
                
                NavigationLink(destination: WatchedView(), label: {
                    VStack(spacing: 10) {
                        Image(systemName: "backward.end.fill")
                            .padding(5)
                            .background(.white)
                            .foregroundColor(Color.primaryBrand)
                            .font(.system(size: 50))
                            
                        
                        Text("watched")
                            .font(.title)
                            .fontWeight(.semibold)
                    }.frame(maxWidth: .infinity, maxHeight: 100)
                        .padding(.vertical, 50)
                        .background(Color.primaryBrand)
                })
            }
        }.frame(maxHeight:.infinity, alignment: .top)
            .padding(.all)
    }
}
