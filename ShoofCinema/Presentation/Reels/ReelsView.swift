//
//  ReelsView.swift
//  365Show
//
//  Created by ممم on 18/11/2023.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct ReelsView: View {
    
//    @ObservedObject var viewModel = ReelsViewModel()
    @ObservedObject var viewModel = HomeViewModel()
    
    //K2273ibUvIa4IKFgM9deooJWQiO0WNTylYoHBdFe54OumH7OqbXuG5NE pexels
    
    var body: some View {
        ScrollView(.vertical) {
//            if !viewModel.sections.isEmpty {
//                LazyVStack {
//                    ForEach(viewModel.sections[0].shows, id: \.id) { reel in
//                        ReelView(reel: reel)
//                            .frame(maxWidth: .infinity)
//                            .background(Color.pink)
//                            .containerRelativeFrame(.vertical)
//                    }
//                }
//            }
        }//.scrollIndicators(.hidden)
//            .scrollTargetBehavior(.paging)
//            .task {
//                viewModel.loadSections()
//            }
    }
}

#Preview {
    ReelsView()
}
