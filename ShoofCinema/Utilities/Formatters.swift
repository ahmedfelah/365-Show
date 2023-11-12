//
//  Formatters.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 2/28/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import Foundation

extension Double {
    func truncate(places: Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}



extension Int {
    
    func  getFormattedViewsNumber () -> String {
        let n = self
        let num = abs(Double(n))
        let sign = (n < 0) ? "-" : ""
        
        switch num {
            
        case 1_000_000_000...:
            var formatted = num / 1_000_000_000
            formatted = formatted.truncate(places: 1)
            return "\(sign)\(formatted)B"
            
        case 1_000_000...:
            var formatted = num / 1_000_000
            formatted = formatted.truncate(places: 1)
            return "\(sign)\(formatted)M"
            
        case 1_000...:
            var formatted = num / 1_000
            formatted = formatted.truncate(places: 1)
            return "\(sign)\(formatted)K"
            
        case 0...:
            return "\(n)"
            
        default:
            return "\(sign)\(n)"
            
        }
    }

}


public extension String {
    
    func getFormattedIMDBRating () -> String {
        let rating = Float(self) ?? 0.0
        return rating.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", rating) : String(rating)
        
    }
    
    
    func getFormattedDate(fromFormate formate : String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formate
        let date = dateFormatter.date(from: String(self) )
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter.string(from: date ?? Date())
    }
}


public extension Float {
    
    func getFormattedIMDBRating () -> String {
        let f = NumberFormatter()
        f.locale = Locale(identifier: "en")
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 1
        return f.string(for: self) ?? ""
    }
}


