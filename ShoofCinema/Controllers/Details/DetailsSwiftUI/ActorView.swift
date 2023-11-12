//
//  ActorView.swift
//  ShoofCinema
//
//  Created by mac on 4/28/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct ActorView: View {
    let actor: ShoofAPI.Actor
    var body: some View {
        VStack {
            ZStack {
                Rectangle().fill(.clear)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.red, lineWidth: 1)
                    )
                
                KingFisherImageView(url: actor.imageURL)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 90, height: 90)
                    .clipped()
                    .cornerRadius(20)
                    
            }.frame(width: 100, height: 100)
            
            Text("\(actor.name)")
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(alignment: .center)
            
        }
    }
}

