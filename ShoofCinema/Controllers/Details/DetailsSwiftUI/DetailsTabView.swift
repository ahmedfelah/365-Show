//
//  DetailsTabView.swift
//  ShoofCinema
//
//  Created by mac on 4/28/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct DetailsTabView: View {
    @State var currentTab = 0
    
    let show: ShoofAPI.Show
    let tabbar: RoundedTabBar
    let moreAction: () -> Void
    let wirteAction: () -> Void
    
    var body: some View {
        VStack() {
            if show.isMovie || !appPublished {
                LastCommentView(viewModel: CommentViewModel(showId: show.id), showId: show.id, moreAction: moreAction, wirteAction: wirteAction)
            }
            else {
                TabBarView(currentTab: $currentTab)
                if currentTab == 0 {
                    SeasonsView(show: show, tabbar: tabbar)
                }
                else {
                    LastCommentView(viewModel: CommentViewModel(showId: show.id), showId: show.id, moreAction: moreAction, wirteAction: wirteAction)
                        .frame(maxWidth: .infinity)
                }
            }
        }.padding(.bottom, 100)
        
    }
}

struct TabBarView: View {
    @Binding var currentTab: Int
    @Namespace var namespace
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarItem(currentTab: $currentTab, namespace: namespace, tabBarItemName: "seasons", tab: 0)
                
            
            TabBarItem(currentTab: $currentTab, namespace: namespace.self, tabBarItemName: "comments", tab: 1)
                
                
        }.padding()
    }
}

struct TabBarItem: View {
    @Binding var currentTab: Int
    let namespace: Namespace.ID
    
    var tabBarItemName: String
    var tab: Int
    
    var body: some View {
        Button {
            self.currentTab = tab
        } label: {
            VStack {
                Spacer()
                Text(LocalizedStringKey(stringLiteral: tabBarItemName))
                    .textCase(.uppercase)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if currentTab == tab {
                    Color.red
                        .frame(height: 2)
                        .matchedGeometryEffect(id: "underline",
                                               in: namespace,
                                               properties: .frame)
                } else {
                    Color.gray.frame(height: 2)
                }
            }
            .animation(.spring(), value: self.currentTab)
        }
        .buttonStyle(.plain)
    }
}


