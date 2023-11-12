//
//  DownloadsView.swift
//  ShoofCinema
//
//  Created by mac on 9/1/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI
import RealmSwift

struct DownloadsView: View {
    
    @StateObject var viewModel = DownloadsViewModel()
    
    @State var downloadSectionSelection : DownloadSection = .all
    
    @ObservedResults(RDownload.self, filter: NSPredicate(format: "isSeriesHeader = false")) var items
    
    init() {
        //UISegmentedControl.appearance().selectedSegmentTintColor = .white
        //UISegmentedControl.appearance().backgroundColor = UIColor(Color.secondaryBrand)
        //UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor:UIColor(Color.primaryText)], for: .normal)
        //UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.secondaryBrand)], for: .selected)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                Picker("", selection: $downloadSectionSelection) {
                    ForEach(DownloadSection.allCases, id: \.self) { option in
                        Text(option.rawValue)
                            .foregroundColor(.blue)
                    }
                }.pickerStyle(SegmentedPickerStyle())
                    .padding()
            }.frame(width: 250)
            
            if downloadSectionSelection == .all {
                DownloadAllView(viewModel: viewModel)
            }
            else {
                DownloadCollectionsView(viewModel: viewModel)
            }
        }.background(Color.primaryBrand)
    }
}

struct DownloadsView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadsView()
    }
}


enum DownloadSection : String, CaseIterable {
    case collection = "Collection"
    case all = "All"
}
