//
//  NeighborhoodLocationsViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 11/19/15.
//  Copyright © 2016 Nooklyn. All rights reserved.
//

import UIKit
import MapKit

class NeighborhoodLocationsViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegateFlowLayout,
                                           UICollectionViewDataSource, SliderTabBarViewDelegate {
    
    // slider tab bar
    @IBOutlet var sliderTabBarView: SliderTabBarView!
    @IBOutlet var sliderTabBarButton1: UIButton!
    @IBOutlet var sliderTabBarButton2: UIButton!
    @IBOutlet var sliderTabBarButton1Width: NSLayoutConstraint!
    @IBOutlet var sliderTabBarButton2Width: NSLayoutConstraint!
    @IBOutlet var sliderTabBarInitialConstraint: NSLayoutConstraint!
    
    // map view
    @IBOutlet var mapView: MKMapView!
    
    // grid view
    @IBOutlet var gridCollectionView: UICollectionView!
    @IBOutlet var gridCollectionViewFlowLayout: UICollectionViewFlowLayout!
    var gridCollectionRefreshControl: UIRefreshControl!
    
    // loading view
    @IBOutlet var loadingView: LoadingView!
    
    var neighborhood: Neighborhood!
    var locationCategory: LocationCategory!
    var locations = [Location]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set locations
        filterAndSortLocations(self.neighborhood.locations)
        
        // navigation bar
        customizeNavigationBar()
        
        // show location category name at the top
        navigationItem.titleView = nil
        self.title = "\(self.neighborhood.name) - \(self.locationCategory.name)"
        
        // slider tab bar
        setupSliderTabBarView()
        
        // map view
        var distance = 7000.0
        if IS_IPAD() {
            distance = 3000.0
        }
        let mapCenter = CLLocationCoordinate2DMake(neighborhood.latitude, neighborhood.longitude)
        let region = MKCoordinateRegionMakeWithDistance(mapCenter, distance, distance)
        mapView.region = region
        mapView.showsUserLocation = true
        
        // grid view
        
        // add pull to refresh grid view
        gridCollectionRefreshControl = UIRefreshControl()
        gridCollectionRefreshControl.addTarget(self, action: "getNeighborhoodLocations", forControlEvents: UIControlEvents.ValueChanged)
        gridCollectionView.addSubview(gridCollectionRefreshControl)
        gridCollectionView.alwaysBounceVertical = true
        
        // get neighborhood locations
        getNeighborhoodLocations()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateViews()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("NeighborhoodLocations")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Filter and sort locations
    
    func filterAndSortLocations(locations: [Location]) {
        self.locations = locations.filter({ $0.category!.id == self.locationCategory.id }).sort({
            $0.name.localizedCaseInsensitiveCompare($1.name) == NSComparisonResult.OrderedAscending
        })
    }
    
    // MARK: - Setup slider tab bar view
    
    func setupSliderTabBarView() {
        self.sliderTabBarView.buttons = [self.sliderTabBarButton1, self.sliderTabBarButton2]
        self.sliderTabBarView.buttonWidthConstraints = [self.sliderTabBarButton1Width, self.sliderTabBarButton2Width]
        self.sliderTabBarView.contentViews = [self.gridCollectionView, self.mapView]
        self.sliderTabBarView.analyticsViewNames = ["Locations#Grid", "Locations#Map"]
        self.sliderTabBarView.centerConstraints = [self.sliderTabBarInitialConstraint]
        self.sliderTabBarView.delegate = self
        
        self.sliderTabBarView.initialize()
    }
    
    // MARK: - Get neighborhood locations
    
    func getNeighborhoodLocations() {
        // show loading view
        showLoadingView()
        
        ApiManager.getNeighborhoodLocations(neighborhoodId: self.neighborhood.id, locationCategoryId: locationCategory.id) { locations in
            self.filterAndSortLocations(locations)
            
            // reload
            self.updateViews()
            
            // remove loading view
            self.removeLoadingView()
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
        
        var annotationView: MKAnnotationView!
        
        if let locationAnnotation = annotation as? LocationPointAnnotation {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "location")
            annotationView.canShowCallout = true
            
            // left callout accessory view
            let imageView = UIImageView(frame: CGRectMake(0, 0, 50, 50))
            imageView.setImageWithURL(NSURL(string: locationAnnotation.location.thumbnailURL)!)
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            annotationView.leftCalloutAccessoryView = imageView
            
            annotationView.image = UIImage(named: "pin-green")
            
            // right callout accessory view
            annotationView.rightCalloutAccessoryView = UIButton(type: .InfoDark)
        }
        return annotationView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if view.annotation is MKUserLocation {
            return
        }
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        if view.annotation is MKUserLocation {
            return
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = (view.annotation as! LocationPointAnnotation).location
        performSegueWithIdentifier("locationDetail", sender: location)
    }
    
    // MARK: - Collection view data source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.locations.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = gridCollectionView.dequeueReusableCellWithReuseIdentifier("NeighborhoodLocationCell", forIndexPath: indexPath)
            as! NeighborhoodLocationCollectionViewCell
        let location = self.locations[indexPath.item]
        cell.locationImageView?.setImageWithURL(NSURL(string: location.mediumImageURL)!)
        updateLocationFavoriteButton(cell.favoriteButton, location: location)
        return cell
    }
    
    // MARK: - Collection view delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let location = self.locations[indexPath.item]
        performSegueWithIdentifier("locationDetail", sender: location)
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
        if String(width).endsWith("66666667") {  // hack for floating point imprecision
            width = round(width)
        }
        let height = width
        return CGSizeMake(width, height)
    }
    
    // MARK: - Update views
    
    func updateViews() {
        // map
        updateMapMarkers()
        
        // grid
        gridCollectionView.reloadData()
    }
    
    // MARK: - Update map markers
    
    func updateMapMarkers() {
        // clear markers [except user location]
        let annotationsToRemove = mapView.annotations.filter({ $0 !== self.mapView.userLocation })
        mapView.removeAnnotations(annotationsToRemove)
        
        for location in self.locations {
            let marker = LocationPointAnnotation()
            marker.location = location
            marker.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            marker.title = location.name
            mapView.addAnnotation(marker)
        }
    }
    
    // MARK: - Favorite
    
    @IBAction func favorite(sender: UIButton) {
        if !UserData.isLoggedIn() {
            tabBarController?.selectedIndex = 4
            return
        }
        
        if let locationCell = sender.superview?.superview?.superview as? NeighborhoodLocationCollectionViewCell {
            if let indexPath = gridCollectionView.indexPathForCell(locationCell) {
                let location = self.locations[indexPath.item]
                sender.selected = !sender.selected
                favoriteLocationAction(location, favorite: sender.selected)
            }
        }
    }
    
    @IBAction func favorite2(sender: UIGestureRecognizer) {
        if sender.state == .Ended {
            let point = sender.locationInView(gridCollectionView)
            if let indexPath = gridCollectionView.indexPathForItemAtPoint(point) {
                let locationCell = gridCollectionView.cellForItemAtIndexPath(indexPath) as! NeighborhoodLocationCollectionViewCell
                let favoriteButton = locationCell.favoriteButton
                favorite(favoriteButton)
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "locationDetail" {
            let location = sender as! Location
            let vc = segue.destinationViewController as! LocationDetailTableViewController
            vc.location = location
        }
    }
}

// MARK: - Neighborhood location collection view cell

class NeighborhoodLocationCollectionViewCell: UICollectionViewCell {
    @IBOutlet var locationImageView: UIImageView!
    @IBOutlet var favoriteButton: UIButton!
}
