//
//  CommentsView.swift
//  ShoofCinema
//
//  Created by mac on 4/28/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct LastCommentView: View {
    
    @ObservedObject var viewModel: CommentViewModel
    
    let showId: String
    let moreAction: () -> Void
    let wirteAction: () -> Void
    
    var body: some View {
        LazyVStack {
            HStack {
                Text("\(Text(LocalizedStringKey(stringLiteral: "comments")))")
                    .textCase(.uppercase)
                
                Spacer()
                
                Button(action: {wirteAction()}) {
                    Text(LocalizedStringKey(stringLiteral: "writeComment"))
                        .textCase(.uppercase)
                        .foregroundColor(.red)
                }
                                    
            }
            
            if viewModel.comments.isEmpty && !viewModel.isLoading  {
                Text(LocalizedStringKey("noComments"))
                    .padding()
            }
            
            else {
                if viewModel.isLoading {
                    mockCommentsView
                }
                else {
                    ForEach(0 ..< viewModel.comments.count, id: \.self) { index in
                        CommentView(comment: viewModel.comments[index])
                    }
                }
                
                if viewModel.hasNextPage && !viewModel.isLoading {
                    mockCommentView
                        .onAppear {
                            viewModel.fetchMoreComment()
                        }
                }
            }
            
//            Button(action: {wirteAction()}) {
//                Text("writeComment")
//                    .textCase(.uppercase)
//                    .foregroundColor(.red)
//                    .padding()
//            }
        }.padding()
            .buttonStyle(.plain)
            .task {
                viewModel.fetchComments()
            }
    }
    
    @ViewBuilder private var mockCommentsView: some View  {
        ForEach(0 ..< 10) {_ in
            mockCommentView
        }
    }
    
    @ViewBuilder private var mockCommentView: some View  {
        CommentView(comment: viewModel.mockComment)
            .redacted(reason: .placeholder)
            .shimmering()
    }
}


