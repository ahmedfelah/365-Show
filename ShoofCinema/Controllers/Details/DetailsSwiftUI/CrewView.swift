//
//  CrewView.swift
//  ShoofCinema
//
//  Created by mac on 4/28/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct CrewView: View {
    let actors: [ShoofAPI.Actor]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(0 ..< actors.count, id: \.self) { index in
                    ActorView(actor: actors[index]).frame(width: 120)
                }
            }
        }
    }
}
