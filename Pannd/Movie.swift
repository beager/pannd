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
    var rating: String
    var audienceRating: String?
    var audienceScore: Int?
    var criticsRating: String?
    var criticsScore: Int?
    var releaseDateTheater: String
    var runtime: Int
    var year: Int
    
    init(movie: NSDictionary) {
        self.title = (movie["title"] as? String)!
        self.poster = (movie.valueForKeyPath("posters.thumbnail") as? String)!
        self.synopsis = (movie["synopsis"] as? String)!
        self.rating = (movie["mpaa_rating"] as? String)!
        self.audienceRating = movie.valueForKeyPath("ratings.audience_rating") as? String
        self.audienceScore = movie.valueForKeyPath("ratings.audience_score") as? Int
        self.criticsRating = movie.valueForKeyPath("ratings.critics_rating") as? String
        self.criticsScore = movie.valueForKeyPath("ratings.critics_score") as? Int
        self.releaseDateTheater = (movie.valueForKeyPath("release_dates.theater") as? String)!
        self.runtime = (movie["runtime"] as? Int)!
        self.year = (movie["year"] as? Int)!
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
