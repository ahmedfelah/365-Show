//
//  CinemaPosterView.swift
//  365Show
//
//  Created by ممم on 09/02/2024.
//  Copyright © 2024 AppChief. All rights reserved.
//

import SwiftUI
import Kingfisher

struct CinemaPosterView: View {
    let show: ShoofAPI.Show
    
    let cinemas = [
        "Al-Zawra'a Cinema", "Retro Cinema", "Holly Cimema", "Empire Cinema"
    ]
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                KFImage.url(show.posterURL)
                    .placeholder {
                        Color.black
                    }
                    .resizable()
                    .fade(duration: 0.25)
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        height: UIScreen.main.bounds.height * 0.8
                    ).clipped()
                
                Rectangle().fill(LinearGradient(colors: [.clear, .primaryBrand], startPoint: .top, endPoint: .bottom))
                    .frame(height: UIScreen.main.bounds.height * 0.3)
                
                
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(cinemas, id: \.self) {cinema in
                        daysView(name: cinema)
                            .padding(.leading, 20)
                            .padding(.bottom, 20)
                    }
                }
            }
            
            
        }.frame(maxWidth: .infinity)
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

//#Preview {
//    CinemaPosterView()
//}
