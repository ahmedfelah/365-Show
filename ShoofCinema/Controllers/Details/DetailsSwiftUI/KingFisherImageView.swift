//
//  KingFisherImageView.swift
//  ShoofCinema
//
//  Created by mac on 4/28/23.
//  Copyright © 2023 AppChief. All rights reserved.
//


import SwiftUI
import struct Kingfisher.KFImage

@ViewBuilder
func KingFisherImageView(url: URL?) -> KFImage {
    KFImage(url)
}

