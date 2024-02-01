//
//  PosterView.swift
//  ShoofCinema
//
//  Created by mac on 6/30/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct PosterView: View {
    
    @State var watchingProgress = 0.6
    
    let show: ShoofAPI.Show
    
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .center) {
                AsyncImage(url: show.posterURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    
                } placeholder: {
                    Color.black
                }
                
                
                
                VStack {
                    Text("")
                        .frame(maxHeight: .infinity)
                    
                    Spacer()
                    
                    VStack {
                        Image(systemName: "play.circle.fill")
                            .imageScale(.large)
                        
                        Text("Continue")
                            .font(.caption)
                            .bold()
                    }.frame(maxHeight: .infinity, alignment: .top)
                    
                    Spacer()
                    
                    
                    Rectangle().fill(LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom))
                        .frame(height: 50)
                }
            }.frame(width: 120, height: 150)
                .clipped()
                .cornerRadius(10)
            
            ProgressView(value: watchingProgress, total: 1)
                .progressViewStyle(LinearProgressViewStyle(tint: .red))
                .background(Color.white)
                .cornerRadius(5)
                .padding(.top, 10)
            
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
                .font(.callout)
            
            Text("Darama, Action, Romance")
                .lineLimit(1)
                .padding([.leading, .trailing, .bottom], 3)
                .foregroundColor(.gray)
                .font(.caption)
            
        }.foregroundColor(.white)
            .frame(width: 120)
    }
}

//struct PosterView_Previews: PreviewProvider {
//    static var previews: some View {
//        PosterView(, show: .)
//    }
//}
