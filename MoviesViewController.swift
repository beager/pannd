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
    @IBOutlet weak var errorView: UIView!

    // Top Box Office URL
    let boxOfficeUrl = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")!
    
    // Top DVD Rentals URL
    let topDvdUrl = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/e41513a57049e21bc6cf/raw/b490e79be2d21818f28614ec933d5d8f467f0a66/gistfile1.json")!
    
    // The current data source URL
    var currentDataSourceUrl: NSURL?
    
    // The last selected TabBar index, to make sure we don't load when you tap what's already selected
    var lastSelectedTabBarIndex: Int?
    
    // The full list of movies
    var movies: [NSDictionary]?
    
    // The filtered list of movies, for search filtering
    var filteredMovies: [NSDictionary]?
    
    // UIRefreshControl
    var refreshControl: UIRefreshControl!
    
    // A UITapGestureRecognizer to assist with search dismissal
    var tapTableViewGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize movies and filteredMovies
        movies = []
        filteredMovies = []
        
        // Default data source to boxOfficeUrl and tab bar index
        // TODO: programmatically set this by examining UITabBar state?
        currentDataSourceUrl = boxOfficeUrl
        lastSelectedTabBarIndex = 0
        tabBar.selectedItem = topBoxOfficeTabBarItem
        
        // Set a whole lot of sources and delegates to self
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        tabBar.delegate = self
        
        // Add refresh control to the tableView
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh...", attributes: [NSForegroundColorAttributeName: UIColor.orangeColor()])
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex:0)
        
        // Add tap gesture recognizer to dismiss search when interacting with the results
        tapTableViewGesture = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard"))
        tapTableViewGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapTableViewGesture)
        
        // Set loader state and load data
        SwiftLoader.show(title: "Loading...", animated: true)
        self.loadData()
    }
    
    // action triggered by UITapGestureRecognizer
    func hideKeyboard() {
        tableView.endEditing(true)
    }
    
    // Loads data
    func loadData() {
        let request = NSURLRequest(URL: currentDataSourceUrl!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 30.0)

        // Hide the error view if it was shown
        errorView.hidden = true
        
        // Make the call
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if ((error) != nil) {
                // Error loading, hide the loader and show the error view
                SwiftLoader.hide()
                self.errorView.hidden = false
            } else {
                // Everything was good, unpack the JSON
                let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
                if let json = json {
                    self.movies = json["movies"] as? [NSDictionary]
                    self.filteredMovies = self.movies
                }
            }
            // End refreshing and reload table view
            self.refreshControl.endRefreshing()
            self.reloadTableViewIfDataExists()
        }
    }
    
    // Delay function I got from somewhere, used to delay setting vars
    func delay(delay: Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ), dispatch_get_main_queue(), closure)
    }
    
    // When refresh is triggered, change the title and load the data
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

    // numberOfRowsInSection
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
        
        // Instantiate model
        let movie = Movie(movie: filteredMovies![indexPath.row])
        
        cell.frame = CGRectMake(0, 0, 300.0, 300.0)
        
        // Set labels and UIImageView
        cell.titleLabel.text = movie.title
        cell.synopsisLabel.text = movie.synopsis
        cell.posterView.image = UIImage()
        
        // Load thumbnail image here
        let url = NSURL(string: movie.poster)
        
        // Success callback
        let imageRequestSuccess = {
            (request : NSURLRequest!, response : NSHTTPURLResponse!, image : UIImage!) -> Void in
            cell.posterView.image = image;
            cell.posterView.alpha = 0
            UIView.animateWithDuration(0.4, animations: {
                cell.posterView.alpha = 1.0
            })
        }
        
        // Failure callback
        let imageRequestFailure = {
            (request : NSURLRequest!, response : NSHTTPURLResponse!, error : NSError!) -> Void in
            NSLog("imageRequestFailure")
        }

        // Execute the call
        cell.posterView.setImageWithURLRequest(NSURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 30.0), placeholderImage: nil, success: imageRequestSuccess, failure: imageRequestFailure)
        
        // If we've loaded a viewport worth of data, dismiss the loader
        if (indexPath.row == tableView.indexPathsForVisibleRows()?.last?.row) {
            SwiftLoader.hide()
        }
        
        // Custom select state for cell
        var bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.orangeColor()
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }

    // Deselect active row on tap
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // When tabBar item selection happens
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        // If no change, return
        if (item.tag == lastSelectedTabBarIndex) {
            return
        }
        
        // Set the proper data source
        if (item.tag == 0) {
            currentDataSourceUrl = boxOfficeUrl
        } else if (item.tag == 1) {
            currentDataSourceUrl = topDvdUrl
        }

        // Do some reloading stuff
        filteredMovies = []
        reloadTableViewIfDataExists()
        searchBar.text = ""
        SwiftLoader.show(title: "Loading...", animated: true)
        loadData()
        
        // Set title of this view to be the title of whichever item you selected
        self.title = item.title
        lastSelectedTabBarIndex = item.tag
    }
    
    // Callback on text change in Search
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
    }
    
    // Reloads the table view if data exists, or shows the no results view
    func reloadTableViewIfDataExists() {
        if (self.filteredMovies?.isEmpty == true) {
            noResultsView.hidden = false
        } else {
            noResultsView.hidden = true
            self.tableView.reloadData()
        }
    }
    
    // Filters search content
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
    
    // Callback on end editing for search
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        // Have to delay here or the touch will be picked up by the tableView and respond
        // TODO: Not do this?
        delay(0.1, closure: {
            self.tapTableViewGesture.cancelsTouchesInView = false
        })
    }
    
    // Callback on start editing for search
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        tapTableViewGesture.cancelsTouchesInView = true
    }
}
