//
//  Language.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/26/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import Foundation
final class Language {
    class func isEnglish() -> Bool {
        if Locale.current.languageCode == "en" { return true }
        else { return false }
    }
}
