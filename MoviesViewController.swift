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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noResultsView: UIView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var topBoxOfficeTabBarItem: UITabBarItem!
    @IBOutlet weak var topDvdRentalsTabBarItem: UITabBarItem!
    @IBOutlet weak var searchBar: UISearchBar!

    let boxOfficeUrl = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")!
    
    let topDvdUrl = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/e41513a57049e21bc6cf/raw/b490e79be2d21818f28614ec933d5d8f467f0a66/gistfile1.json")!
    
    var currentDataSourceUrl: NSURL?
    
    var lastSelectedTabBarIndex: Int?
    
    var movies: [NSDictionary]?
    
    var filteredMovies: [NSDictionary]?
    
    var refreshControl: UIRefreshControl!
    
    var tapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentDataSourceUrl = boxOfficeUrl
        lastSelectedTabBarIndex = 0
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        tabBar.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh...", attributes: [NSForegroundColorAttributeName: UIColor.orangeColor()])
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex:0)

        SwiftLoader.show(title: "Loading...", animated: true)
        self.loadData()
        
        tabBar.selectedItem = topBoxOfficeTabBarItem
        
        tapGesture = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard"))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }
    
    func hideKeyboard() {
        tableView.endEditing(true)
    }
    
    func loadData() {
        let request = NSURLRequest(URL: currentDataSourceUrl!)

        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            self.delay(1, closure: {
                let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
                if let json = json {
                    self.movies = json["movies"] as? [NSDictionary]
                    self.filteredMovies = self.movies
                    self.reloadTableViewIfDataExists()
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
        refreshControl.attributedTitle = NSAttributedString(string: "Loading data...", attributes: [NSForegroundColorAttributeName: UIColor.orangeColor()])
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
        let movie = Movie(movie: filteredMovies![indexPath!.row])
        
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        } else {
            return 0
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = Movie(movie: filteredMovies![indexPath.row])
        
        cell.frame = CGRectMake(0, 0, 300.0, 300.0)
        
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
        filteredMovies = []
        reloadTableViewIfDataExists()
        searchBar.text = ""
        SwiftLoader.show(title: "Loading...", animated: true)
        loadData()
        self.title = item.title
        lastSelectedTabBarIndex = item.tag
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
    }
    
    func reloadTableViewIfDataExists() {
        if (self.filteredMovies?.isEmpty == true) {
            noResultsView.hidden = false
        } else {
            noResultsView.hidden = true
            self.tableView.reloadData()
        }
    }
    
    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        if (searchText == "") {
            self.filteredMovies = self.movies
        } else {
            self.filteredMovies = self.movies!.filter({( movie: NSDictionary) -> Bool in
                let stringMatch = movie["title"]!.rangeOfString(searchText)
                return stringMatch.length > 0
            })
        }
        reloadTableViewIfDataExists()
    }
    
    // MARK: UISearchBarDelegate methods
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        delay(0.1, closure: {
            self.tapGesture.cancelsTouchesInView = false
        })
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        tapGesture.cancelsTouchesInView = true
    }
}
