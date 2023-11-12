//
//  HorizontalPosterView.swift
//  ShoofCinema
//
//  Created by mac on 7/17/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI
import Kingfisher

struct HorizontalPosterView: View {
    
    let show: ShoofAPI.Show
    
    var body: some View {
        HStack {
            KFImage.url(show.posterURL)
                .placeholder {
                    Color.black
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 180)
                .clipped()
            
            VStack(alignment: .leading) {
                Text("\(show.title)")
                    .lineLimit(1)
                    .padding(.vertical)
                    .font(.caption)
                    .foregroundColor(.white)
                
                //show.genres?.compactMap({$0.name}).joined(separator: ",") ?? ""
                Text("Darama, Action, Romance")
                    .lineLimit(1)
                    .foregroundColor(.gray)
                    .font(.caption)
                
                HStack {
                    Text("IMDB")
                        .font(.system(size: 8))
                        .padding(3)
                        .background(Color("imdb"))
                        .cornerRadius(5)
                        .foregroundColor(.black)
                        .padding(3)
                    
                    Text("\(show.rating ?? "_")")
                        .padding(3)
                        .font(.caption2)
                }.padding(.vertical)
                
            }.padding(.horizontal, 10)
                .foregroundColor(.gray)
        }
    }
}

