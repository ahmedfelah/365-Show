//
//  AllCommentsView.swift
//  ShoofCinema
//
//  Created by mac on 5/26/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct AllCommentsView: View {
    
    @StateObject var viewModel: CommentViewModel
    
    var body: some View {
        LazyVStack {
            ForEach(0 ..< viewModel.comments.count, id: \.self) { index in
                CommentView(comment: viewModel.comments[index])
            }
            
            
            if viewModel.hasNextPage && !viewModel.isLoading {
                CommentView(comment: viewModel.mockComment)
                    .redacted(reason: .placeholder)
                    .shimmering()
                    .onAppear {
                        viewModel.fetchMoreComment()
                    }
            }
        }.background(.black)
    }
}


