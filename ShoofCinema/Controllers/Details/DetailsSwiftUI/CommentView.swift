//
//  CommentView.swift
//  ShoofCinema
//
//  Created by mac on 4/28/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct CommentView: View {
    let comment: ShoofAPI.Comment
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .fill(Color(uiColor: Theme.current.backgroundColor))
                        .frame(height: 50)
                    
                    if comment.userProfileURL != nil {
                        KingFisherImageView(url: comment.userProfileURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50,height: 50)
                            .clipShape(Circle())
                    } else {
                        Text(comment.userName?.prefix(1) ?? "A")
                            .bold()
                            .font(.largeTitle)
                            .textCase(.uppercase)
                            .foregroundColor(Color(uiColor: Theme.current.tintColor))
                    }
                    
                    
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(comment.userName ?? "")")
                        .lineLimit(1)
                    
                    Text("\(comment.message)")
                        .lineLimit(6)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
        }.frame(maxWidth: .infinity)
            .background(Color(uiColor: Theme.current.secondaryColor))
            .environment(\.layoutDirection, .rightToLeft)
    }
}

