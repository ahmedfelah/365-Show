//
//  SwiftUIView.swift
//  ShoofCinema
//
//  Created by mac on 7/5/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI
import Kingfisher

struct SmallPosterView: View {
    
    @State var watchingProgress = 0.6
    
    
    let show: ShoofAPI.Show
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .center) {
                KFImage.url(show.coverURL)
                    .placeholder {
                        Color.black
                        
                        ZStack {
                            Image("360-show")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100)
                                .padding()
                                .opacity(0.2)
                            
                           
                        }
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }.frame(width: 120, height: 170)
                .clipped()
                .cornerRadius(2)
            
            HStack {
                Text("IMDB")
                    .font(.system(size: 8))
                    .padding(3)
                    .background(Color("imdb"))
                    .cornerRadius(5)
                    .foregroundColor(.black)
                    .padding(3)
                
                
                Text("\(show.imdbID ?? "")")
                    .padding(3)
                    .font(.caption2)
            }
            
            Text("\(show.title)")
                .lineLimit(1)
                .padding([.leading, .trailing], 3)
                .font(.caption)
            
            Text("Darama, Action, Romance")
                .lineLimit(1)
                .padding([.leading, .trailing, .bottom], 3)
                .foregroundColor(.gray)
                .font(.caption)
                
        }.foregroundColor(.white)
            .frame(width: 120)
            
        
    }
}


