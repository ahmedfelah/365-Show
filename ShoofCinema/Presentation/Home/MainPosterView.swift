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
        ZStack(alignment: .top) {
            KFImage.url(show.coverURL)
                .placeholder {
                    Color.black
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(
                    maxWidth: UIScreen.main.bounds.width,
                    maxHeight: .infinity,
                    alignment: .top
                )
                .clipped()
    
            
            VStack(alignment: .trailing) {
                if show.titleImageURL != nil {
                    KFImage.url(show.titleImageURL)
                        .placeholder {
                            Color.clear
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .clipped()
                        .padding()
                }
                
                else {
                    Text(show.title)
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
                
                Spacer()
                
                if !isOutsideDomain {
                    WatchButtonView()
                        .padding(.vertical, 10)
                        .padding(.horizontal, 25)
                        .background(Color.secondaryBrand)
                        .clipShape(Capsule())
                        .padding()
                }
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
