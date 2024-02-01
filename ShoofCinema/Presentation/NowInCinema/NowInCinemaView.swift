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
    
    let cinemas = [
        "Al-Zawra'a Cinema", "Retro Cinema", "Holly Cimema", "Empire Cinema"
    ]
    
    let posters: [URL] = [
        URL(string: "https://cinema5-api.shoofnetwork.net:2053/993b9043-9710-411f-b213-00d52dbba5dc/Pc8warJLo0tw3yp/Pc8warJLo0tw3yp.jpg")!,
        URL(string: "https://cinema5-api.shoofnetwork.net:2053/993b9043-9710-411f-b213-00d52dbba5dc/XsXZmDViEVhF8XW/XsXZmDViEVhF8XW.jpg")!,
        URL(string: "https://cinema5-api.shoofnetwork.net:2053/993b9043-9710-411f-b213-00d52dbba5dc/xWZmilz6N66Ncw4/xWZmilz6N66Ncw4.jpg")!,
        URL(string: "https://cinema5-api.shoofnetwork.net:2053/993b9043-9710-411f-b213-00d52dbba5dc/6DG4ZTKLMMTldVR/6DG4ZTKLMMTldVR.jpg")!,
        URL(string: "https://cinema5-api.shoofnetwork.net:2053/993b9043-9710-411f-b213-00d52dbba5dc/35UDSworUOdiRNc/35UDSworUOdiRNc.jpg")!,
        URL(string: "https://cinema5-api.shoofnetwork.net:2053/993b9043-9710-411f-b213-00d52dbba5dc/IS3PPgDk8cxROlH/IS3PPgDk8cxROlH.jpg")!,
        URL(string: "https://cinema5-api.shoofnetwork.net:2053/993b9043-9710-411f-b213-00d52dbba5dc/Zv4njgEiwDAU6z9/Zv4njgEiwDAU6z9.jpg")!,
        URL(string: "https://cinema5-api.shoofnetwork.net:2053/993b9043-9710-411f-b213-00d52dbba5dc/cDu0mS8E4edZLhO/cDu0mS8E4edZLhO.jpg")!,
        URL(string: "https://cinema5-api.shoofnetwork.net:2053/993b9043-9710-411f-b213-00d52dbba5dc/EgOkplqFGYSBJF6/EgOkplqFGYSBJF6.jpg")!
    ]
    
    @StateObject var viewModel = HomeViewModel()
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                if !viewModel.sections.isEmpty {
                    ForEach(viewModel.sections[1].shows, id: \.id) { poster in
                        VStack {
                            ZStack(alignment: .bottom) {
                                KFImage.url(poster.posterURL)
                                    .placeholder {
                                        Color.black
                                    }
                                    .resizable()
                                    .fade(duration: 0.25)
                                    .aspectRatio(contentMode: .fill)
                                    .frame(
                                        width: UIScreen.main.bounds.width,
                                        height: UIScreen.main.bounds.height * 0.7
                                    ).clipped()
                                
                                Rectangle().fill(LinearGradient(colors: [.clear, .primaryBrand], startPoint: .top, endPoint: .bottom))
                                    .frame(height: UIScreen.main.bounds.height * 0.3)
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack {
                                    ForEach(cinemas, id: \.self) {cinema in
                                        daysView(name: cinema)
                                            .scrollTargetLayout()
                                            .padding(.leading, 20)
                                            .padding(.bottom, 20)
                                    }
                                }
                            }
                        }
                            .frame(maxWidth: .infinity)
                            .containerRelativeFrame(.vertical)
                    }
                }
            }.scrollTargetLayout()
        }.edgesIgnoringSafeArea(.all)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
            .statusBar(hidden: true)
            .background(Color.primaryBrand)
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
        }.safeAreaPadding(.vertical)
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
