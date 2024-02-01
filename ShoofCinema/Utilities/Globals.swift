//
//  Globals.swift
//  SuperCell
//
//  Created by Husam Aamer on 3/30/19.
//  Copyright © 2019 AppChief. All rights reserved.
//

import UIKit
import SwiftUI


public extension String {
    
    // MARK:-  IDs
    static let cellID = "cellID"
    
    
    // MARK:-  GENERAL LOCALIZED MESSAGES
    static let genericErrorTitle = NSLocalizedString("genericErrorTitle", comment: "")
    static let genericErrorMessage = NSLocalizedString("genericErrorMessage", comment: "")
    static let noContentMessage = NSLocalizedString("noContentMessage", comment: "")
    static let noMatchesMessage = NSLocalizedString("noMatchesMessage", comment: "")
    static let tryAgainButtonTitle = NSLocalizedString("tryAgainButtonTitle", comment: "")
    
    static let allTitle = NSLocalizedString("allTitle", comment: "")
    
    // MARK:-  HAVLIY USED ICONS
    static let sadFaceIcon = "ic-no-error-icon"
}

extension Int {
    static let moviesCategoryId = 91
    static let seriesCategoryId = 92
}


let ResellersUrl = {
    [
        "http://reselller1.supercellnetwork.com/user/api/index.php/api/auth/autoLogin",
        "http://reseller1.supercellnetwork.com/user/api/index.php/api/auth/autoLogin",
        "http://reseller.scn-ftth.com/user/api/index.php/api/auth/autoLogin",
        "http://reseeller1.supercellnetwork.com/user/api/index.php/api/auth/autoLogin",
        "http://reseller2.supercellnetwork.com/user/api/index.php/api/auth/autoLogin",
        "http://reseller3.supercellnetwork.com/user/api/index.php/api/auth/autoLogin",
        "http://reseller4.supercellnetwork.com/user/api/index.php/api/auth/autoLogin"
        
    ]
    
}()

func baseUrl(url: String) -> URL? {
    guard let url = URL(string: url) else { return nil}
    
    var components = URLComponents()
    components.scheme = url.scheme
    components.host = url.host
    
    return components.url
}



var isOutsideDomain: Bool {
    !ShoofAPI.shared.isInNetwork
}
//var appPublished = false
var appPublished : Bool {
    let df = DateFormatter()
    df.dateFormat = "yyyy/MM/dd"
    let threshold = df.date(from: "2023/6/27")!
    let appleReviewPassed = Date().timeIntervalSince(threshold) > 0

    return appleReviewPassed || !isOutsideDomain
}

/// Holds the recommendation percents
var matchValues: [String:String] = [:]




struct Colors {
    static var tint           = UIColor(red: 0.83921569, green: 0.01568627, blue: 0.01568627, alpha: 1.00)
    static var darkGray       = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1.00)
    static var tabbar         = UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1.00)
    static var lightGray: UIColor {
        UIColor(red: 0.125, green: 0.125, blue: 0.125, alpha: 1.00)
    }

    
    static var pink: UIColor {
        UIColor(red: 255/255, green: 2/255, blue: 98/255, alpha: 1)
    }

    
    static var rating         = UIColor(red:1, green:0.77, blue:0.07, alpha:1) // Mikado yellow
    static var bright_tint    = UIColor(red:0.82, green:0.12, blue:0.27, alpha:1) // Bright maroon
    
    
    static var navbar         = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1) // Dark jungle green
    static var captions       = UIColor(red:0.67, green:0.67, blue:0.67, alpha:1) // Dark gray
    static var captionsDarker = UIColor(red:0.423, green:0.423, blue:0.423, alpha:1) // Dark gray 2
    static var text           = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1) // Isabelline
    static var pressed_area   = UIColor(red:0.11, green:0.11, blue:0.11, alpha:1) // Dark jungle green
    static var background     = UIColor(red:0, green:0, blue:0, alpha:1.00) //
    static var separator      = UIColor(red:0.217, green:0.217, blue:0.217, alpha:1.00)
    static var button         = UIColor(red:0.196, green:0.196, blue:0.196, alpha:1.00) //Gray
    
    //Used rarely
    static var yellow       = UIColor(red:1, green:197/255, blue:18/255, alpha:1.00) //Yellow
    static var orange       = UIColor(red:1, green:163/255, blue:59/255, alpha:1.00) //Yellow
    
    
}

//SwiftUI Theme
extension Color {
    static var  primaryBrand = Color("primary-brand")
    static var secondaryBrand = Color("secondary-brand")
    static var tertiaryBrand = Color("tertiary-brand")
    static var primaryText = Color("primary-text")
    static var secondaryText = Color("secondary-text")
    
}
enum Fonts {
    static func almaraiExtraBold (_ fontSize:CGFloat = 17) -> UIFont {
        return UIFont(name: "Almarai-ExtraBold", size: fontSize)!
    }
    
    static func almaraiBold (_ fontSize:CGFloat = 17) -> UIFont {
        return UIFont(name: "Almarai-Bold", size: fontSize)!
    }
    static func almaraiLight (_ fontSize:CGFloat = 17) -> UIFont {
        return UIFont(name: "Almarai-Light", size: fontSize)!
    }
    static func almarai (_ fontSize:CGFloat = 17) -> UIFont {
        return UIFont(name: "Almarai-Regular", size: fontSize)!
    }
    
    
    static func myriad (_ fontSize:CGFloat = 16) -> UIFont {
        return UIFont(name: "MyriadPro-Bold", size: fontSize)!
    }
}
