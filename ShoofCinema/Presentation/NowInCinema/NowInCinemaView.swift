//
//  NowInCinemaView.swift
//  365Show
//
//  Created by ممم on 30/11/2023.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI
import Kingfisher

struct NowInCinemaView: View {
    
    @State var index = 0
    
    let cinemas = [
        "Al-Zawra'a Cinema", "Retro Cinema", "Holly Cimema", "Empire Cinema"
    ]
    
    
    @StateObject var viewModel = HomeViewModel()
    var body: some View {
        VStack {
            if !viewModel.sections.isEmpty {
                TabView(selection: $index.animation()) {
                    ForEach(viewModel.sections[1].shows.indices, id:\.self) { index in
                        CinemaPosterView(show: viewModel.sections[1].shows[index])
                    }
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: UIScreen.main.bounds.height)
            }
        }
        .task {
            viewModel.loadSections()
        }
        .overlay {
            if viewModel.status == .loading {
                VStack {
                    LoadingView()
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black.opacity(0.2))
            }
        }
    }
    
    @ViewBuilder private func daysView(name: String) -> some View {
        VStack {
            Text(name)
                .font(.subheadline)
            
            HStack(content: {
                ForEach(showDate(showDays: 2), id: \.self) { date in
                    VStack {
                        ForEach(convertStringDateToArray(string: date), id: \.self) { dateString in
                            Text(dateString)
                                .font(.caption)
                        }
                    }.padding(10)
                    .background(.black)
                    .cornerRadius(10)
                    
                }
            })
        }
    }
    
    private func showDate(showDays: Int) -> [String]{
        let cal = Calendar.current
        var date = Date()
        var days = [String]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ccc-dd-MMM"
        for _ in 0 ... showDays {
            let dateFormat = dateFormatter.string(from: date)
    
            days.append(dateFormat)
            date = cal.date(byAdding: .day, value: +1, to: date)!
        }
        return days
    }
    
    private func convertStringDateToArray(string: String) -> [String] {
        return string.components(separatedBy: "-")
    }
    
    
}

#Preview {
    NowInCinemaView()
}
