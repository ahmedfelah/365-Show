//
//  FilterSearchView.swift
//  ShoofCinema
//
//  Created by mac on 7/26/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct FilterSearchView: View {
    
    @StateObject var viewModel: SearchViewModel
    
    @Environment(\.dismiss) var dismiss
    
    let min: CGFloat = 0
    let max: CGFloat = 10
    let step: CGFloat = 1
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Button(action: {dismiss()}, label: {
                        Image(systemName: "xmark")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    })
                    
                    Text("Filter Results")
                        .bold()
                        .frame(maxWidth: .infinity)
   
                    Button(action: {
                        viewModel.clearAll()
                    }, label: {
                        Text("Clear all")
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(.secondaryBrand)
                        
                            
                    })
                }.padding(.vertical)
                
                Text("Year")
                
                HStack {
                    Picker(selection: $viewModel.fromYearSelectedIndex,
                           label: EmptyView(),
                           content: {
                        ForEach(viewModel.allYears.indices, id: \.self) { index in
                            Text("\(viewModel.allYears[index])")
                        }
                    }).pickerStyle(.wheel)
                        .accentColor(.white)
                        .labelsHidden()
                    
                    
                    
                    Text("To")
                    
                    Picker(selection: $viewModel.toYearSelectedIndex,
                           label: EmptyView(),
                           content: {
                        ForEach(viewModel.allYearsReversed.indices, id: \.self) { index in
                            Text(viewModel.allYearsReversed[index])
                        }
                    }).pickerStyle(.wheel)
                        .accentColor(.white)
                }.frame(height: 130)
                    .clipped()
                
                Text("Category")
                    .padding(.top)
                Menu {
                    Picker(selection: $viewModel.genreSelectedIndex,
                           label: EmptyView(),
                           content: {
                        ForEach(viewModel.allGenres.indices, id: \.self) { index in
                            Text("\(viewModel.allGenres[index].name)")
                        }
                    }).pickerStyle(.automatic)
                        .accentColor(.white)
                } label: {
                    HStack {
                        Image(systemName: "chevron.down")
                        
                        Text("\(viewModel.allGenres[viewModel.genreSelectedIndex].name)")
                        
                    }.font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                        .frame(height: 55)
                        .background(Color.primaryBrand)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }.padding(.bottom)
                
                Text("IMDB Rating - \(Int(viewModel.rate)) -")
                    .padding(.vertical)
                
                Slider(
                    value: $viewModel.rate,
                    in: min...max,
                    step: step,
                    minimumValueLabel: Text(formated(value: min)),
                    maximumValueLabel: Text(formated(value: max)),
                    label: { })
                    .accentColor(.white)
                    .padding(.bottom)
                
                Text("Staff")
                
                TextField("", text: $viewModel.actors, axis: .vertical)
                    .padding()
                    .background(Color.primaryBrand)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .lineLimit(2)
                    .padding(.bottom)
                    
                
                Button(action: {
                    viewModel.updateShows()
                    dismiss()
                }, label: {
                    Text("Show Result")
                }).font(.title3)
                    .frame(maxWidth: .infinity)
                    .padding(.leading)
                    .fontWeight(.semibold)
                    .frame(height: 55)
                    .background(Color.secondaryBrand)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .padding(.vertical)
            }.buttonStyle(.plain)
                .padding(.horizontal)
        }.background(Color.primaryBrand)
    }
    
    private func formated(value: CGFloat) -> String {
        return String(format: "%.0f", value)
    }
}

