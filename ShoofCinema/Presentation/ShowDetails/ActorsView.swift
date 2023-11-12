//
//  ActorsView.swift
//  ShoofCinema
//
//  Created by mac on 8/1/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI
import Kingfisher

struct ActorsView: View {
    
    let actors: [ShoofAPI.Actor]
    
    let columns = [
        GridItem(.adaptive(minimum: 120), spacing: 10, alignment: .top)
    ]
    
    var body: some View {
        
        Text("Actors")
            .padding(.horizontal)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(actors.indices, id: \.self) { index in
                VStack(spacing: 0) {
                    KFImage.url(actors[index].imageURL)
                        .placeholder {
                            Color.black
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(width: 75)
                        .clipShape(Circle())
                    
                    Text("\(actors[index].name)")
                        .foregroundColor(.white)
                        .lineLimit(3)
                        .multilineTextAlignment(.center)
                }.frame(height: 140, alignment: .top)
                    
                    .padding(.horizontal)
            }
        }
        .padding(.horizontal)
    }
}


