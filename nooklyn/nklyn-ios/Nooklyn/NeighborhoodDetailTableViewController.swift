//
//  NeighborhoodDetailTableViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 11/17/15.
//  Copyright © 2016 Nooklyn. All rights reserved.
//

import UIKit

class NeighborhoodDetailTableViewController: UITableViewController, UICollectionViewDataSource,
                                             UICollectionViewDelegateFlowLayout {

    var neighborhood: Neighborhood!
    var rows = ["Image", "LocationCategories"]
    
    var locationCategories = [LocationCategory]()
    var locationCategoriesCollectionView: UICollectionView?
    var locationCategoriesCollectionViewHeightConstant: CGFloat = 0
    
    var mates = [Mate]()
    var matesCollectionView: UICollectionView?
    
    var featuredLocations = [Location]()
    var featuredLocationsCollectionView: UICollectionView?
    
    // refresh control
    var tableViewRefreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar
        customizeNavigationBar()
        
        tableView.estimatedRowHeight = 182.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // refresh control
        tableViewRefreshControl = UIRefreshControl()
        tableViewRefreshControl.addTarget(self, action: "getNeighborhoodData", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(tableViewRefreshControl)
        tableView.alwaysBounceVertical = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // get neighborhood data
        getNeighborhoodData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("NeighborhoodDetail")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Get neighborhood data
    
    func getNeighborhoodData() {
        // location categories
        getNeighborhoodLocationCategories()
        
        // mates
        if UserData.isFacebookAuthenticated() {
            getNeighborhoodMates()
        } else {
            self.rows.removeObject("Mates")
        }
        
        // featured locations
        getNeighborhoodFeaturedLocations()
        
        // refresh table
        self.tableView.reloadData()
    }
    
    // MARK: - Get neighborhood location categories
    
    func getNeighborhoodLocationCategories() {
        ApiManager.getNeighborhoodLocationCategories(neighborhoodId: self.neighborhood.id) { categories in
            self.locationCategories = categories
            
            // adjust collection view height to fit content
            let numRows = self.getNumLocationCategoryRows()
            let height = 169
            self.locationCategoriesCollectionViewHeightConstant = CGFloat(numRows) * CGFloat(height)
            
            // reload
            self.locationCategoriesCollectionView?.reloadData()
            self.tableView.reloadData()
            
            // end refresh
            self.tableViewRefreshControl.endRefreshing()
        }
    }
    
    // MARK: - Get neighborhood mates
    
    func getNeighborhoodMates() {
        ApiManager.getMates(neighborhoodId: self.neighborhood.id) { mates in
            self.mates = mates.filter({ $0.neighborhood.id == self.neighborhood.id }).sort({
                $0.when.compare($1.when) == NSComparisonResult.OrderedAscending
            }).map({ $0 })
            if !self.rows.contains("Mates") && self.mates.count > 0 {
                self.rows.insert("Mates", atIndex: 2)
            }
            self.matesCollectionView?.reloadData()
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Get neighborhood featured locations
    
    func getNeighborhoodFeaturedLocations() {
        ApiManager.getNeighborhoodFeaturedLocations(neighborhoodId: self.neighborhood.id) { locations in
            self.featuredLocations = locations
            
            if !self.rows.contains("FeaturedLocations") && self.featuredLocations.count > 0 {
                self.rows.append("FeaturedLocations")
            }
            
            // reload
            self.featuredLocationsCollectionView?.reloadData()
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = indexPath.row
        let rowLabel = rows[row]
        var cell: UITableViewCell!
        switch rowLabel {
        case "Image":
            let thisCell = tableView.dequeueReusableCellWithIdentifier("NeighborhoodDetailImageCell", forIndexPath: indexPath) as! NeighborhoodDetailImageTableViewCell
            thisCell.neighborhoodImageView?.setImageWithURL(NSURL(string: neighborhood.imageURL)!)
            thisCell.nameLabel?.text = neighborhood.name.uppercaseString
            cell = thisCell
        case "LocationCategories":
            let thisCell = tableView.dequeueReusableCellWithIdentifier("NeighborhoodDetailLocationCategoriesCell", forIndexPath: indexPath) as! NeighborhoodDetailLocationCategoriesTableViewCell
            locationCategoriesCollectionView = thisCell.locationCategoriesCollectionView
            thisCell.locationCategoriesCollectionViewHeight.constant = locationCategoriesCollectionViewHeightConstant
            thisCell.border1Thickness.constant = 0.5
            thisCell.border2Thickness.constant = 0.5
            cell = thisCell
        case "Mates":
            let thisCell = tableView.dequeueReusableCellWithIdentifier("NeighborhoodDetailMatesCell", forIndexPath: indexPath) as! NeighborhoodDetailMatesTableViewCell
            matesCollectionView = thisCell.matesCollectionView
            thisCell.borderThickness.constant = 0.5
            cell = thisCell
        case "FeaturedLocations":
            let thisCell = tableView.dequeueReusableCellWithIdentifier("NeighborhoodDetailFeaturedLocationsCell", forIndexPath: indexPath) as! NeighborhoodDetailFeaturedLocationsTableViewCell
            thisCell.exploreLabel.text = "EXPLORE \(self.neighborhood.name)".uppercaseString
            featuredLocationsCollectionView = thisCell.featuredLocationsCollectionView
            thisCell.borderThickness.constant = 0.5
            cell = thisCell
        default:
            break
        }
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        
        return cell
    }

    // MARK: - Collection view data source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == locationCategoriesCollectionView {
            return self.locationCategories.count
        } else if collectionView == matesCollectionView {
            return self.mates.count
        } else if collectionView == featuredLocationsCollectionView {
            return featuredLocations.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell!
        if collectionView == locationCategoriesCollectionView {
            let locationCategory = self.locationCategories[indexPath.item]
            
            let thisCell = collectionView.dequeueReusableCellWithReuseIdentifier("LocationCategoryCell", forIndexPath: indexPath) as! NeighborhoodDetailLocationCategoriesCollectionViewCell
            thisCell.locationCategoryImageView?.setImageWithURL(NSURL(string: locationCategory.imageURL)!, fadeIn: false)
            thisCell.nameLabel?.text = locationCategory.name.uppercaseString
            
            thisCell.topBorderThickness.constant = 0.25
            thisCell.rightBorderThickness.constant = 0.5
            thisCell.bottomBorderThickness.constant = 0.5
            
            // initialize all borders as hidden
            thisCell.topBorder.hidden = true
            thisCell.rightBorder.hidden = true
            thisCell.bottomBorder.hidden = true
            
            // check which borders to show
            let numCols = getNumLocationCategoryCols()
            
            // right border
            if indexPath.item % numCols != numCols - 1 {
                thisCell.rightBorder.hidden = false
            }
            // bottom border
            thisCell.bottomBorder.hidden = false
            
            cell = thisCell
        } else if collectionView == matesCollectionView {
            let mate = self.mates[indexPath.item]
            
            let thisCell = collectionView.dequeueReusableCellWithReuseIdentifier("MateCell", forIndexPath: indexPath) as! NeighborhoodDetailMatesCollectionViewCell
            thisCell.mateImageView?.setImageWithURL(NSURL(string: mate.imageURL)!)
            thisCell.mateImageView?.round()
            cell = thisCell
        } else if collectionView == featuredLocationsCollectionView {
            let featuredLocation = self.featuredLocations[indexPath.item]
            
            let thisCell = collectionView.dequeueReusableCellWithReuseIdentifier("FeaturedLocationCell", forIndexPath: indexPath) as! NeighborhoodDetailFeaturedLocationsCollectionViewCell
            thisCell.featuredLocationImageView?.setImageWithURL(NSURL(string: featuredLocation.mediumImageURL)!)
            cell = thisCell
        }
        return cell
    }

    // MARK: - Collection view delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == locationCategoriesCollectionView {
            let locationCategory = self.locationCategories[indexPath.item]
            performSegueWithIdentifier("neighborhoodLocations", sender: locationCategory)
        } else if collectionView == matesCollectionView {
            let mate = self.mates[indexPath.item]
            performSegueWithIdentifier("mateDetail", sender: mate)
        } else if collectionView == featuredLocationsCollectionView {
            let location = self.featuredLocations[indexPath.item]
            performSegueWithIdentifier("locationDetail", sender: location)
        }
    }

    // MARK: - Collection view delegate flow layout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView == locationCategoriesCollectionView {
            let numDesiredColumns = getNumLocationCategoryCols()
            let width = collectionView.frame.size.width / CGFloat(numDesiredColumns)
            let height = 169
            return CGSizeMake(width, CGFloat(height))
        } else if collectionView == matesCollectionView {
            return CGSizeMake(50, 50)
        } else {
            return CGSizeMake(82, 82)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        if collectionView == matesCollectionView || collectionView == featuredLocationsCollectionView {
            return 7
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    // MARK: - Get location category num cols/rows
    
    func getNumLocationCategoryCols() -> Int {
        let numDesiredColumns: Int!
        if IS_IPAD() {
            numDesiredColumns = 6
        } else {
            numDesiredColumns = 3
        }
        return numDesiredColumns
    }
    
    func getNumLocationCategoryRows() -> Int {
        let numCols = self.getNumLocationCategoryCols()
        let numRows = ceil(Float(self.locationCategories.count) / Float(numCols))
        return Int(numRows)
    }

    // MARK: - Browse mates
    
    @IBAction func browseMates(sender: UIButton) {
        selectMatesTab()
    }
    
    // MARK: - Select mates tab
    
    func selectMatesTab() {
        if let tabBarViewControllers = tabBarController?.viewControllers,
            nc = tabBarViewControllers[2] as? UINavigationController,
            matesVC = nc.viewControllers[0] as? MatesViewController {
                if UserData.isFacebookAuthenticated() {
                    matesVC.filters = MateFilters()
                    matesVC.filters.neighborhoodIds = [self.neighborhood.id]
                }
        }
        tabBarController?.selectedIndex = 2
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "neighborhoodLocations" {
            let locationCategory = sender as! LocationCategory
            let vc = segue.destinationViewController as! NeighborhoodLocationsViewController
            vc.neighborhood = self.neighborhood
            vc.locationCategory = locationCategory
        } else if segue.identifier == "mateDetail" {
            let mate = sender as! Mate
            let vc = segue.destinationViewController as! MateDetailTableViewController
            vc.mate = mate
        } else if segue.identifier == "locationDetail" {
            let location = sender as! Location
            let vc = segue.destinationViewController as! LocationDetailTableViewController
            vc.location = location
        }
    }
}

// MARK: - Neighborhood Detail Image Table View Cell

class NeighborhoodDetailImageTableViewCell: UITableViewCell {
    @IBOutlet var neighborhoodImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
}

// MARK: Neighborhood Detail Location Categories Table View Cell

class NeighborhoodDetailLocationCategoriesTableViewCell: UITableViewCell {
    @IBOutlet var locationCategoriesCollectionView: UICollectionView!
    @IBOutlet var locationCategoriesCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet var border1Thickness: NSLayoutConstraint!
    @IBOutlet var border2Thickness: NSLayoutConstraint!
}

// MARK: Neighborhood Detail Mates Table View Cell

class NeighborhoodDetailMatesTableViewCell: UITableViewCell {
    @IBOutlet var matesCollectionView: UICollectionView!
    @IBOutlet var borderThickness: NSLayoutConstraint!
}

// MARK: Neighborhood Detail Featured Locations Table View Cell

class NeighborhoodDetailFeaturedLocationsTableViewCell: UITableViewCell {
    @IBOutlet var exploreLabel: UILabel!
    @IBOutlet var featuredLocationsCollectionView: UICollectionView!
    @IBOutlet var borderThickness: NSLayoutConstraint!
}

// MARK: - Neighborhood Detail Location Categories Collection View Cell

class NeighborhoodDetailLocationCategoriesCollectionViewCell: UICollectionViewCell {
    @IBOutlet var locationCategoryImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var topBorder: UILabel!
    @IBOutlet var rightBorder: UILabel!
    @IBOutlet var bottomBorder: UILabel!
    
    @IBOutlet var topBorderThickness: NSLayoutConstraint!
    @IBOutlet var rightBorderThickness: NSLayoutConstraint!
    @IBOutlet var bottomBorderThickness: NSLayoutConstraint!
}

// MARK: Neighborhood Detail Mates Collection View Cell

class NeighborhoodDetailMatesCollectionViewCell: UICollectionViewCell {
    @IBOutlet var mateImageView: UIImageView!
}

// MARK: Neighborhood Detail Featured Locations Collection View Cell

class NeighborhoodDetailFeaturedLocationsCollectionViewCell: UICollectionViewCell {
    @IBOutlet var featuredLocationImageView: UIImageView!
}
