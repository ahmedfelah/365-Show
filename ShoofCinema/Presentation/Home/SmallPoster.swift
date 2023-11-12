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
                KFImage.url(show.posterURL)
                    .resizable()
                    .fade(duration: 0.4)
                    .frame(width: 120, height: 180)
                    .scaledToFill()
                    .clipped()
            }
                
        }.foregroundColor(.white)
            .frame(width: 120)
            
        
    }
}


