//
//  NeighborhoodsCollectionViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 5/28/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

import UIKit

class NeighborhoodsCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, SliderTabBarViewDelegate {
    
    // slider tab bar
    @IBOutlet var sliderTabBarView: SliderTabBarView!
    @IBOutlet var sliderTabBarButton1: UIButton!
    @IBOutlet var sliderTabBarButton2: UIButton!
    @IBOutlet var sliderTabBarButton3: UIButton!
    @IBOutlet var sliderTabBarInitialConstraint: NSLayoutConstraint!
    
    // neighborhoods collection view
    @IBOutlet var neighborhoodsCollectionView: UICollectionView!
    
    let kBrooklynTabIndex = 0
    let kManhattanTabIndex = 1
    let kSanFranciscoTabIndex = 2
    
    var neighborhoods = CacheManager.getNeighborhoods()
    var brooklynNeighborhoods = [Neighborhood]()
    var manhattanNeighborhoods = [Neighborhood]()
    var sanFranciscoNeighborhoods = [Neighborhood]()
    
    // refresh control
    var gridCollectionRefreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateNeighborhoods()
        
        // navigation bar
        customizeNavigationBar()
        
        // slider tab bar
        setupSliderTabBarView()
        
        // refresh control
        gridCollectionRefreshControl = UIRefreshControl()
        gridCollectionRefreshControl.addTarget(self, action: "getNeighborhoods", forControlEvents: UIControlEvents.ValueChanged)
        neighborhoodsCollectionView?.addSubview(gridCollectionRefreshControl)
        neighborhoodsCollectionView?.alwaysBounceVertical = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        neighborhoodsCollectionView?.reloadData()
        
        let totalNeighborhoodCount = brooklynNeighborhoods.count + manhattanNeighborhoods.count + sanFranciscoNeighborhoods.count
        if totalNeighborhoodCount == 0 {
            getNeighborhoods()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("Neighborhoods#Brooklyn")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Setup slider tab bar view
    
    func setupSliderTabBarView() {
        self.sliderTabBarView.buttons = [self.sliderTabBarButton1, self.sliderTabBarButton2, self.sliderTabBarButton3]
        self.sliderTabBarView.contentViews = [neighborhoodsCollectionView, neighborhoodsCollectionView, neighborhoodsCollectionView]
        self.sliderTabBarView.analyticsViewNames = ["Neighborhoods#Brooklyn", "Neighborhoods#Manhattan", "Neighborhoods#SanFrancisco"]
        self.sliderTabBarView.centerConstraints = [sliderTabBarInitialConstraint]
        self.sliderTabBarView.delegate = self
        
        self.sliderTabBarView.initialize()
    }
    
    // MARK: - SliderTabBarViewDelegate
    
    func sliderTabBarView(sliderTabBarView: SliderTabBarView, tabSelected tabIndex: Int) {
        neighborhoodsCollectionView.reloadData()
        self.neighborhoodsCollectionView.setContentOffset(CGPointZero, animated: false)
    }
    
    // MARK: - Get neighborhoods
    
    func getNeighborhoods() {
        ApiManager.getNeighborhoods() { neighborhoods in
            self.neighborhoods = neighborhoods
            CacheManager.saveNeighborhoods(neighborhoods)
            
            self.updateNeighborhoods()
            
            self.gridCollectionRefreshControl.endRefreshing()
            self.neighborhoodsCollectionView.reloadData()
        }
    }
    
    func updateNeighborhoods() {
        // brooklyn
        self.brooklynNeighborhoods = self.neighborhoods.filter({
            $0.region.id == "1" && $0.locationCategoryCount >= 2
        }).sort({
            $0.locationCategoryCount > $1.locationCategoryCount
        })
        
        // manhattan
        self.manhattanNeighborhoods = self.neighborhoods.filter({
            $0.region.id == "2" && $0.locationCategoryCount >= 2
        }).sort({
            $0.locationCategoryCount > $1.locationCategoryCount
        })
        
        // san francisco
        self.sanFranciscoNeighborhoods = self.neighborhoods.filter({
            $0.region.id == "4" && $0.locationCategoryCount >= 2
        }).sort({
            $0.locationCategoryCount > $1.locationCategoryCount
        })
    }
    
    // MARK: - Get neighborhoods for current tab
    
    func getNeighborhoodsForCurrentTab() -> [Neighborhood] {
        if self.sliderTabBarView.currentTabIndex == kBrooklynTabIndex {
            return brooklynNeighborhoods
        } else if self.sliderTabBarView.currentTabIndex == kManhattanTabIndex {
            return manhattanNeighborhoods
        } else {
            return sanFranciscoNeighborhoods
        }
    }
    
    // MARK: - Collection view data source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getNeighborhoodsForCurrentTab().count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NeighborhoodCell", forIndexPath: indexPath)
            as! NeighborhoodCollectionViewCell
        let neighborhood = getNeighborhoodsForCurrentTab()[indexPath.item]
        cell.nameLabel?.text = neighborhood.name.uppercaseString
        cell.backgroundImageView?.setImageWithURL(NSURL(string: neighborhood.imageURL)!)
        return cell
    }
    
    // MARK: - Collection view delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let neighborhood = getNeighborhoodsForCurrentTab()[indexPath.item]
        performSegueWithIdentifier("neighborhoodDetail", sender: neighborhood)
    }
    
    // MARK: - Collection view delegate flow layout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if IS_IPAD() {
            let width = view.frame.size.width/3
            let height = width * 0.88
            return CGSizeMake(width, height)
        } else {
            let width = view.frame.size.width
            let height = width * 0.88
            return CGSizeMake(width, height)
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "neighborhoodDetail" {
            let vc = segue.destinationViewController as! NeighborhoodDetailTableViewController
            let neighborhood = sender as! Neighborhood
            vc.neighborhood = neighborhood
        }
    }
}

class NeighborhoodCollectionViewCell: UICollectionViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var backgroundImageView: UIImageView!
}
