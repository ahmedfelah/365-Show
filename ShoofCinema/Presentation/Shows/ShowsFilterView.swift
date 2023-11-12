//
//  ShowsFilterView.swift
//  ShoofCinema
//
//  Created by mac on 7/30/23.
//  Copyright © 2023 AppChief. All rights reserved.
//


import SwiftUI

struct ShowsFilterView: View {
    
    @StateObject var viewModel: ShowViewModel
    
    @State private var selectedIndexYear = 0
    @State private var selectedIndexGenre: Int = 0
    @State private var selectedIndexSorting: Int = 0
    
    @State var isOpenYearDropdownMenu: Bool = false
    @State var isOpenGenreDropdownMenu: Bool = false
    @State var isOpenSortingDropdownMenu: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {}) {
                    Text("Movies")
                        .font(.caption)
                        .foregroundColor(.white)
                        .bold()
                        .padding()
                        .frame(minWidth: 80)
                        .overlay {
                            Capsule(style: .continuous)
                                .stroke(.white, lineWidth: 1)
                        }
                    
                }
                    .padding()
                
                Button(action: {}) {
                    Text("TV Shows")
                        .font(.caption)
                        .foregroundColor(.white)
                        .bold()
                        .padding()
                        .frame(minWidth: 80)
                        
                }
                    .padding()
            }
            
            HStack(alignment: .top) {
                Menu {
                    Picker(selection: $selectedIndexGenre,
                           label: EmptyView(),
                           content: {
                        ForEach(viewModel.allGenres.indices, id: \.self) { index in
                            Text(viewModel.allGenres[index].localizedString)
                        }
                    }).pickerStyle(.automatic)
                        .accentColor(.white)
                } label: {
                    HStack {
                        Image(systemName: "chevron.down")
                        
                        Text(viewModel.allGenres[selectedIndexGenre].localizedString)
                        
                    }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                        .frame(height: 55)
                        .background(Color.primaryBrand)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }.padding(.bottom)
                
                Menu {
                    Picker(selection: $selectedIndexYear,
                           label: EmptyView(),
                           content: {
                        Text("Upload date")
                        Text("Release date")
                        Text("English title")
                        Text("Arabic title")
                        Text("Views")
                        Text("Parental Rating")
                        Text("IMDB Rating")
                    }).pickerStyle(.automatic)
                        .accentColor(.white)
                } label: {
                    HStack {
                        Image(systemName: "chevron.down")
                        
                        Text("Upload date")
                        
                    }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                        .frame(height: 55)
                        .background(Color.primaryBrand)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }.padding(.bottom)
                
                Menu {
                    Picker(selection: $selectedIndexSorting,
                           label: EmptyView(),
                           content: {
                            Text("asc")
                            Text("desc")
                    }).pickerStyle(.automatic)
                        .accentColor(.white)
                } label: {
                    HStack {
                        Image(systemName: "chevron.down")
                        
                        Text("asc")
                        
                    }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                        .frame(height: 55)
                        .background(Color.primaryBrand)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }.padding(.bottom)
                
                
            }.padding(.horizontal)
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


