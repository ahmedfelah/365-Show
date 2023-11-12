//
//  RateHomeHeader.swift
//  ShoofCinema
//
//  Created by mac on 2/9/23.
//  Copyright © 2023 AppChief. All rights reserved.
//

import SwiftUI

struct RateHomeHeader: View {
    
    @State var rate: Int = 0
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                ForEach(0...5, id: \.self) { index in
                    if rate > index {
                        Image(systemName: "star")
                    }
                    
                    else {
                        Image(systemName: "star.fill")
                    }
                }
            }
        }
    }
}

struct RateHomeHeader_Previews: PreviewProvider {
    static var previews: some View {
        RateHomeHeader()
    }
}
