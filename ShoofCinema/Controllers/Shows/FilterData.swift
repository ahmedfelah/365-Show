//
//  FilterData.swift
//  ShoofCinema
//
//  Created by Abdulla Jafar on 3/12/21.
//  Copyright © 2021 AppChief. All rights reserved.
//

import Foundation


struct Sort {
    enum SortingValue : String {
        case year = "year"
        case rating = "rate"
        case views = "watched"
        case upload = "upload"
        
    }
    enum SortingTypeValue : String {
        case ascending = "asc"
        case descending  = "desc"
    }
    
    let displayName : String
    let value : SortingValue?
    let typeValue : SortingTypeValue?
}


let sortData : [Sort] = [
    Sort(displayName: .allTitle, value: nil, typeValue: nil),
    Sort(displayName: .sortRatingDescending, value: .rating, typeValue: .descending),
   //Sort(displayName: .sortRatingAscending, value: .rating, typeValue: .ascending),
    
    Sort(displayName: .sortViewsDescending, value: .views, typeValue: .descending),
    //Sort(displayName: .sortViewsAscending, value: .views, typeValue: .ascending),
    
    Sort(displayName: .sortYearDescending, value: .year, typeValue: .descending),
    //Sort(displayName: .sortYearAscending, value: .year, typeValue: .ascending)
    
    Sort(displayName: .sortViewsDescending, value: .upload, typeValue: .descending)
]


//let genreData : [String] = [
//    .allTitle,
//    "Comedy",
//    "Crime",
//    "Thriller",
//    "Biography",
//    "War",
//    "Adventure",
//    "Family",
//    "Fantasy",
//    "Mystery",
//    "Sport",
//    "Action",
//    "Horror",
//    "Romance",
//    "Drama",
//    "History",
//    "Film-Noir",
//    "Musical",
//    "Sci-Fi",
//    "Documentary",
//    "Animation",
//    //"N/A",
//    "Western",
//    "Short",
//    "Reality-TV",
//    "News",
//    "Talk-Show"
//]

var genreData: [String] {
    [.allTitle] + ShoofAPI.Genre.allGenres.map(\.name)
}

//var genreData: [String] {
//    [.allTitle] + ShoofAPI.Category.allCategories.compactMap(\.name)
//}

var yearData : [String] {
    let currentDate = Date()
    let calendar = Calendar.current
    let currentYear = calendar.component(.year, from: currentDate)
    var years = (1900...currentYear).map { String($0) }
    years.append(.allTitle)
    return years.reversed()
}


var mainCategoriesData:[SCCategory] = []

var fullCategoriesData:[SCCategory]? {
    
    var categories = [SCCategory]()
    
    for category in mainCategoriesData {
        categories.append(category)
        category.subcategories.forEach {
            categories.append($0)
        }
    }
    
    categories.insert(SCCategory(id: .moviesCategoryId, title: .allTitle), at: 0)
    return categories
}


fileprivate extension String {
    


    // SORT TITLES
    static let sortRatingDescending = NSLocalizedString("sortRatingDescending", comment: "")
    static let sortRatingAscending = NSLocalizedString("sortRatingAscending", comment: "")
    
    static let sortViewsDescending = NSLocalizedString("viewsDescending", comment: "")
    static let sortViewsAscending = NSLocalizedString("viewsAscending", comment: "")
    
    static let sortYearDescending = NSLocalizedString("sortYearDescending", comment: "")
    static let sortYearAscending = NSLocalizedString("sortYearAscending", comment: "")
    
    static let sortUploadDescending = NSLocalizedString("sortUploadDescending", comment: "")
    static let sortUploadAscending = NSLocalizedString("sortUploadAscending", comment: "")

    static let genreComedy = NSLocalizedString("genreComedy", comment: "")
    static let genreCrime = NSLocalizedString("genreCrime", comment: "")
    static let genreThriller = NSLocalizedString("genreThriller", comment: "")
    static let genreBiography = NSLocalizedString("genreBiography", comment: "")
    static let genreWar = NSLocalizedString("genreWar", comment: "")
    static let genreAdventure = NSLocalizedString("genreAdventure", comment: "")
    static let genreFamily = NSLocalizedString("genreFamily", comment: "")
    static let genreFantasy = NSLocalizedString("genreFantasy", comment: "")
    static let genreMystery = NSLocalizedString("genreMystery", comment: "")
    static let genreSport = NSLocalizedString("genreSport", comment: "")
    static let genreAction = NSLocalizedString("genreAction", comment: "")
    static let genreHorror = NSLocalizedString("genreHorror", comment: "")
    static let genreRomance = NSLocalizedString("genreRomance", comment: "")
    static let genreDrama = NSLocalizedString("genreDrama", comment: "")
    static let genreHistory = NSLocalizedString("genreHistory", comment: "")
    static let genreFilmNoir = NSLocalizedString("genreFilm-Noir", comment: "")
    static let genreMusical = NSLocalizedString("genreMusical", comment: "")
    static let genreSciFi = NSLocalizedString("genreSci-Fi", comment: "")
    static let genreDocumentary = NSLocalizedString("genreDocumentary", comment: "")
    static let genreAnimation = NSLocalizedString("genreAnimation", comment: "")
    static let genreNA = NSLocalizedString("genreN/A", comment: "")
    static let genreWestern = NSLocalizedString("genreWestern", comment: "")
    static let genreShort = NSLocalizedString("genreShort", comment: "")
    static let genreRealityTV = NSLocalizedString("genreReality-TV", comment: "")
    static let genreNews =  NSLocalizedString("genreNews", comment: "")
    static let genreTalkShow = NSLocalizedString("genreTalk-Show", comment: "")
}
