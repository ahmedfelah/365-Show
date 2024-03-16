//
//  ShowsFilterView.swift
//  ShoofCinema
//
//  Created by mac on 7/30/23.
//  Copyright © 2023 AppChief. All rights reserved.
//


import SwiftUI

struct ShowsFilterView: View {
    
    @State var selectedType: ShoofAPI.Filter.MediaType = .all
    @State var selectedSortBy: SegmentSortBy = .rate
    
    @Environment(\.dismiss) var dismis

    let viewModel: ShowViewModel
    
    var body: some View {
        GeometryReader { bounds in
            VStack {
                HStack {
                    Text("filter")
                    
                    Spacer()
                    
                    Text("reset")
                        .foregroundColor(.secondaryBrand)
                        .onTapGesture {
                            withAnimation {
                                selectedType = .all
                                selectedSortBy = .rate
                            }
                        }
                    
                }.font(.caption.bold())
                    .padding()
                    .padding(.top)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("type")
                        .font(.title2.bold())
                    
                    SegmentControlView(segments: ShoofAPI.Filter.MediaType.allCases.reversed(),
                                       selected: $selectedType,
                                       titleNormalColor: .white,
                                       titleSelectedColor: .primaryBrand,
                                       bgColor: .white,
                                       animation: .spring) { segment in
                        Text(LocalizedStringKey(segment.title))
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                    } background: {
                        RoundedRectangle(cornerRadius: 17, style: .continuous)
                    }
                    .frame(height: 50)
                    
                    
                    Text("sort by")
                        .padding(.top)
                        .font(.title2.bold())
                    
                    SegmentControlView(segments: SegmentSortBy.allCases,
                                       selected: $selectedSortBy,
                                       titleNormalColor: .white,
                                       titleSelectedColor: .primaryBrand,
                                       bgColor: .white,
                                       animation: .spring) { segment in
                        Text(LocalizedStringKey(segment.title))
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                        
                            .padding(.vertical, 8)
                    } background: {
                        RoundedRectangle(cornerRadius: 17, style: .continuous)
                    }
                    .frame(height: 50)
                }
                .padding(.top, 50)
                .padding()
                .padding(.trailing, 10)
                
                Button("show result") {
                    viewModel.filter?.mediaType = selectedType
                    
                    switch selectedSortBy {
                    case .rate:
                        viewModel.filter?.sortType = .rateDescending
                        
                    case .views:
                        viewModel.filter?.sortType = .viewsDescending
                        
                    case .year:
                        viewModel.filter?.sortType = .yearDescending
                    }
                    
                    viewModel.loadShows()
                    
                    dismis()
                    
                }.frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color.primaryBrand)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .padding()
            }.onAppear {
                selectedType = viewModel.filter?.mediaType ?? .all
                
                switch viewModel.filter?.sortType {
                case .rateDescending:
                    selectedSortBy = .rate
                    
                case .viewsDescending:
                    selectedSortBy = .views
                    
                case .yearDescending:
                    selectedSortBy = .year
                    
                default:
                    selectedSortBy = .rate
                }
            }
        }
    }
    
    @ViewBuilder private func filterButtonView(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text("\(title)")
                    .lineLimit(1)
                
                Image(systemName: "chevron.down")
            }.padding()
                .frame(width: 140)
        }.background(Color.primaryBrand)
            .clipShape(Capsule())
    }
}



//@StateObject var viewModel: ShowViewModel
//
//@State private var selectedIndexYear = 0
//@State private var selectedIndexGenre: Int = 0
//@State private var selectedIndexSorting: Int = 0
//
//@State var isOpenYearDropdownMenu: Bool = false
//@State var isOpenGenreDropdownMenu: Bool = false
//@State var isOpenSortingDropdownMenu: Bool = false
//
//var body: some View {
//    VStack {
//        HStack {
//            Button(action: {}) {
//                Text("Movies")
//                    .font(.caption)
//                    .foregroundColor(.white)
//                    .bold()
//                    .padding()
//                    .frame(minWidth: 80)
//                    .overlay {
//                        Capsule(style: .continuous)
//                            .stroke(.white, lineWidth: 1)
//                    }
//                
//            }
//                .padding()
//            
//            Button(action: {}) {
//                Text("TV Shows")
//                    .font(.caption)
//                    .foregroundColor(.white)
//                    .bold()
//                    .padding()
//                    .frame(minWidth: 80)
//                    
//            }
//                .padding()
//        }
//        
//        HStack(alignment: .top) {
//            Menu {
//                Picker(selection: $selectedIndexGenre,
//                       label: EmptyView(),
//                       content: {
//                    ForEach(viewModel.allGenres.indices, id: \.self) { index in
//                        Text(viewModel.allGenres[index].localizedString)
//                    }
//                }).pickerStyle(.automatic)
//                    .accentColor(.white)
//            } label: {
//                HStack {
//                    Image(systemName: "chevron.down")
//                    
//                    Text(viewModel.allGenres[selectedIndexGenre].localizedString)
//                    
//                }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.leading)
//                    .frame(height: 55)
//                    .background(Color.primaryBrand)
//                    .cornerRadius(10)
//                    .foregroundColor(.white)
//            }.padding(.bottom)
//            
//            Menu {
//                Picker(selection: $selectedIndexYear,
//                       label: EmptyView(),
//                       content: {
//                    Text("Upload date")
//                    Text("Release date")
//                    Text("English title")
//                    Text("Arabic title")
//                    Text("Views")
//                    Text("Parental Rating")
//                    Text("IMDB Rating")
//                }).pickerStyle(.automatic)
//                    .accentColor(.white)
//            } label: {
//                HStack {
//                    Image(systemName: "chevron.down")
//                    
//                    Text("Upload date")
//                    
//                }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.leading)
//                    .frame(height: 55)
//                    .background(Color.primaryBrand)
//                    .cornerRadius(10)
//                    .foregroundColor(.white)
//            }.padding(.bottom)
//            
//            Menu {
//                Picker(selection: $selectedIndexSorting,
//                       label: EmptyView(),
//                       content: {
//                        Text("asc")
//                        Text("desc")
//                }).pickerStyle(.automatic)
//                    .accentColor(.white)
//            } label: {
//                HStack {
//                    Image(systemName: "chevron.down")
//                    
//                    Text("asc")
//                    
//                }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.leading)
//                    .frame(height: 55)
//                    .background(Color.primaryBrand)
//                    .cornerRadius(10)
//                    .foregroundColor(.white)
//            }.padding(.bottom)
//            
//            
//        }.padding(.horizontal)
//    }
//}
//
//@ViewBuilder private func filterButtonView(title: String, action: @escaping () -> Void) -> some View {
//    Button(action: action) {
//        HStack {
//            Text("\(title)")
//                .lineLimit(1)
//            
//            Image(systemName: "chevron.down")
//        }.padding()
//            .frame(width: 140)
//    }.background(Color.primaryBrand)
//        .clipShape(Capsule())
//}


