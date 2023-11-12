//
//  LanguageHelper.swift
//  Qi Mobile Bank
//
//  Created by Abdulla Jafar on 11/22/20.
//  Copyright © 2020 Enjaz Mac. All rights reserved.
//

import Foundation
import UIKit

class LanguageHelper : NSObject {
    
    var codes : [String] = []
    var localizedList : [String] = []
    var currentLanguage = "en"
    
    // MARK: - INIT
    public override init() {
        var codes = Bundle.main.localizations        
        codes = codes.uniques
        if let indexOfBase  = codes.firstIndex(of: "Base") {
            codes.remove(at: indexOfBase)
        }
        if let indexAR  = codes.firstIndex(of: "ar-IQ") {
            codes[indexAR] = "ar"
        }
        self.codes = codes
        self.localizedList = codes.map { NSLocalizedString($0, comment: "") }
        print("nknknk", self.localizedList)
        
    }
    
    public func getSelectedLanguageCode () -> String {
        return Locale.current.languageCode ?? "en"
    }
    
    public func changeLanguageForIOS13 () {
        let url = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(url)
    }
    
    public func changeLanguageForIOS12(languageCode : String) {
        UserDefaults.standard.set(languageCode, forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }

}

extension String {
	var localized: String {
		NSLocalizedString(self, comment: "")
	}
}
