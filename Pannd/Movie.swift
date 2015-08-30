//
//  Movie.swift
//  Pannd
//
//  Created by Bill Eager on 8/30/15.
//  Copyright (c) 2015 Bill Eager. All rights reserved.
//

import Foundation

class Movie {
    // MARK: Properties
    
    var title: String
    var poster: String
    var synopsis: String
    
    init(movie: NSDictionary) {
        self.title = (movie["title"] as? String)!
        self.poster = (movie.valueForKeyPath("posters.thumbnail") as? String)!
        self.synopsis = (movie["synopsis"] as? String)!
    }
    
    func getHighQualityPoster() -> String {
        var range = self.poster.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            let url = self.poster.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
            return url
        }
        return ""
    }
}
