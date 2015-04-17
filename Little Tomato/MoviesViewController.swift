//
//  MoviesViewController.swift
//  Little Tomato
//
//  Created by Holly French on 4/15/15.
//  Copyright (c) 2015 Holly French. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var networkErrorView: UIView!
    
    var refreshControl: UIRefreshControl!
    var movies: [NSDictionary]?
    var filtered: [NSDictionary] = []
    var searchActive: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SVProgressHUD.show()
        loadAllMovies()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Loading movies...")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black // 37 111 18
        nav?.tintColor = UIColor.whiteColor()
        
    }
    
    func refresh(sender:AnyObject)
    {
        // Code to refresh table view
        self.refreshControl.endRefreshing()
        loadAllMovies()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadAllMovies() {
        
        networkErrorView.hidden = true
        
        let url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=US")!
        
        let request = NSURLRequest(URL: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            if let error = error {
                self.networkErrorView.hidden = false
            }
            
            let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
            
            if let json = json {
                self.movies = json["movies"] as? [NSDictionary]
                self.tableView.reloadData()
            }
            
            SVProgressHUD.dismiss()
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        movieSearchBar.delegate = self
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        filtered = movies!.filter({ (text) -> Bool in
            let tmp: NSString = text["title"] as! String
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            if (searchActive && filtered.count > 0) {
                return filtered.count
            } else {
                return movies.count
            }
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        var movie = movies![indexPath.row]
     
        if (searchActive && filtered.count > 0) {
            movie = filtered[indexPath.row]
        }
        
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        cell.movieRatingLabel.text = movie["mpaa_rating"] as? String
        
        var movieUrl = movie.valueForKeyPath("posters.thumbnail") as! String
        
        var range = movieUrl.rangeOfString(".*cloudfront.net/", options:.RegularExpressionSearch)
        if let range = range {
            movieUrl = movieUrl.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        
        
        let url = NSURL(string: movieUrl)
        
        cell.posterView.setImageWithURL(url)
        
        var rating = movie.valueForKeyPath("ratings.critics_rating") as! String
        
        if (rating == "Rotten") {
            var rottenImage = "http://can.whatsnewonnetflix.com/assets/rt/rotten-faa167f02772878934fe1c643e768dc8.png"
            var rottenUrl =  NSURL(string: rottenImage)
            cell.rottenImageView.setImageWithURL(rottenUrl)
        } else {
            var freshImage = "http://can.whatsnewonnetflix.com/assets/rt/fresh-e8a12911901fa79aa8484a708bff4675.png"
            var freshUrl =  NSURL(string: freshImage)
            cell.rottenImageView.setImageWithURL(freshUrl)
        }

        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        
        var movie: NSDictionary?
        
        if (searchActive && filtered.count > 0) {
            movie = filtered[indexPath.row]
        } else {
            movie = movies![indexPath.row]
        }
        
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        
        movieDetailsViewController.movie = movie
    }
}
