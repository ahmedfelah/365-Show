//
//  SegmentControlView.swift
//  365Show
//
//  Created by ممم on 08/03/2024.
//  Copyright © 2024 AppChief. All rights reserved.
//

import SwiftUI

struct SegmentControlView<ID: Identifiable, Content: View, Background: Shape>: View {
    let segments: [ID]
    @Binding var selected: ID
    var titleNormalColor: Color
    var titleSelectedColor: Color
    var bgColor: Color
    let animation: Animation
    @ViewBuilder var content: (ID) -> Content
    @ViewBuilder var background: () -> Background
    
    @Namespace private var namespace
    
    var body: some View {
        GeometryReader { bounds in
            HStack(spacing: 0) {
                ForEach(segments) { segment in
                    NewSegmentButtonView(id: segment,
                                         selectedId: $selected,
                                         titleNormalColor: titleNormalColor,
                                         titleSelectedColor: titleSelectedColor,
                                         bgColor: bgColor,
                                         animation: animation,
                                         namespace: namespace) {
                        content(segment)
                    } background: {
                        background()
                    }
                    .frame(width: bounds.size.width / CGFloat(segments.count))
                }
            }.padding(6)
            .background {
                background()
                    .fill(Color.secondaryBrand)
            }
        }
    }
}

fileprivate struct NewSegmentButtonView<ID: Identifiable, Content: View, Background: Shape> : View {
    let id: ID
    @Binding var selectedId: ID
    var titleNormalColor: Color
    var titleSelectedColor: Color
    var bgColor: Color
    var animation: Animation
    var namespace: Namespace.ID
    @ViewBuilder var content: () -> Content
    @ViewBuilder var background: () -> Background
    
    
    var body: some View {
        GeometryReader { bounds in
            Button {
                withAnimation(animation) {
                    selectedId = id
                }
            } label: {
                content()
            }
            .frame(width: bounds.size.width, height: bounds.size.height)
            .scaleEffect(selectedId.id == id.id ? 1 : 0.8)
            .clipShape(background())
            .foregroundColor(selectedId.id == id.id ? titleSelectedColor : titleNormalColor)
            .background(buttonBackground)
        }
    }
    
    @ViewBuilder private var buttonBackground: some View {
        if selectedId.id == id.id {
            background()
                .fill(bgColor)
                .matchedGeometryEffect(id: "SelectedTab", in: namespace)
        }
    }
}

enum SegmentSortBy: Identifiable, CaseIterable {
    case rate, views, year
    
    var id: String {
        title
    }
    
    var value: Int {
        switch self {
        case .rate:
            return 1
        case .views:
            return 2
        case .year:
            return 3
        }
    }
    
    var title: String {
        switch self {
        case .rate:
            return "rating"
        case .views:
            return "views"
        case .year:
            return "year"
        }
    }
}
