//
//  TermsViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 7/23/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar
        customizeNavigationBar()
        
        // load webview
        let request = NSURLRequest(URL: NSURL(string: "https://nooklyn.com/tos")!)
        webView.loadRequest(request)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("Terms")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
