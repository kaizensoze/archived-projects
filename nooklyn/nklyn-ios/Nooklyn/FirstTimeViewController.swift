//
//  FirstTimeViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 6/7/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

import UIKit

class FirstTimeViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pageViewController: UIPageViewController!
    var pageContent1VC: UIViewController!
    var pageContent2VC: UIViewController!
    var pageContent3VC: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // navigation bar
        customizeNavigationBar()
        
        // page controller
        pageContent1VC = storyboard?.instantiateViewControllerWithIdentifier("PageContent1") as UIViewController!
        pageContent2VC = storyboard?.instantiateViewControllerWithIdentifier("PageContent2") as UIViewController!
        pageContent3VC = storyboard?.instantiateViewControllerWithIdentifier("PageContent3") as UIViewController!
        
        pageViewController.setViewControllers([pageContent1VC], direction: UIPageViewControllerNavigationDirection.Forward,
            animated: true, completion: nil)
        
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.blackColor()
        pageControl.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("FirstTime")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func browseNow(sender: UIButton) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("TabBar") as UIViewController!
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = vc
    }
    
    // MARK: - Page view controller data source
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 3
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        if viewController == pageContent1VC {
            return pageContent2VC
        } else if viewController == pageContent2VC {
            return pageContent3VC
        } else {
            return nil
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        if viewController == pageContent3VC {
            return pageContent2VC
        } else if viewController == pageContent2VC {
            return pageContent1VC
        } else {
            return nil
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pageController" {
            pageViewController = segue.destinationViewController as! UIPageViewController
            pageViewController.dataSource = self
            pageViewController.delegate = self
        }
    }
}
