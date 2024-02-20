//
//  SettingsView.swift
//  ShoofCinema
//
//  Created by mac on 7/8/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @State var toggle = false
    
    @AppStorage("language") var language: String = "en"
    @AppStorage("colorScheme") var colorScheme: ColorScheme = .dark
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Account Settings")
                    .bold()
                    .padding()
                
                Text("Content Filter Mode")
                    .padding([.bottom, .leading, .trailing])
                    .font(.caption)
                
                HStack(spacing: 10) {
                    VStack(spacing: 0) {
                        Image(systemName: "circle.grid.2x2")
                            .imageScale(.large)
                            .padding([.bottom, .leading, .trailing])
                        
                        Text("All")
                            .bold()
                    }.frame(width: 80)
                        .padding(.vertical)
                        .background(Color.primaryBrand)
                        .cornerRadius(10)
                    
                    VStack(spacing: 0) {
                        Image(systemName: "checkmark.shield")
                            .imageScale(.large)
                            .padding([.bottom, .leading, .trailing])
                        
                        Text("Default")
                            .bold()
                    }.frame(width: 80)
                        .padding(.vertical)
                        .background(Color.primaryBrand)
                        .cornerRadius(10)
                    
                    VStack(spacing: 0) {
                        Image(systemName: "person.3")
                            .imageScale(.large)
                            .padding([.bottom, .leading, .trailing])
                        
                        Text("Family")
                            .bold()
                    }.frame(width: 80)
                        .padding(.vertical)
                        .background(.white)
                        .foregroundColor(.primaryBrand)
                        .cornerRadius(10)
                    
                    VStack(spacing: 0) {
                        Image(systemName: "face.smiling.fill")
                            .imageScale(.large)
                            .padding([.bottom, .leading, .trailing])
                        
                        Text("Kids")
                            .bold()
                    }.frame(width: 80)
                        .padding(.vertical)
                        .background(Color.primaryBrand)
                        .cornerRadius(10)
                }.font(.caption)
                    .padding(.horizontal)
                
                Toggle("Skip Inappropriate SCENES", isOn: $toggle)
                    .toggleStyle(SymbolToggleStyle(systemImage: "circle", activeColor: .green))
                
                Toggle("Enable Non Translation Items", isOn: $toggle)
                    .toggleStyle(SymbolToggleStyle(systemImage: "circle", activeColor: .green))
                    .padding(.bottom)
                
                Text("App Settings")
                    .padding()
                
                HStack {
                    Text("Clear Search History")
                        .font(.caption)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Text("Clear data")
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .font(.caption)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.tertiaryBrand, lineWidth: 1)
                            )
                    }
                }.padding()
                
                
                Group {
                    Text("Language")
                        .padding([.top, .leading])
                        .font(.caption)
                    
                    HStack {
                        Button(action: {language = "ar"}) {
                            Text("Arabic")
                                .padding(10)
                                .background(language == "ar" ? Color.tertiaryBrand : Color.primaryBrand)
                                .foregroundColor(language == "ar" ? Color.secondaryText: Color.primaryText)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {language = "en"}) {
                            Text("English")
                                .padding(10)
                                .background(language == "en" ? Color.tertiaryBrand : Color.primaryBrand)
                                .foregroundColor(language == "en" ? Color.secondaryText: Color.primaryText)
                                .cornerRadius(10)
                        }

                    }.padding(.horizontal)
                }
                
                
                Group {
                    Text("Mode")
                        .padding([.top, .leading])
                        .font(.caption)
                    
                    HStack {
                        Button(action: {colorScheme = .light}) {
                            Image(systemName: "sun.max")
                            
                            Text("Light")
                                
                        }.padding(10)
                            .foregroundColor(colorScheme == .light ? Color.secondaryText : Color.primaryText)
                            .background(colorScheme == .light ? Color.tertiaryBrand : Color.primaryBrand)
                            .cornerRadius(10)
                        
                        Button(action: {colorScheme = .dark}) {
                            HStack {
                                Image(systemName: "moon.fill")
                                
                                Text("Dark")
                                
                            }.padding(10)
                                .foregroundColor(colorScheme == .dark ? Color.secondaryText : Color.primaryText)
                                .background(colorScheme == .dark ? Color.tertiaryBrand : Color.primaryBrand)
                                .cornerRadius(10)
                        }

                    }.padding(.horizontal)

                }
                    
                }.frame(maxWidth: .infinity, alignment: .leading)
                
                
        }.background(Color.primaryBrand)
            .buttonStyle(.plain)
            .navigationTitle("Settings")
        }
    }
    
    struct SettingsView_Previews: PreviewProvider {
        static var previews: some View {
            SettingsView()
        }
    }
    
    
    
    struct SymbolToggleStyle: ToggleStyle {
        
        var systemImage: String = "checkmark"
        var activeColor: Color = .green
        
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(configuration.isOn ? activeColor : Color(.systemGray5))
                    .overlay {
                        Circle()
                            .fill(.white)
                            .padding(3)
                            .offset(x: configuration.isOn ? 10 : -10)
                        
                    }
                    .frame(width: 50, height: 32)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            configuration.isOn.toggle()
                        }
                    }.padding()
                
                configuration.label
                
                
                
            }
        }
    }
