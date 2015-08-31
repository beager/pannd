//
//  MovieDetailsViewController.swift
//  Pannd
//
//  Created by Bill Eager on 8/29/15.
//  Copyright (c) 2015 Bill Eager. All rights reserved.
//

import UIKit
import AFNetworking

class MovieDetailsViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var movieDetailView: UIView!
    @IBOutlet weak var synopsisLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    
    // The movie model passed to this view
    var movie: Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set text labels
        titleLabel.text = String("\(movie.title) (\(movie.year))")
        synopsisLabel.text =
            "Rating: \(movie.rating)\n" +
            "Runtime: \(movie.runtime) minutes\n" +
            "Release Date: \(movie.releaseDateTheater)\n\n" +
            "\(movie.synopsis)\n\n" +
            "Critics Say:\n\(movie.criticsRating as String!) (\(movie.criticsScore as Int!)% liked it)\n\n" +
            "Audiences Say\n\(movie.audienceRating as String!) (\(movie.audienceScore as Int!)% liked it)"
        // Fit it all
        synopsisLabel.sizeToFit()
        
        // Do some fun math to frame the movieDetailView to match the title and synopsis labels
        movieDetailView.frame = CGRectMake(movieDetailView.frame.origin.x, movieDetailView.frame.origin.y, movieDetailView.frame.width, synopsisLabel.frame.height + 70)

        // Load the low-res URL which should be cached already
        let lowResUrl = NSURL(string: movie.poster)
        imageView.setImageWithURL(lowResUrl!)
        
        // Upgrade it to the high quality poster
        let url = NSURL(string: movie.getHighQualityPoster())
        imageView.setImageWithURL(url!)
        
        // Set title of this view
        self.title = movie.title

        // Set the scrollview content size to include everything from the top of the screen to the end of the movieDetailView content.
        // This is to make it so you can pull the description and details up.
        scrollView.contentSize = CGSizeMake(scrollView.frame.width, movieDetailView.frame.origin.y + movieDetailView.frame.height)
        
        // Set scrollview delegate so we can intercept the scroll event
        scrollView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Fires when scroll view does scroll
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // This is neat, as you scroll the description up, there's a blur effect view atop the big poster image
        // that gets "stronger" (i.e. more opaque).
        // This means that as you scroll up, the poster image blurs so you can read the text.
        var totalBlurAlpha = scrollView.contentOffset.y / 200
        if (totalBlurAlpha > 1.0) {
            totalBlurAlpha = 1.0
        }
        blurEffectView.alpha = totalBlurAlpha
    }

}
