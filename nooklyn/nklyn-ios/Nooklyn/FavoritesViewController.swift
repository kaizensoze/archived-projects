//
//  FavoritesCollectionViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 6/8/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

import UIKit
import MobileCoreServices
import MBProgressHUD

class FavoritesViewController: UIViewController,
                               UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,
                               UITableViewDataSource, UITableViewDelegate, SliderTabBarViewDelegate,
                               UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var infoView: FavoritesInfoView!
    @IBOutlet var buttonsView: FavoritesButtonsView!
    @IBOutlet var favoritesView: FavoritesFavoritesView!
    
    // mate post view
    @IBOutlet var matePostTableView: UITableView!
    
    // favorite listings collection view
    @IBOutlet var favoriteListingsCollectionView: UICollectionView!
    @IBOutlet var favoriteListingsCollectionViewFlowLayout: UICollectionViewFlowLayout!
    
    // favorite mates collection view
    @IBOutlet var favoriteMatesCollectionView: UICollectionView!
    @IBOutlet var favoriteMatesCollectionViewFlowLayout: UICollectionViewFlowLayout!
    
    // favorite locations collection view
    @IBOutlet var favoriteLocationsCollectionView: UICollectionView!
    @IBOutlet var favoriteLocationsCollectionViewFlowLayout: UICollectionViewFlowLayout!
    
    // loading view
    @IBOutlet var loadingView: LoadingView!
    
    // refresh controls
    var favoriteListingsRefreshControl: UIRefreshControl!
    var favoriteMatesRefreshControl: UIRefreshControl!
    var favoriteLocationsRefreshControl: UIRefreshControl!
    
    var agent: Agent!
    var viewingFromFavoritesTab = false
    
    var matePostTableRows = ["Image", "Info", "Description"]
    var listingFavorites = [ListingFavorite]()
    var mateFavorites = [MateFavorite]()
    var locationFavorites = [LocationFavorite]()
    
    var imageAlertController: UIAlertController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar
        customizeNavigationBar()
        
        // setup views
        setupInfoView()
        setupButtonsView()
        setupFavoritesView()
        
        // image alert controller
        setupImageAlertController()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewingFromFavoritesTab = isViewingFromFavoritesTab()

        // hide settings button
        navigationItem.rightBarButtonItem = nil

        // special cases for viewing from favorites tab
        if self.viewingFromFavoritesTab {
            // show settings button
            let settingsButtonItem = UIBarButtonItem(title: "Settings", style: .Plain,
                target: self, action: "goToSettings:")
            settingsButtonItem.tintColor = UIColor(hexString: "FFC03A")
            navigationItem.setRightBarButtonItem(settingsButtonItem, animated: true)
            
            // require being logged in
            if !UserData.isLoggedIn() {
                performSegueWithIdentifier("login", sender: nil)
                return
            }
            
            // we can assume we're logged in
            let loggedInAgent = CacheManager.getAgent(UserData.getLoggedInAgentId()!)
            self.agent = loggedInAgent
        }
        
        if let _agent = self.agent {
            // if viewing own profile, hide buttons view
            if UserData.isLoggedInAgent(agentId: _agent.id) {
                self.buttonsView.height.constant = 0
            }
            
            // log agent id to console for convenience
            if UserData.isLoggedInAgent(agentId: _agent.id) {
                print("favorites for me (\(_agent.id))")
            } else {
                print("favorites for other (\(_agent.id))")
            }
            
            // update info view
            updateInfoView()
            
            // update buttons view
            updateButtonsView()
            
            // initially hide profile tab
            updateSliderTabBarView()
            matePostTableView.reloadData()
            
            // get favorites, mate post
            getFavorites() {
                ApiManager.getMate(_agent.id) { mate in
                    if let _mate = mate {
                        _mate.agent = _agent.copy() as! Agent
                        self.agent.mate = _mate
                        
                        if self.viewingFromFavoritesTab {
                            // update logged in agent's mate post in cache
                            CacheManager.saveAgents([self.agent])
                        }
                    }
                    
                    // update slider tab bar
                    self.updateSliderTabBarView()
                    
                    // update mate post view
                    self.matePostTableView.reloadData()
                    
                    // remove loading view
                    self.removeLoadingView()
                }
            }
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("Favorites")
    }
    
    override func viewDidLayoutSubviews() {
        self.updateSliderTabBarView()
        
//        self.matePostTableView.reloadData()
        self.favoriteListingsCollectionView.reloadData()
        self.favoriteMatesCollectionView.reloadData()
        self.favoriteLocationsCollectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func isViewingFromFavoritesTab() -> Bool {
        // determine if coming to favorites view as top view in favorites tab (your favorites)
        if let viewControllers = navigationController?.viewControllers {
            if viewControllers.count == 1 && viewControllers[0].isKindOfClass(FavoritesViewController) {
                return true
            }
        }
        return false
    }
    
    // MARK: - Go to settings
    
    @IBAction func goToSettings(sender: UIBarButtonItem) {
        performSegueWithIdentifier("settings", sender: nil)
    }
    
    // MARK: - Setup info view
    
    func setupInfoView() {
        if IS_IPHONE4() {
            self.infoView.imageHeight.constant = 65
            self.infoView.height.constant = 120
        } else if IS_IPHONE5() {
            self.infoView.imageHeight.constant = 70
            self.infoView.height.constant = 127
        } else if IS_IPHONE6() {
            self.infoView.imageHeight.constant = 92
            self.infoView.height.constant = 150
        } else {
            self.infoView.imageHeight.constant = 132
            self.infoView.height.constant = 190
        }
        self.infoView.layoutIfNeeded()
    }
    
    // MARK: - Setup buttons view
    
    func setupButtonsView() {
        // adjust height based on screen size
        if IS_IPHONE4() {
            self.buttonsView.height.constant = 50
        } else if IS_IPHONE5() {
            self.buttonsView.height.constant = 55
        } else {
            self.buttonsView.height.constant = 65
        }
        
        self.buttonsView.border1Thickness.constant = 0.5
        self.buttonsView.border2Thickness.constant = 0.5
    }
    
    // MARK: - Setup favorites view
    
    func setupFavoritesView() {
        // setup slider tab bar view
        setupSliderTabBarView()
        
        // mate post table view
        self.matePostTableView.estimatedRowHeight = 182.0
        self.matePostTableView.rowHeight = UITableViewAutomaticDimension
        
        // add refresh controls to collection views
        self.favoriteListingsRefreshControl = UIRefreshControl()
        self.favoriteListingsRefreshControl.addTarget(self, action: "getFavorites", forControlEvents: UIControlEvents.ValueChanged)
        self.favoriteListingsCollectionView.addSubview(self.favoriteListingsRefreshControl)
        self.favoriteListingsCollectionView.alwaysBounceVertical = true
        
        self.favoriteMatesRefreshControl = UIRefreshControl()
        self.favoriteMatesRefreshControl.addTarget(self, action: "getFavorites", forControlEvents: UIControlEvents.ValueChanged)
        self.favoriteMatesCollectionView.addSubview(self.favoriteMatesRefreshControl)
        self.favoriteMatesCollectionView.alwaysBounceVertical = true
        
        self.favoriteLocationsRefreshControl = UIRefreshControl()
        self.favoriteLocationsRefreshControl.addTarget(self, action: "getFavorites", forControlEvents: UIControlEvents.ValueChanged)
        self.favoriteLocationsCollectionView.addSubview(self.favoriteLocationsRefreshControl)
        self.favoriteLocationsCollectionView.alwaysBounceVertical = true
    }
    
    // MARK: - Setup slider tab bar view
    
    func setupSliderTabBarView() {
        favoritesView.sliderTabBarView.buttons = [
            favoritesView.sliderTabBarButton1,
            favoritesView.sliderTabBarButton2,
            favoritesView.sliderTabBarButton3,
            favoritesView.sliderTabBarButton4,
        ]
        
        favoritesView.sliderTabBarView.buttonWidthConstraints = [
            favoritesView.sliderTabBarButton1Width,
            favoritesView.sliderTabBarButton2Width,
            favoritesView.sliderTabBarButton3Width,
            favoritesView.sliderTabBarButton4Width,
        ]
        
        favoritesView.sliderTabBarView.contentViews = [
            self.matePostTableView,
            self.favoriteListingsCollectionView,
            self.favoriteMatesCollectionView,
            self.favoriteLocationsCollectionView
        ]
        favoritesView.sliderTabBarView.analyticsViewNames = [
            "Favorites#MatePost", "Favorites#Listings", "Favorites#Mates", "Favorites#Locations"
        ]
        favoritesView.sliderTabBarView.centerConstraints = [favoritesView.sliderTabBarInitialConstraint]
        favoritesView.sliderTabBarView.delegateView = favoritesView
        favoritesView.sliderTabBarView.delegate = self
        
        favoritesView.sliderTabBarView.currentTabIndex = 1
        favoritesView.sliderTabBarView.initialize()
    }
    
    // MARK: - Update slider tab bar view
    
    func updateSliderTabBarView() {
        favoritesView.sliderTabBarView.showAllTabs()
        
        // hide profile tab if no mate post
        if let _ = self.agent.mate {
        } else {
            favoritesView.sliderTabBarView.hideTabWithIndex(0)
        }
    }
    
    // MARK: - Slider tab bar view delegate
    
    func sliderTabBarView(sliderTabBarView: SliderTabBarView, tabSelected tabIndex: Int) {
        updateFavoritesEmptyView()
    }
    
    // MARK: - Update info view
    
    func updateInfoView() {
        self.infoView.imageView?.setImageWithURL(NSURL(string: self.agent.thumbnailURL)!)
        self.infoView.imageView.round()
        self.infoView.nameLabel?.text = self.agent.shortName
        self.infoView.regionLabel?.text = "Brooklyn, NY"
    }
    
    // MARK: - Update buttons view
    
    func updateButtonsView() {
        // disable/enable call button
        if self.agent.hasPhoneNumber() {
            self.buttonsView.callButton.enable()
        } else {
            self.buttonsView.callButton.disable()
        }
        
        // disable/enable message button
        if self.agent.onProbation || self.agent.suspended {
            self.buttonsView.messageButton.disable()
        } else {
            self.buttonsView.messageButton.enable()
        }
    }
    
    // MARK: - Get favorites
    
    func getFavorites(completion: (Void -> Void)?) {
        // hide empty view
        self.favoritesView.favoritesEmptyView.hidden = true
        
        // show loading view
        showLoadingView()
        
        ApiManager.getListingFavorites(agentId: self.agent.id) { listingFavorites in
            self.listingFavorites = listingFavorites.sort({ $0.statusVal < $1.statusVal })
            if self.viewingFromFavoritesTab {
                CacheManager.saveListingFavorites(listingFavorites)
            }
            
            ApiManager.getMateFavorites(agentId: self.agent.id) { mateFavorites in
                self.mateFavorites = mateFavorites.sort({ $0.when.compare($1.when) == NSComparisonResult.OrderedAscending })
                if self.viewingFromFavoritesTab {
                    CacheManager.saveMateFavorites(mateFavorites)
                }
                
                ApiManager.getLocationFavorites(agentId: self.agent.id) { locationFavorites in
                    self.locationFavorites = locationFavorites
                    if self.viewingFromFavoritesTab {
                        CacheManager.saveLocationFavorites(locationFavorites)
                    }
                    
                    // update collection views
                    self.updateFavoriteCollectionViews()
                    
                    completion?()
                }
            }
        }
    }

    // MARK: - Call agent
    
    @IBAction func call(sender: UIButton) {
        callAgent(agent: self.agent)
    }
    
    // MARK: - Message agent
    
    @IBAction func message(sender: UIButton) {
        let contextURL = "\(SITE_DOMAIN)/agents/\(self.agent.id)"
        messageAgent(agent: self.agent, contextURL: contextURL, vc: self)
    }

    // MARK: - Update favorite collection views
    
    func updateFavoriteCollectionViews() {
        // update collection views
        self.favoriteListingsCollectionView?.reloadData()
        self.favoriteMatesCollectionView?.reloadData()
        self.favoriteLocationsCollectionView?.reloadData()
        
        // update favorites empty view
        updateFavoritesEmptyView()
    }
    
    // MARK: - Update favorites empty view
    
    func updateFavoritesEmptyView() {
        let isOtherAgent = !UserData.isLoggedInAgent(agentId: self.agent.id)
        
        var hidden = true
        
        // label 1
        var label1Text = "You have no favorites."
        if isOtherAgent {
            label1Text = "They have no favorites."
        }
        self.favoritesView.favoritesEmptyLabel1.text = label1Text
        
        // label 2
        var label2Text = ""
        if self.listingFavorites.count == 0 && self.favoritesView.sliderTabBarButton2.selected {
            label2Text = "Try tapping the heart on a listing :)"
            hidden = false
        } else if self.mateFavorites.count == 0 && self.favoritesView.sliderTabBarButton3.selected {
            label2Text = "Try tapping the heart on a mate :)"
            hidden = false
        } else if self.locationFavorites.count == 0 && self.favoritesView.sliderTabBarButton4.selected {
            label2Text = "Try tapping the heart on a location :)"
            hidden = false
        }
        self.favoritesView.favoritesEmptyLabel2.text = label2Text
        self.favoritesView.favoritesEmptyLabel2.hidden = isOtherAgent
        
        // hide/show
        self.favoritesView.favoritesEmptyView.hidden = hidden
    }
    
    // MARK: - Show loading view
    
    func showLoadingView() {
        loadingView.hidden = false
        loadingView.activityIndicatorView.startAnimating()
    }
    
    // MARK: - Remove loading view
    
    func removeLoadingView() {
        if loadingView.imageView.layer.animationForKey("rotate") != nil {
            loadingView.imageView.layer.removeAnimationForKey("rotate")
        }
        loadingView.activityIndicatorView.stopAnimating()
        loadingView.hidden = true
        
        // stop refresh controls
        self.favoriteListingsRefreshControl.endRefreshing()
        self.favoriteMatesRefreshControl.endRefreshing()
        self.favoriteLocationsRefreshControl.endRefreshing()
    }
    
    // MARK: - Collection view data source

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.favoriteListingsCollectionView {
            return self.listingFavorites.count
        } else if collectionView == self.favoriteMatesCollectionView {
            return self.mateFavorites.count
        } else {
            return self.locationFavorites.count
        }
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == self.favoriteListingsCollectionView {
            let listing = self.listingFavorites[indexPath.item]
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FavoriteListingCell", forIndexPath: indexPath)
                as! FavoriteListingCollectionViewCell
            cell.listingImageView?.setImageWithURL(NSURL(string: listing.mediumImageURL)!)
            cell.favoriteButton.selected = true
            cell.rentedImageView.hidden = true
            if !listing.available {
                cell.rentedImageView.hidden = false
            }
            
            return cell
        } else if collectionView == self.favoriteMatesCollectionView {
            let mate = self.mateFavorites[indexPath.item]
            
            let cell = self.favoriteMatesCollectionView.dequeueReusableCellWithReuseIdentifier("FavoriteMateCell", forIndexPath: indexPath)
                as! FavoriteMateCollectionViewCell
            cell.firstNameLabel?.text = mate.firstName
            cell.mateImageView?.setImageWithURL(NSURL(string: mate.imageURL)!)
            cell.neighborhoodLabel?.text = mate.neighborhood?.name
            cell.budgetLabel?.text = "\(mate.formattedPrice)"
            cell.moveInLabel?.text = mate.formattedWhen
            
            updateMateFavoriteButton(cell.favoriteButton, mate: mate)
            
            cell.border1Thickness.constant = 0.5
            cell.border2Thickness.constant = 0.5
            
            return cell
        } else {
            let location = self.locationFavorites[indexPath.item]
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FavoriteLocationCell", forIndexPath: indexPath)
                as! FavoriteLocationCollectionViewCell
            cell.locationImageView?.setImageWithURL(NSURL(string: location.mediumImageURL)!)
            cell.favoriteButton.selected = true
            
            return cell
        }
    }

    // MARK: - Collection view delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.favoriteListingsCollectionView {
            let favoriteListing = self.listingFavorites[indexPath.item]
            if favoriteListing.available {
                performSegueWithIdentifier("listingDetail", sender: favoriteListing)
            } else {
                let alert = UIAlertController(title: "Remove?", message: "Listing is no longer available.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Remove", style: UIAlertActionStyle.Default) { action in
                    let cell = collectionView.cellForItemAtIndexPath(indexPath) as! FavoriteListingCollectionViewCell
                    let favoriteButton = cell.favoriteButton
                    self.favoriteListing(favoriteButton)
                })
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        } else if collectionView == self.favoriteMatesCollectionView {
            let favoriteMate = self.mateFavorites[indexPath.item]
            performSegueWithIdentifier("mateDetail", sender: favoriteMate)
        } else {
            let favoriteLocation = self.locationFavorites[indexPath.item]
            performSegueWithIdentifier("locationDetail", sender: favoriteLocation)
        }
    }

    // MARK: - Collection view delegate flow layout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView == self.favoriteListingsCollectionView || collectionView == self.favoriteLocationsCollectionView {
            let numDesiredColumns: Int!
            if IS_IPAD() {
                numDesiredColumns = 6
            } else {
                numDesiredColumns = 3
            }
            // listing and location collection view flow layouts should be the same
            let sectionPadding = self.favoriteListingsCollectionViewFlowLayout.sectionInset.left
            let itemPadding = self.favoriteListingsCollectionViewFlowLayout.minimumInteritemSpacing
            var width = view.frame.size.width - 2*sectionPadding - CGFloat(numDesiredColumns-1)*itemPadding
            width /= CGFloat(numDesiredColumns)
            if String(width).endsWith("66666667") {  // hack for floating point imprecision
                width = round(width)
            }
            let height = width
            return CGSizeMake(width, height)
        } else {
            var width = 161
            if IS_IPHONE5() || IS_IPHONE4() {
                width = 142
            }
            return CGSizeMake(CGFloat(width), 300)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        if collectionView == self.favoriteMatesCollectionView {
            return getInset()
        } else if collectionView == self.favoriteListingsCollectionView {
            return self.favoriteLocationsCollectionViewFlowLayout.minimumLineSpacing
        } else {
            return self.favoriteLocationsCollectionViewFlowLayout.minimumLineSpacing
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        if collectionView == self.favoriteMatesCollectionView {
            return getInset()
        } else if collectionView == self.favoriteListingsCollectionView {
            return self.favoriteLocationsCollectionViewFlowLayout.minimumInteritemSpacing
        } else {
            return self.favoriteLocationsCollectionViewFlowLayout.minimumInteritemSpacing
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if collectionView == self.favoriteMatesCollectionView {
            let inset = getInset()
            return UIEdgeInsetsMake(inset, inset, inset, inset)
        } else if collectionView == self.favoriteListingsCollectionView {
            return self.favoriteListingsCollectionViewFlowLayout.sectionInset
        } else {
            return self.favoriteLocationsCollectionViewFlowLayout.sectionInset
        }
    }
    
    func getInset() -> CGFloat {
        let viewWidth = self.view.frame.size.width
        let itemSize = self.collectionView(self.favoriteMatesCollectionView, layout: favoriteMatesCollectionViewFlowLayout, sizeForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        let colWidth = itemSize.width
        var numCols = floor(viewWidth / colWidth)
        // ipad screen is kinda cramped so subtract a column
        if IS_IPAD() {
            numCols -= 1
        }
        var inset = (viewWidth - (numCols * colWidth)) / (numCols + 1)
        inset = max(inset, 0)
        
        return CGFloat(inset)
    }

    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = self.agent.mate else {
            return 0
        }
        return self.matePostTableRows.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let matePost = self.agent.mate!
        let row = indexPath.row
        let rowLabel = self.matePostTableRows[row]
        var cell: UITableViewCell!
        switch rowLabel {
        case "Image":
            let thisCell = tableView.dequeueReusableCellWithIdentifier("MateDetailImageCell", forIndexPath: indexPath) as! MateDetailImageTableViewCell
            thisCell.mateImageView?.setImageWithURL(NSURL(string: matePost.imageURL)!)
            // one-time image height adjust for iphone 4/5
            if (IS_IPHONE4() || IS_IPHONE5()) && !thisCell.mateImageViewHeightSet {
                thisCell.mateImageViewHeight.constant = 300
                thisCell.mateImageViewHeightSet = true
            }
            cell = thisCell
        case "Name":
            let thisCell = tableView.dequeueReusableCellWithIdentifier("MateDetailNameCell", forIndexPath: indexPath) as! MateDetailNameTableViewCell
            thisCell.nameLabel?.text = matePost.firstName
            thisCell.borderThickness.constant = 0.5
            cell = thisCell
        case "Info":
            let thisCell = tableView.dequeueReusableCellWithIdentifier("MateDetailInfoCell", forIndexPath: indexPath) as! MateDetailInfoTableViewCell
            thisCell.neighborhoodLabel?.text = matePost.neighborhood?.name
            thisCell.budgetLabel?.text = "\(matePost.formattedPrice)"
            thisCell.moveInLabel?.text = matePost.formattedWhen
            thisCell.border1Thickness.constant = 0.5
            thisCell.border2Thickness.constant = 0.5
            thisCell.border3Thickness.constant = 0.5
            cell = thisCell
        case "Description":
            let thisCell = tableView.dequeueReusableCellWithIdentifier("MateDetailDescriptionCell", forIndexPath: indexPath) as! MateDetailDescriptionTableViewCell
            thisCell.descriptionTextView.setAttributedTextOnly(matePost._description)
            thisCell.descriptionTextView.contentInset = UIEdgeInsetsMake(-8, -4, 0, 0)
            cell = thisCell
        default:
            break
        }
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        
        return cell
    }
    
    // MARK: - Favorite listing
    
    @IBAction func favoriteListing(sender: UIButton) {
        // disallow unfavoriting someone else's favorite listings (wouldn't go through server-side anyway)
        if !UserData.isLoggedInAgent(agentId: self.agent.id) {
            return
        }
        
        sender.selected = !sender.selected
        
        if let cell = sender.superview?.superview?.superview as? FavoriteListingCollectionViewCell {
            if let indexPath = self.favoriteListingsCollectionView?.indexPathForCell(cell) {
                let listingFavorite = self.listingFavorites[indexPath.item]
                favoriteListingAction(listingFavorite as Listing, favorite: sender.selected)
                self.listingFavorites.removeAtIndex(indexPath.item)
                updateFavoriteCollectionViews()
            }
        }
    }
    
    // MARK: - Favorite listing 2 (long press)

    @IBAction func favoriteListing2(sender: UIGestureRecognizer) {
        if sender.state == .Ended {
            let point = sender.locationInView(self.favoriteListingsCollectionView)
            if let indexPath = self.favoriteListingsCollectionView?.indexPathForItemAtPoint(point) {
                let cell = self.favoriteListingsCollectionView?.cellForItemAtIndexPath(indexPath) as! FavoriteListingCollectionViewCell
                let favoriteButton = cell.favoriteButton
                favoriteListing(favoriteButton)
            }
        }
    }
    
    // MARK: - Favorite mate
    
    @IBAction func favoriteMate(sender: UIButton) {
        // disallow unfavoriting someone else's favorite mates (wouldn't go through server-side anyway)
        if !UserData.isLoggedInAgent(agentId: self.agent.id) {
            return
        }
        
        // get mate
        var mate: Mate?
        var mateItem: Int?
        if let mateCell = sender.superview?.superview as? FavoriteMateCollectionViewCell {
            if let indexPath = self.favoriteMatesCollectionView?.indexPathForCell(mateCell) {
                mate = self.mateFavorites[indexPath.item]
                mateItem = indexPath.item
            }
        }
        
        if mate == nil {
            return
        }
        
        sender.selected = !sender.selected
        favoriteMateAction(mate!, favorite: sender.selected)
        self.mateFavorites.removeAtIndex(mateItem!)
        updateFavoriteCollectionViews()
    }
    
    // MARK: - Favorite location
    
    @IBAction func favoriteLocation(sender: UIButton) {
        // disallow unfavoriting someone else's favorite locations (wouldn't go through server-side anyway)
        if !UserData.isLoggedInAgent(agentId: self.agent.id) {
            return
        }
        
        sender.selected = !sender.selected
        
        if let cell = sender.superview?.superview?.superview as? FavoriteLocationCollectionViewCell {
            if let indexPath = self.favoriteLocationsCollectionView?.indexPathForCell(cell) {
                let locationFavorite = self.locationFavorites[indexPath.item]
                favoriteLocationAction(locationFavorite as Location, favorite: sender.selected)
                self.locationFavorites.removeAtIndex(indexPath.item)
                updateFavoriteCollectionViews()
            }
        }
    }
    
    // MARK: - Favorite location 2 (long press)
    
    @IBAction func favoriteLocation2(sender: UIGestureRecognizer) {
        if sender.state == .Ended {
            let point = sender.locationInView(self.favoriteLocationsCollectionView)
            if let indexPath = self.favoriteLocationsCollectionView?.indexPathForItemAtPoint(point) {
                let cell = self.favoriteLocationsCollectionView?.cellForItemAtIndexPath(indexPath) as! FavoriteLocationCollectionViewCell
                let favoriteButton = cell.favoriteButton
                favoriteLocation(favoriteButton)
            }
        }
    }
    
    // MARK: - Message
    
    @IBAction func messageMate(sender: UIButton) {
        // get mate
        var mate: Mate?
        if let mateCell = sender.superview?.superview as? MateCollectionViewCell {
            if let indexPath = self.favoriteMatesCollectionView?.indexPathForCell(mateCell) {
                mate = self.mateFavorites[indexPath.item]
            }
        }
        
        let contextURL = "\(SITE_DOMAIN)/mate_posts/\(mate!.id)"
        messageAgent(agent: mate!.agent, contextURL: contextURL, vc: self)
    }

    // MARK: - Image alert controller
    
    func setupImageAlertController() {
        self.imageAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        // take image from camera
        let cameraAction = UIAlertAction(title: "Use Camera", style: .Default) { action in
            self.useCamera()
        }
        self.imageAlertController.addAction(cameraAction)
        
        // select from photo library
        let libraryAction = UIAlertAction(title: "Choose from photo library", style: .Default) { action in
            self.chooseFromPhotoLibrary()
        }
        self.imageAlertController.addAction(libraryAction)
        
        // cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
        }
        self.imageAlertController.addAction(cancelAction)
        
        // required for ipad
        self.imageAlertController.popoverPresentationController?.sourceView = self.infoView.imageView
        self.imageAlertController.popoverPresentationController?.sourceRect = CGRectMake(0, 0,
            self.view.frame.size.width, 215)
        self.imageAlertController.popoverPresentationController?.permittedArrowDirections = .Up
    }
    
    @IBAction func showImageAlertController(sender: UIGestureRecognizer) {
        if !UserData.isLoggedInAgent(agentId: self.agent.id) {
            return
        }
        
        if sender.state == .Ended {
            self.presentViewController(self.imageAlertController, animated: true, completion: {
                // ipad edge case
                if IS_IPAD() {
                    self.setupImageAlertController()
                }
            })
        }
    }
    
    // MARK: - Use camera
    
    func useCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - Choose from photo library
    
    func chooseFromPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - Image picker controller delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: {
            // upload image
            let mediaType = info[UIImagePickerControllerMediaType] as! String
            if mediaType == (kUTTypeImage as String) {
                let image = info[UIImagePickerControllerOriginalImage] as! UIImage
                self.uploadProfileImage(image)
            }
        })
    }
    
    // MARK: - Upload profile image
    
    func uploadProfileImage(image: UIImage) {
        // check image file size
        let imageFileSizeinMB = getImageFileSizeInMB(image)
        if imageFileSizeinMB > 10 {
            showErrorAlert(message: "Image exceeds 10MB file size limit.", vc: self)
            return
        }
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        ApiManager.uploadProfileImage(image) { (uploadSucceeded, newThumbnailURL) in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            
            if uploadSucceeded {
                // update logged in agent's thumbnail url
                if let loggedInAgent = CacheManager.getAgent(UserData.getLoggedInAgentId()!), thumbnailURL = newThumbnailURL {
                    loggedInAgent.thumbnailURL = thumbnailURL
                    CacheManager.saveAgents([loggedInAgent])
                }
                // update profile image in info view
                self.infoView.imageView.image = image
            } else {
                showErrorAlert(message: "Unable to update profile picture.", vc: self)
            }
        }
    }
    
    // MARK: - Prepare for segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "listingDetail" {
            let vc = segue.destinationViewController as! ListingDetailTableViewController
            let listing = sender as! Listing
            vc.listing = listing
        } else if segue.identifier == "mateDetail" {
            let vc = segue.destinationViewController as! MateDetailTableViewController
            let mate = sender as! Mate
            vc.mate = mate
        } else if segue.identifier == "locationDetail" {
            let vc = segue.destinationViewController as! LocationDetailTableViewController
            let location = sender as! Location
            vc.location = location
        }
    }
}

class FavoritesInfoView: UIView {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageHeight: NSLayoutConstraint!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var regionLabel: UILabel!
    @IBOutlet var height: NSLayoutConstraint!
}

class FavoritesButtonsView: UIView {
    @IBOutlet var callButton: UIButton!
    @IBOutlet var messageButton: UIButton!
    @IBOutlet var height: NSLayoutConstraint!
    @IBOutlet var border1Thickness: NSLayoutConstraint!
    @IBOutlet var border2Thickness: NSLayoutConstraint!
}

class FavoritesFavoritesView: UIView {
    // slider tab bar
    @IBOutlet var sliderTabBarView: SliderTabBarView!
    @IBOutlet var sliderTabBarButton1: UIButton!
    @IBOutlet var sliderTabBarButton2: UIButton!
    @IBOutlet var sliderTabBarButton3: UIButton!
    @IBOutlet var sliderTabBarButton4: UIButton!
    @IBOutlet var sliderTabBarButton1Width: NSLayoutConstraint!
    @IBOutlet var sliderTabBarButton2Width: NSLayoutConstraint!
    @IBOutlet var sliderTabBarButton3Width: NSLayoutConstraint!
    @IBOutlet var sliderTabBarButton4Width: NSLayoutConstraint!
    @IBOutlet var sliderTabBarInitialConstraint: NSLayoutConstraint!
    
    // favorites empty view
    @IBOutlet var favoritesEmptyView: UIView!
    @IBOutlet var favoritesEmptyLabel1: UILabel!
    @IBOutlet var favoritesEmptyLabel2: UILabel!
}

class FavoriteListingCollectionViewCell: ListingCollectionViewCell {
    @IBOutlet var rentedImageView: UIImageView!
}

class FavoriteMateCollectionViewCell: MateCollectionViewCell {
}

class FavoriteLocationCollectionViewCell: UICollectionViewCell {
    @IBOutlet var locationImageView: UIImageView!
    @IBOutlet var favoriteButton: UIButton!
}
