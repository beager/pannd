//
//  MoviesViewController.swift
//  Pannd
//
//  Created by Bill Eager on 8/29/15.
//  Copyright (c) 2015 Bill Eager. All rights reserved.
//

import UIKit
import SwiftLoader
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let boxOfficeUrl = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")!
    
    let topDvdUrl = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/e41513a57049e21bc6cf/raw/b490e79be2d21818f28614ec933d5d8f467f0a66/gistfile1.json")!
    
    var currentDataSourceUrl: NSURL?
    
    var lastSelectedTabBarIndex: Int?

    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var topBoxOfficeTabBarItem: UITabBarItem!
    @IBOutlet weak var topDvdRentalsTabBarItem: UITabBarItem!
    
    var movies: [NSDictionary]?
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentDataSourceUrl = boxOfficeUrl
        lastSelectedTabBarIndex = 0
        tableView.dataSource = self
        tableView.delegate = self
        
        tabBar.delegate = self
        // Do any additional setup after loading the view.
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex:0)

        SwiftLoader.show(title: "Loading...", animated: true)
        self.loadData()
        
        tabBar.selectedItem = topBoxOfficeTabBarItem
    }
    
    func loadData() {
        let request = NSURLRequest(URL: currentDataSourceUrl!)

        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            self.delay(1, closure: {
                let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
                if let json = json {
                    self.movies = json["movies"] as? [NSDictionary]
                    self.tableView.reloadData()
                }
                
                SwiftLoader.hide()
                self.refreshControl.endRefreshing()
            })

            
        }
    }
    
    func delay(delay: Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ), dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        self.loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = Movie(movie: movies![indexPath!.row])
        
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = Movie(movie: movies![indexPath.row])
        
        cell.titleLabel.text = movie.title
        cell.synopsisLabel.text = movie.synopsis
        cell.posterView.image = UIImage()
        
        let url = NSURL(string: movie.getHighQualityPoster())
        
        let imageRequestSuccess = {
            (request : NSURLRequest!, response : NSHTTPURLResponse!, image : UIImage!) -> Void in
            cell.posterView.image = image;
            cell.posterView.alpha = 0
            UIView.animateWithDuration(0.4, animations: {
                cell.posterView.alpha = 1.0
            })
        }
        let imageRequestFailure = {
            (request : NSURLRequest!, response : NSHTTPURLResponse!, error : NSError!) -> Void in
            NSLog("imageRequestFailure")
        }

        cell.posterView.setImageWithURLRequest(NSURLRequest(URL: url!), placeholderImage: nil, success: imageRequestSuccess, failure: imageRequestFailure)
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        if (item.tag == lastSelectedTabBarIndex) {
            return
        }
        if (item.tag == 0) {
            currentDataSourceUrl = boxOfficeUrl
        } else if (item.tag == 1) {
            currentDataSourceUrl = topDvdUrl
        }
        movies = []
        tableView.reloadData()
        SwiftLoader.show(title: "Loading...", animated: true)
        loadData()
        lastSelectedTabBarIndex = item.tag
    }
}
