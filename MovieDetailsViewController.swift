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
    
    var movie: Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = String("\(movie.title) (\(movie.year))")
        synopsisLabel.text = movie.synopsis
        
        synopsisLabel.text =
            "Rating: \(movie.rating)\n" +
            "Runtime: \(movie.runtime) minutes\n" +
            "Release Date: \(movie.releaseDateTheater)\n\n" +
            "\(movie.synopsis)\n\n" +
            "Critics Say:\n\(movie.criticsRating as String!) (\(movie.criticsScore as Int!)% liked it)\n\n" +
            "Audiences Say\n\(movie.audienceRating as String!) (\(movie.audienceScore as Int!)% liked it)"
        synopsisLabel.sizeToFit()
        
        movieDetailView.frame = CGRectMake(movieDetailView.frame.origin.x, movieDetailView.frame.origin.y, movieDetailView.frame.width, synopsisLabel.frame.height + 70)

        let url = NSURL(string: movie.getHighQualityPoster())
        
        imageView.setImageWithURL(url!)
        
        self.title = movie.title
        // Do any additional setup after loading the view.
        scrollView.contentSize = CGSizeMake(scrollView.frame.width, movieDetailView.frame.origin.y + movieDetailView.frame.height)
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var totalBlurAlpha = scrollView.contentOffset.y / 200
        if (totalBlurAlpha > 1.0) {
            totalBlurAlpha = 1.0
        }
        blurEffectView.alpha = totalBlurAlpha
    }

}
