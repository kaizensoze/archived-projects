//
//  ListingsViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 5/28/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ListingsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate,
                              UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,
                              UIPopoverPresentationControllerDelegate, FiltersViewDelegate,
                              SliderTabBarViewDelegate {
    
    // slider tab bar
    @IBOutlet var sliderTabBarView: SliderTabBarView!
    @IBOutlet var sliderTabBarButton1: UIButton!
    @IBOutlet var sliderTabBarButton2: UIButton!
    @IBOutlet var sliderTabBarButton3: UIButton!
    @IBOutlet var sliderTabBarButton1Width: NSLayoutConstraint!
    @IBOutlet var sliderTabBarButton2Width: NSLayoutConstraint!
    @IBOutlet var sliderTabBarButton3Width: NSLayoutConstraint!
    @IBOutlet var sliderTabBarInitialConstraint: NSLayoutConstraint!
    
    // map view
    @IBOutlet var mapView: MKMapView!
    
    // listing preview
    @IBOutlet var listingPreviewView: ListingPreviewView!
    @IBOutlet var listingPreviewDefaultConstraint: NSLayoutConstraint!
    var listingPreviewActiveConstraint: NSLayoutConstraint!
    
    // grid view
    @IBOutlet var gridCollectionView: UICollectionView!
    @IBOutlet var gridCollectionViewFlowLayout: UICollectionViewFlowLayout!
    var gridCollectionRefreshControl: UIRefreshControl!
    
    // play view
    @IBOutlet var playView: PlayListingView!
    
    // loading view
    @IBOutlet var loadingView: LoadingView!
    
    var listings = [Listing]()
    var lastFetchedListings = [Listing]()
    
    var filters: ListingFilters = ListingFilters()
    var pinSelectCount = 0
    
    let NOOKLYN_CENTER = CLLocationCoordinate2DMake(40.687108, -73.943166)
    var locationDistance: Double!
    
    var locationManager: CLLocationManager!
    var lastLocation: CLLocation!
    
    let stopwatch = StopWatch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar
        customizeNavigationBar()
        
        // location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // slider tab bar
        setupSliderTabBarView()
        
        // map view
        locationDistance = 16000.0
        if IS_IPAD() {  // adjust distance for ipad
            locationDistance = 8000.0
        }
        let region = MKCoordinateRegionMakeWithDistance(NOOKLYN_CENTER, locationDistance, locationDistance)
        mapView.region = region
        mapView.showsUserLocation = true
        
        // listing preview
        listingPreviewView.hidden = true
        
        listingPreviewActiveConstraint = NSLayoutConstraint(item: listingPreviewView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: bottomLayoutGuide, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        
        // grid view
        
        // add pull to refresh grid view
        gridCollectionRefreshControl = UIRefreshControl()
        gridCollectionRefreshControl.addTarget(self, action: "getListings", forControlEvents: UIControlEvents.ValueChanged)
        gridCollectionView.addSubview(gridCollectionRefreshControl)
        gridCollectionView.alwaysBounceVertical = true
        
        // play view
        setupPlayView()
        
        // get listings
        getListings()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // this is here due to the filter segue navigationbar overlap issue
        navigationItem.rightBarButtonItem?.title = "Filter"
        navigationItem.titleView?.hidden = false
        
        // update slider tab bar
        updateSliderTabBarView()
        
        // update grid/listing preview view to reflect latest favorites data
        gridCollectionView.reloadData()
        if !listingPreviewView.hidden {
            updateListingFavoriteButton(listingPreviewView.favoriteButton, listing: listingPreviewView.listing)
        }
        
        // refresh play view
        refreshPlayView()
        
        // we don't want to refresh listing pins everytime due to an annoying flicker,
        // but if listing objects have been invalidated, clear them
        if self.listings.count == 0 {
            updateMapMarkers()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("Listings#Map")
        
        // record initial play view image center
        self.playView.initialImageContainerCenter = self.playView.imageContainerView.center
    }
    
    override func viewDidLayoutSubviews() {
        self.updateSliderTabBarView()
        self.gridCollectionView.reloadData()
        self.playView.initialImageContainerCenter = self.playView.imageContainerView.center
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Setup slider tab bar view
    
    func setupSliderTabBarView() {
        self.sliderTabBarView.buttons = [self.sliderTabBarButton1, self.sliderTabBarButton2, self.sliderTabBarButton3]
        self.sliderTabBarView.buttonWidthConstraints = [self.sliderTabBarButton1Width, self.sliderTabBarButton2Width, self.sliderTabBarButton3Width]
        self.sliderTabBarView.contentViews = [self.mapView, self.gridCollectionView, self.playView]
        self.sliderTabBarView.analyticsViewNames = ["Listings#Map", "Listings#Grid", "Listings#Play"]
        self.sliderTabBarView.centerConstraints = [self.sliderTabBarInitialConstraint]
        self.sliderTabBarView.delegate = self
        
        self.sliderTabBarView.initialize()
    }
    
    // MARK: - Update slider tab bar view
    
    func updateSliderTabBarView() {
        self.sliderTabBarView.showAllTabs()
        
        // hide play tab if not logged in
        if !UserData.isLoggedIn() {
            self.sliderTabBarView.hideTabWithIndex(2)
        }
    }
    
    // MARK: - Setup play view
    
    func setupPlayView() {
        // rotate yay/nay labels
        self.playView.yayLabel.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_4))
        self.playView.nayLabel.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
        
        // adjust position of yay/nay labels
        var yPos: CGFloat!
        if IS_IPHONE4() {
            yPos = CGFloat(10)
        } else if IS_IPHONE5() {
            yPos = CGFloat(30)
        } else if IS_IPHONE6() {
            yPos = CGFloat(53)
        } else {
            yPos = CGFloat(65)
        }
        self.playView.yayLabelY.constant = yPos
        self.playView.nayLabelY.constant = yPos
        self.playView.layoutIfNeeded()
        
        // play view border thickness
        self.playView.borderThickness.constant = 0.5
        
        // adjust play view for smaller screen
        if IS_IPHONE5() || IS_IPHONE4() {
            adjustPlayViewForSmallerScreen()
        }
    }
    
    // MARK: - Adjust play view for smaller screen
    
    func adjustPlayViewForSmallerScreen() {
        var multiplier: CGFloat!
        if IS_IPHONE5() {
            multiplier = 0.45
        } else {
            multiplier = 0.53
        }
        
        // play price view height
        self.playView.alternatePriceViewHeight = NSLayoutConstraint(item: self.playView.priceView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.playView.playBottomView, attribute: NSLayoutAttribute.Height, multiplier:multiplier, constant: 0)
        self.playView.priceViewHeight.active = false
        self.view.addConstraint(self.playView.alternatePriceViewHeight)
        
        // play likes view height
        self.playView.alternateLikesViewHeight = NSLayoutConstraint(item: self.playView.likesView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.playView.playBottomView, attribute: NSLayoutAttribute.Height, multiplier:multiplier, constant: 0)
        self.playView.likesViewHeight.active = false
        self.view.addConstraint(self.playView.alternateLikesViewHeight)
        
        // small button size (ignore/message)
        var smallButtonEdgeLength: CGFloat!
        if IS_IPHONE5() {
            smallButtonEdgeLength = 45
        } else {
            smallButtonEdgeLength = 35
        }
        self.playView.ignoreButtonWidth.constant = smallButtonEdgeLength
        self.playView.ignoreButtonHeight.constant = smallButtonEdgeLength
        
        self.playView.messageButtonWidth.constant = smallButtonEdgeLength
        self.playView.messageButtonHeight.constant = smallButtonEdgeLength
        
        // large button size (favorite)
        var largeButtonEdgeLength: CGFloat!
        if IS_IPHONE5() {
            largeButtonEdgeLength = 90
        } else {
            largeButtonEdgeLength = 70
        }
        self.playView.favoriteButtonWidth.constant = largeButtonEdgeLength
        self.playView.favoriteButtonHeight.constant = largeButtonEdgeLength
    }
    
    // MARK: - Get listings
    
    func getListings() {
        // show loading view
        showLoadingView()
        
        self.stopwatch.start()
        
        ApiManager.getListings() { listings in
            self.listings = listings
            self.lastFetchedListings = listings
            
            // cache listing neighborhoods
            let listingNeighborhoods = Array(Set(listings.map({ $0.neighborhood })))
            CacheManager.saveListingNeighborhoods(listingNeighborhoods)
            
            // cache amenities
            var amenities = [String]()
            for listing in listings {
                amenities.appendContentsOf(listing.amenitiesList)
            }
            CacheManager.setAmenities(Array(Set(amenities)))
            
            // if logged in, get listing favorites/ignores
            if let loggedInAgentId = UserData.getLoggedInAgentId() {
                ApiManager.getListingFavorites(agentId: loggedInAgentId) { listingFavorites in
                    ApiManager.getListingIgnores() { listingIgnores in
                        CacheManager.saveListingFavorites(listingFavorites)
                        CacheManager.saveListingIgnores(listingIgnores)
                        
                        self.postGetListings()
                    }
                }
            } else {
                self.postGetListings()
            }
        }
    }
    
    // MARK: - Post get listings

    func postGetListings() {
        self.applyFilters(self.filters)
        
        self.stopwatch.stop()
        self.stopwatch.report(label: "load listings")
        
        // remove loading view
        self.removeLoadingView()
    }
    
    // MARK: - Get listing favorites
    
    func getListingFavorites() -> [ListingFavorite] {
        return CacheManager.getListingFavorites()
    }

    // MARK: - Get listing ignores
    
    func getListingIgnores() -> [ListingIgnore] {
        return CacheManager.getListingIgnores()
    }

    // MARK: - Load play listing
    
    func loadPlayListing() {
        // reset play view
        resetPlayView()
        
        // exclude favorited/ignored listings
        let listingFavoriteIds = getListingFavorites().map({ $0.id })
        let listingIgnoreIds = getListingIgnores().map({ $0.id })
        let idsToExclude = listingFavoriteIds + listingIgnoreIds
        
//        print("listing favorite ids: \(listingFavoriteIds)")
//        print("listing ignore ids: \(listingIgnoreIds)")
        
        var subpredicates = [NSPredicate]()
        
        let subpredicate1 = NSPredicate(format: "NOT id IN %@", idsToExclude)
        subpredicates.append(subpredicate1)
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
        
        let playListings = self.listings.filter({ predicate.evaluateWithObject($0) })
        
        // do nothing if no remaining listings to play
        if playListings.count == 0 {
            self.playView.outOfListingsLabel?.hidden = false
            return
        }
        
        let randomListingIndex = Int(arc4random_uniform(UInt32(playListings.count)))
        let playListing = playListings[randomListingIndex]
        self.playView.listing = playListing
        
        let bedText = "\(playListing.bedrooms) Bed"
        let bathText = "\(playListing.bathrooms) Bath"
        let neighborhoodText = playListing.neighborhood != nil ? "(\(playListing.neighborhood.name))" : ""
        
        self.playView.imageView?.setImageWithURL(NSURL(string: playListing.mediumImageURL)!)
        self.playView.imageView?.hidden = false
        self.playView.bedBathNeighborhoodLabel?.text = "\(bedText) / \(bathText) \(neighborhoodText)"
        self.playView.priceLabel?.text = "\(playListing.formattedPrice)"
        self.playView.likesLabel?.text = "\(playListing.heartsCount)"
    }
    
    // MARK: - Refresh play view
    
    func refreshPlayView() {
        if !UserData.isLoggedIn() {
            return
        }
        
        // if currently shown play listing no longer valid (now favorited/ignored via other view), load new one
        if let currentPlayListing = self.playView.listing {
            let listingFavoriteIds = getListingFavorites().map({ $0.id })
            let listingIgnoreIds = getListingIgnores().map({ $0.id })
            let idsToExclude = listingFavoriteIds + listingIgnoreIds
            
            if idsToExclude.contains(currentPlayListing.id) {
                loadPlayListing()
            }
        }
    }
    
    // MARK: - Reset play view
    
    func resetPlayView() {
        self.playView.listing = nil
        self.playView.imageView?.image = UIImage(named: "missing")
        self.playView.imageView?.hidden = true
        self.playView.imageContainerView.center = self.playView.initialImageContainerCenter
        self.playView.yayLabel.hidden = true
        self.playView.nayLabel.hidden = true
        self.playView.outOfListingsLabel?.hidden = true
        self.playView.bedBathNeighborhoodLabel?.text = ""
        self.playView.priceLabel?.text = ""
        self.playView.likesLabel?.text = ""
        self.playView.favoriteButton.selected = false
    }
    
    // MARK: - Reset play view image
    
    func resetPlayViewImage() {
        // return image to original place
        self.playView.imageContainerView.center = self.playView.initialImageContainerCenter
        
        // reset (hide) yay/nay labels
        self.playView.nayLabel.hidden = true
        self.playView.yayLabel.hidden = true
    }
    
    // MARK: - Tap play view image
    
    @IBAction func tapPlayViewImage(sender: UIGestureRecognizer) {
        if let playViewListing = self.playView.listing {
            performSegueWithIdentifier("listingDetail", sender: playViewListing)
        }
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
        
        // end collection view refresh control if visible
        gridCollectionRefreshControl.endRefreshing()
    }
    
    // MARK: - Map view delegate
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if let annotationView = mapView.viewForAnnotation(userLocation) {
            annotationView.canShowCallout = false
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let listingId = annotation.title!
        let listing = self.listings.filter({ $0.id == listingId }).first
        
        let annotationView = MapAnnotationView(annotation:annotation, reuseIdentifier:"listing")
        annotationView.listing = listing
        annotationView.canShowCallout = false
        annotationView.image = UIImage(named: "pin-red")
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        pinSelectCount++
        
        if view.annotation is MKUserLocation {
            return
        }
        
        let annotationView = view as! MapAnnotationView
        annotationView.image = UIImage(named: "pin-black")
        showListingPreview(annotationView.listing)
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        pinSelectCount--
        
        if view.annotation is MKUserLocation {
            return
        }
        
        view.image = UIImage(named: "pin-red")
        hideListingPreview()
    }
    
    // MARK: - Listing preview
    
    func showListingPreview(listing: Listing) {
        /*
         * If the listings api call fails, the user will still see cached listings but their
         * neighborhoods will be nil if the neighborhoods api call [that gets called on launch]
         * succeeded since it clears the old neighborhoods before getting the new ones.
         * As a result, if the neighborhood is nil, show an empty string.
         */
        var neighborhoodPart = ""
        if let neighborhood = listing.neighborhood {
            neighborhoodPart = "/ \(neighborhood.name.uppercaseString)"
        }
        
        listingPreviewView.listing = listing
        listingPreviewView.imageView?.setImageWithURL(NSURL(string: listing.thumbnailURL)!)
        listingPreviewView.priceLabel.text = "\(listing.formattedPrice)"
        listingPreviewView.bedBathNeighborhoodLabel.text = "\(listing.bedrooms) BED  /  \(listing.bathrooms) BATH \(neighborhoodPart)"
        updateListingFavoriteButton(listingPreviewView.favoriteButton, listing: listing)
        
        // skip slide up animation if listing preview already visible
        if !listingPreviewView.hidden {
            return
        }
        
        // slide up
        self.listingPreviewView.hidden = false
        self.listingPreviewDefaultConstraint.active = false
        self.view.addConstraint(self.listingPreviewActiveConstraint)
        UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func hideListingPreview(force: Bool = false) {
        if force {
            listingPreviewView.hidden = true
            return
        }
        
        // Switching between pins on the map does an implicit deselect between the selects. If the preview
        // is already visible and you select another pin, it should just stay where it is and show the info
        // for the updated pin. The delay here along with having a pinSelectCount variable prevents the
        // implicit intermediate deselect from having an effect.
        delay(0.1) {
            if self.pinSelectCount > 0 {
                return
            }
            
            // slide down
            self.view.removeConstraint(self.listingPreviewActiveConstraint)
            self.listingPreviewDefaultConstraint.active = true
            UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }, completion: { finished in
                self.listingPreviewView.hidden = true
            })
        }
    }
    
    // MARK: - Collection view data source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listings.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = gridCollectionView.dequeueReusableCellWithReuseIdentifier("ListingCell", forIndexPath: indexPath)
            as! ListingCollectionViewCell
        let listing = self.listings[indexPath.item]
        cell.listingImageView?.setImageWithURL(NSURL(string: listing.mediumImageURL)!)
        updateListingFavoriteButton(cell.favoriteButton, listing: listing)
        return cell
    }
    
    // MARK: - Collection view delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let listing = self.listings[indexPath.item]
        performSegueWithIdentifier("listingDetail", sender: listing)
    }
    
    // MARK: - Collection view delegate flow layout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let numDesiredColumns: Int!
        if IS_IPAD() {
            numDesiredColumns = 6
        } else {
            numDesiredColumns = 3
        }
        let sectionPadding = gridCollectionViewFlowLayout.sectionInset.left
        let itemPadding = gridCollectionViewFlowLayout.minimumInteritemSpacing
        var width = view.frame.size.width - 2*sectionPadding - CGFloat(numDesiredColumns-1)*itemPadding
        width /= CGFloat(numDesiredColumns)
        // hack for floating point imprecision
        if String(width).endsWith("66666667") {
            width = round(width)
        }
        let height = width
        return CGSizeMake(width, height)
    }
    
    // MARK: - Message (via button on play view)
    
    @IBAction func message(sender: UIButton) {
        let listing = self.playView.listing
        if listing == nil {
            return
        }
        
        let contextURL = "\(SITE_DOMAIN)/listings/\(listing.id)"
        messageAgent(agent: listing.agent, contextURL: contextURL, vc: self)
    }
    
    // MARK: - Favorite (via listing preview, grid view, button on play view, or yay)
    
    @IBAction func favorite(sender: UIButton) {
        if !UserData.isLoggedIn() {
            tabBarController?.selectedIndex = 4
            return
        }
        
        // check if action is from play view
        var fromPlayView = false
        if sender.tag == 1 || sender.tag == 2 {
            fromPlayView = true
        }
        
        var listing: Listing?
        if let listingPreviewView = sender.superview?.superview as? ListingPreviewView {
            listing = listingPreviewView.listing
        } else if let listingCell = sender.superview?.superview?.superview as? ListingCollectionViewCell {
            if let indexPath = gridCollectionView.indexPathForCell(listingCell) {
                listing = self.listings[indexPath.item]
            }
        } else if fromPlayView {
            listing = self.playView.listing
        }
        
        if listing == nil {
            return
        }
        
        sender.selected = !sender.selected
        favoriteListingAction(listing!, favorite: sender.selected)
        
        // update views
        updateListingViews(updateMap: false)
    }
    
    @IBAction func favorite2(sender: UIGestureRecognizer) {
        if sender.state == .Ended {
            let point = sender.locationInView(gridCollectionView)
            if let indexPath = gridCollectionView.indexPathForItemAtPoint(point) {
                let listingGridCell = gridCollectionView.cellForItemAtIndexPath(indexPath) as! ListingCollectionViewCell
                let favoriteButton = listingGridCell.favoriteButton
                favorite(favoriteButton)
            }
        }
    }
    
    // MARK: - Yay
    
    func yay() {
        let button = UIButton()
        button.tag = 2
        favorite(button)
    }
    
    // MARK: - Ignore (via button on play view or nay)
    
    @IBAction func ignore(sender: UIButton) {
        let listing = self.playView.listing
        if listing == nil {
            return
        }
        ignoreListingAction(listing!)
        
        // reapply filters (The reason Ignore has to reapply filters and Favorite doesn't is due to the way
        //                  the filter predicates are written for excluding ids and the fact that Ignore
        //                  needs to remove cells from the grid view while Favorite just has to update existing
        //                  grid view cells.)
        applyFilters(self.filters)
    }
    
    // MARK: - Nay
    
    func nay() {
        let button = UIButton()
        ignore(button)
    }
    
    // MARK: - Play view image drag
    
    @IBAction func playViewImageDrag(recognizer: UIPanGestureRecognizer) {
        if recognizer.state != UIGestureRecognizerState.Ended {
            let translation = recognizer.translationInView(self.view)
            let currentCenter = self.playView.imageContainerCenter
            self.playView.imageContainerView.center = CGPointMake(currentCenter.x + translation.x, currentCenter.y + translation.y)
            
            // show yay/nay depending on how far to the right/left
            if isNay() {
                self.playView.nayLabel.hidden = false
            } else if isYay() {
                self.playView.yayLabel.hidden = false
            } else {
                self.playView.nayLabel.hidden = true
                self.playView.yayLabel.hidden = true
            }
        } else {
            // play view image pan ended (yay/nay drop action)
            
            // check if yay/nay
            if isYay() {
                if isFirstFavoriteListingDrop() {
                    showFavoriteConfirmAlert()
                    return
                } else {
                    yay()
                }
            } else if isNay() {
                if isFirstIgnoreListingDrop() {
                    showIgnoreConfirmAlert()
                    return
                } else {
                    nay()
                }
            }
            resetPlayViewImage()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.playView.imageContainerCenter = self.playView.imageContainerView.center
    }
    
    // MARK: - Yay/Nay check
    
    func isNay() -> Bool {
        let centerPct = self.playView.imageContainerView.center.x / self.view.frame.size.width
        return centerPct < 0.35
    }
    
    func isYay() -> Bool {
        let centerPct = self.playView.imageContainerView.center.x / self.view.frame.size.width
        return centerPct > 0.65
    }
    
    // MARK: - Show favorite confirm alert
    
    func showFavoriteConfirmAlert() {
        let alert = UIAlertController(title: "Favorite?", message: "Dragging a listing's picture to the right will favorite it.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { action in
            self.resetPlayViewImage()
            })
        alert.addAction(UIAlertAction(title: "Favorite", style: UIAlertActionStyle.Default) { action in
            self.yay()
            })
        self.presentViewController(alert, animated: true, completion: nil)
        
        markFirstFavoriteListingDrop()
    }
    
    // MARK: - Show ignore confirm alert
    
    func showIgnoreConfirmAlert() {
        let alert = UIAlertController(title: "Hide?", message: "Dragging a listing's picture to the left will remove it from the map/grid view.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { action in
            self.resetPlayViewImage()
            })
        alert.addAction(UIAlertAction(title: "Hide", style: UIAlertActionStyle.Default) { action in
            self.nay()
            })
        self.presentViewController(alert, animated: true, completion: nil)
        
        markFirstIgnoreListingDrop()
    }
    
    // MARK: - Focus to neighborhood center
    
    func focusToNeighborhoodCenter(neighborhood: Neighborhood) {
        // pop off detail view if shown
        navigationController?.popToRootViewControllerAnimated(false)
        
        // switch to map view
        self.sliderTabBarView.selectTabWithIndex(0)
        
        let latitude = neighborhood.latitude
        let longitude = neighborhood.longitude
        
        let neighborhoodCenter = CLLocationCoordinate2DMake(latitude, longitude)
        let focusedLocationDistance = 4500.0
        
        let region = MKCoordinateRegionMakeWithDistance(neighborhoodCenter, focusedLocationDistance, focusedLocationDistance)
        mapView.region = region
    }
    
    // MARK: - Post filter on subway line
    
    func postFilterOnSubwayLine() {
        // pop off detail view if shown
        navigationController?.popToRootViewControllerAnimated(false)
        
        // switch to map view
        self.sliderTabBarView.selectTabWithIndex(0)
    }
    
    // MARK: - Filters delegate
    
    func applyFilters(filters: Filters) {
        self.filters = filters as! ListingFilters
        
        var subpredicates = [NSPredicate]()
        
        // price
        let subpredicate1 = NSPredicate(format: "price BETWEEN %@", [self.filters.startPrice ?? 0, self.filters.endPrice ?? Int.max])
        subpredicates.append(subpredicate1)
        
        // beds
        if self.filters.beds.count > 0 {
            let subpredicate2String = self.filters.beds.indexOf(5) != nil ? "bedrooms IN %@ OR bedrooms >= 5" : "bedrooms IN %@"
            let subpredicate2 = NSPredicate(format: subpredicate2String, self.filters.beds)
            subpredicates.append(subpredicate2)
        }
        
        // baths
        if self.filters.baths.count > 0 {
            let subpredicate3String = self.filters.baths.indexOf(5) != nil ? "bathrooms IN %@ OR bathrooms >= 5" : "bathrooms IN %@"
            let subpredicate3 = NSPredicate(format: subpredicate3String, self.filters.baths)
            subpredicates.append(subpredicate3)
        }
        
        // neighborhoods
        if self.filters.neighborhoodIds.count > 0 {
            let subpredicate4 = NSPredicate(format: "neighborhood.id IN %@", self.filters.neighborhoodIds)
            subpredicates.append(subpredicate4)
        }
        
        // subway lines
        if let subwayLineFilter = self.filters.subwayLine {
            let subpredicate5 = NSPredicate(format: "subwayLines CONTAINS %@", subwayLineFilter)
            subpredicates.append(subpredicate5)
        }
        
        // amenities
        if self.filters.amenities.count > 0 {
            let subpredicate6 = NSPredicate(format: "ALL %@ IN amenitiesList", self.filters.amenities)
            subpredicates.append(subpredicate6)
        }
        
        // restrictions (default is whatever's returned by api minus ignored)
        if !self.filters.restrictions.isEmpty {
            var restrictionSubpredicates = [NSPredicate]()
            
            // favorited
            if self.filters.restrictions.contains(.Favorited) {
                let listingFavoriteIds = getListingFavorites().map({ $0.id })
                let favoriteSubpredicate = NSPredicate(format: "id IN %@", listingFavoriteIds)
                restrictionSubpredicates.append(favoriteSubpredicate)
            }
            
            // ignored
            if self.filters.restrictions.contains(.Ignored) {
                let listingIgnoreIds = getListingIgnores().map({ $0.id })
                let ignoreSubpredicate = NSPredicate(format: "id IN %@", listingIgnoreIds)
                restrictionSubpredicates.append(ignoreSubpredicate)
            }
            
            let restrictionPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: restrictionSubpredicates)
            subpredicates.append(restrictionPredicate)
        } else {
            // exclude ignored
            let listingIgnoreIds = getListingIgnores().map({ $0.id })
            let ignoreSubpredicate = NSPredicate(format: "NOT id IN %@", listingIgnoreIds)
            subpredicates.append(ignoreSubpredicate)
        }
        
        let finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
        self.listings = self.lastFetchedListings.filter({ finalPredicate.evaluateWithObject($0) })
        
        print("listings: \(self.listings.count)")
        
        updateListingViews()
    }
    
    func resetGridScroll() {
        gridCollectionView.setContentOffset(CGPointZero, animated: false)
    }
    
    // MARK: - Update listing views
    
    func updateListingViews(updateMap updateMap: Bool = true) {
        // map
        if updateMap {
            updateMapMarkers()
        }
        
        // grid
        gridCollectionView.reloadData()
        
        // play
        loadPlayListing()
    }
    
    func updateMapMarkers() {
        // clear markers [except user location]
        let annotationsToRemove = mapView.annotations.filter({ $0 !== self.mapView.userLocation })
        mapView.removeAnnotations(annotationsToRemove)
        
        for listing: Listing in self.listings {
            let marker = MKPointAnnotation()
            marker.coordinate = CLLocationCoordinate2DMake(listing.latitude, listing.longitude)
            marker.title = listing.id
            mapView.addAnnotation(marker)
        }
    }
    
    // MARK: - Location manager
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        lastLocation = locationObj
    }

    // MARK: - Go to listing detail
    
    @IBAction func goToListingDetail(sender: UIGestureRecognizer) {
        if sender.state == .Ended {
            let listingPreview = sender.view as! ListingPreviewView
            performSegueWithIdentifier("listingDetail", sender: listingPreview.listing)
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "filter" {
            let nc = segue.destinationViewController as! UINavigationController
            let filterViewController = nc.viewControllers[0] as! FiltersViewController
            filterViewController.delegate = self
            filterViewController.type = FilterType.Listings
            filterViewController.filters = filters
            
            // the filter segue overlaps navigation bar so hide titleView and Filter button
            navigationItem.rightBarButtonItem?.title = ""
            navigationItem.titleView?.hidden = true
        } else if segue.identifier == "listingDetail" {
            let vc = segue.destinationViewController as! ListingDetailTableViewController
            let listing = sender as! Listing
            vc.listing = listing
        }
    }
}

// MARK: - Map Annotation View

class MapAnnotationView: MKAnnotationView {
    var listing: Listing!
}

// MARK: - Listing Preview View

class ListingPreviewView: UIView {
    var listing: Listing!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var bedBathNeighborhoodLabel: UILabel!
    @IBOutlet var favoriteButton: UIButton!
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = touches.first as UITouch? {
            self.backgroundColor = UIColor.lightGrayColor()
        }
        super.touchesBegan(touches, withEvent:event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = touches.first as UITouch? {
            self.backgroundColor = UIColor.whiteColor()
        }
        super.touchesEnded(touches, withEvent:event)
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if let _ = touches!.first as UITouch? {
            self.backgroundColor = UIColor.whiteColor()
        }
        super.touchesCancelled(touches, withEvent:event)
    }
}

// MARK: - Listing Collection View Cell

class ListingCollectionViewCell: UICollectionViewCell {
    @IBOutlet var listingImageView: UIImageView!
    @IBOutlet var favoriteButton: UIButton!
}

// MARK: - Play Listing View

class PlayListingView: UIView {
    // listing
    var listing: Listing!
    
    // top view
    @IBOutlet var playTopView: UIView!
    @IBOutlet var imageContainerView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var yayLabel: UILabel!
    @IBOutlet var nayLabel: UILabel!
    @IBOutlet var outOfListingsLabel: UILabel!
    @IBOutlet var bedBathNeighborhoodLabel: UILabel!
    
    @IBOutlet var borderThickness: NSLayoutConstraint!
    @IBOutlet var yayLabelY: NSLayoutConstraint!
    @IBOutlet var nayLabelY: NSLayoutConstraint!
    var imageContainerCenter = CGPointMake(0, 0)
    var initialImageContainerCenter = CGPointMake(0, 0)
    
    // bottom view
    @IBOutlet var playBottomView: UIView!
    @IBOutlet var priceView: UIView!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var likesView: UIView!
    @IBOutlet var likesLabel: UILabel!
    
    @IBOutlet var ignoreButton: UIButton!
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var messageButton: UIButton!
    
    // price view height
    @IBOutlet var priceViewHeight: NSLayoutConstraint!
    var alternatePriceViewHeight: NSLayoutConstraint!
    
    // likes view height
    @IBOutlet var likesViewHeight: NSLayoutConstraint!
    var alternateLikesViewHeight: NSLayoutConstraint!
    
    // button sizes
    @IBOutlet var ignoreButtonWidth: NSLayoutConstraint!
    @IBOutlet var ignoreButtonHeight: NSLayoutConstraint!
    
    @IBOutlet var favoriteButtonWidth: NSLayoutConstraint!
    @IBOutlet var favoriteButtonHeight: NSLayoutConstraint!
    
    @IBOutlet var messageButtonWidth: NSLayoutConstraint!
    @IBOutlet var messageButtonHeight: NSLayoutConstraint!
}
