//
//  PhotoViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 7/29/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    var photo: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar
        customizeNavigationBar()
        
        // load image
        imageView.setImageWithURL(NSURL(string: photo.imageURL)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
