//
//  MovieDetailsViewController.swift
//  Little Tomato
//
//  Created by Holly French on 4/15/15.
//  Copyright (c) 2015 Holly French. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = movie["title"] as? String
        synopsisLabel.text = movie["synopsis"] as? String

        var movieUrl = movie.valueForKeyPath("posters.thumbnail") as! String
        
        var range = movieUrl.rangeOfString(".*cloudfront.net/", options:.RegularExpressionSearch)
        if let range = range {
            movieUrl = movieUrl.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        
        
        let url = NSURL(string: movieUrl)
        
        imageView.setImageWithURL(url)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var synopsisLabel: UILabel!
    
    var movie: NSDictionary!
}
