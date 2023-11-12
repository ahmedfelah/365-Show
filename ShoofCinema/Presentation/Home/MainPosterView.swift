//
//  MainPosterView.swift
//  ShoofCinema
//
//  Created by mac on 6/30/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI
import Kingfisher


struct MainPosterView: View {
    
    
    let show: ShoofAPI.Show
    
    var body: some View {
        ZStack(alignment: .bottom) {
            KFImage.url(show.posterURL)
                .placeholder {
                    Color.black
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(
                    width: UIScreen.main.bounds.width,
                    height: UIScreen.main.bounds.height * 0.6
                ).clipped()
            
            Rectangle().fill(LinearGradient(colors: [.clear, .primaryBrand], startPoint: .top, endPoint: .bottom))
                .frame(height: UIScreen.main.bounds.height * 0.3)
            
            if show.titleImageURL != nil {
                KFImage.url(show.titleImageURL)
                    .placeholder {
                        Color.clear
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 150).clipped()
                    .padding()
            }
        }.foregroundColor(.white)
            .buttonStyle(.plain)
    }
}

//struct MainCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainPosterView()
//    }
//}
