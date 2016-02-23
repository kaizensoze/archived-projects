//
//  PhotosViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 7/29/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var pageViewController: UIPageViewController!
    var photoIndex: Int!
    var photos = [Photo]()
    var viewControllers = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar
        customizeNavigationBar()
        
        // generate view controllers
        generateViewControllers()
        
        // initial view controller
        let initialVC = viewControllers[photoIndex]
        
        pageViewController.setViewControllers([initialVC], direction: UIPageViewControllerNavigationDirection.Forward,
            animated: true, completion: nil)
        
        // page control
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor(hexString: "FFC03A") // F1E577
        pageControl.backgroundColor = UIColor.blackColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("Photos")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Generate view controllers
    
    func generateViewControllers() {
        for photo in photos {
            let vc = storyboard?.instantiateViewControllerWithIdentifier("Photo") as! PhotoViewController
            vc.photo = photo
            viewControllers.append(vc)
        }
    }
    
    // MARK: - Page view controller data source
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return photos.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return photoIndex
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let currentVC = viewController as! PhotoViewController
        if let vcIndex = viewControllers.indexOf(currentVC) {
            if vcIndex >= viewControllers.count - 1 {
                return nil
            } else {
                return viewControllers[vcIndex + 1]
            }
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let currentVC = viewController as! PhotoViewController
        if let vcIndex = viewControllers.indexOf(currentVC) {
            if vcIndex <= 0 {
                return nil
            } else {
                return viewControllers[vcIndex - 1]
            }
        }
        return nil
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
