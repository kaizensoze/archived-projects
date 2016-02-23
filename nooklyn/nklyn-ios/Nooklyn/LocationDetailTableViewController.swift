//
//  LocationDetailTableViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 8/16/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

import UIKit
import MapKit

class LocationDetailTableViewController: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
                                         MKMapViewDelegate {

    var location: Location!
    var rows = ["Image", "Name", "Description", "Location", "Address"]
    
    var favoriteButton: UIButton?
    
    var photos = [LocationPhoto]()
    var photosCollectionView: UICollectionView?
    var photosCollectionViewHeight: NSLayoutConstraint?
    var photosCollectionViewHeightVal: CGFloat?
    
    var nearbyLocations = [Location]()
    var nearbyListings = [Listing]()
    var mapViewCell: LocationLocationTableViewCell!
    var locationMapView: MKMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar
        customizeNavigationBar()
        
        tableView.estimatedRowHeight = 200.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        getPhotos() {
            self.getNearbyLocationsAndListings()
        }
        
        print("location: \(location.id)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // update favorite button
        if let favoriteButton = self.favoriteButton {
            updateLocationFavoriteButton(favoriteButton, location: self.location)
        }
        
        // refresh nearby locations/listings
        refreshNearbyLocationsAndListings()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("Location")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Get photos
    
    func getPhotos(completion: (Void -> Void)?) {
        ApiManager.getLocationPhotos(location: self.location) { photos in
            self.photos = photos
            
            // show photos row
            if !self.rows.contains("Photos") && self.photos.count > 0 {
                self.rows.insert("Photos", atIndex: 3)
                self.tableView.reloadData()
                
                // adjust photos collection view height to fit content
                let minLineSpacing = 7
                let itemSpacing = 7
                let sidePadding = 37
                // HACK: Manual calculation.
                let photoHeight = (self.tableView.frame.size.width - (2 * CGFloat(sidePadding)) - CGFloat(itemSpacing)) / 2
                let numPhotos = ceil(CGFloat(self.photos.count) / 2)
                let newHeight = (numPhotos * CGFloat(photoHeight)) + ((numPhotos - 1) * CGFloat(minLineSpacing))
                self.photosCollectionViewHeightVal = CGFloat(newHeight)
                self.photosCollectionViewHeight?.constant = self.photosCollectionViewHeightVal!
                
                // reload
                self.photosCollectionView?.reloadData()
                self.tableView.reloadData()
            }
            completion?()
        }
    }
    
    // MARK: - Get nearby locations/listings
    
    func getNearbyLocationsAndListings() {
        // get nearby locations
        ApiManager.getNearbyLocations(latitude: location.latitude, longitude: location.longitude) { locations in
            self.nearbyLocations = locations
            
            // force update of map view cell
            if let _ = self.mapViewCell {
                self.mapViewCell.addNearbyLocations = true
            }
            self.reloadLocationTableViewCell()
        }
        
        // get nearby listings
        ApiManager.getNearbyListings(latitude: location.latitude, longitude: location.longitude) { listings in
            self.nearbyListings = listings
            
            // force update of map view cell
            if let _ = self.mapViewCell {
                self.mapViewCell.addNearbyListings = true
            }
            self.reloadLocationTableViewCell()
        }
    }
    
    // MARK: - Refresh nearby locations/listings
    
    func refreshNearbyLocationsAndListings() {
        if let mapView = self.locationMapView {
            // clear markers [except user location]
            let annotationsToRemove = mapView.annotations.filter({ $0 !== mapView.userLocation })
            mapView.removeAnnotations(annotationsToRemove)
            
            // nearby locations
            for location in nearbyLocations {
                let marker = LocationPointAnnotation()
                marker.location = location
                marker.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                marker.title = location.name
                mapView.addAnnotation(marker)
            }
            
            // nearby listings
            for listing in nearbyListings {
                let marker = ListingPointAnnotation()
                marker.listing = listing
                marker.coordinate = CLLocationCoordinate2DMake(listing.latitude, listing.longitude)
                marker.title = "\(listing.formattedPrice) / \(listing.bedrooms) Bed"
                mapView.addAnnotation(marker)
            }
        }
    }
    
    // MARK: - Reload location table view cell
    
    func reloadLocationTableViewCell() {
        let indexPath = NSIndexPath(forRow: self.rows.indexOf("Location")!, inSection: 0)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
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
            let thisCell = tableView.dequeueReusableCellWithIdentifier("LocationImageCell", forIndexPath: indexPath) as! LocationImageTableViewCell
            thisCell.locationImageView?.setImageWithURL(NSURL(string: location.imageURL)!)
            // one-time image height adjust for iphone 4/5
            if (IS_IPHONE4() || IS_IPHONE5()) && !thisCell.locationImageViewHeightSet {
                thisCell.locationImageViewHeight.constant = 320
                thisCell.locationImageViewHeightSet = true
            }
            updateLocationFavoriteButton(thisCell.favoriteButton, location: self.location)
            self.favoriteButton = thisCell.favoriteButton
            cell = thisCell
        case "Name":
            let thisCell = tableView.dequeueReusableCellWithIdentifier("LocationNameCell", forIndexPath: indexPath) as! LocationNameTableViewCell
            thisCell.nameLabel.text = location.name
            thisCell.borderThickness.constant = 0.5
            cell = thisCell
        case "Description":
            let thisCell = tableView.dequeueReusableCellWithIdentifier("LocationDescriptionCell", forIndexPath: indexPath) as! LocationDescriptionTableViewCell
            thisCell.descriptionLabel.setAttributedTextOnly(location._description)
            cell = thisCell
        case "Photos":
            let thisCell = tableView.dequeueReusableCellWithIdentifier("LocationPhotosCell", forIndexPath: indexPath) as! LocationPhotosTableViewCell
            photosCollectionView = thisCell.photosCollectionView
            photosCollectionViewHeight = thisCell.photosCollectionViewHeight
            if let heightVal = self.photosCollectionViewHeightVal {
                if photosCollectionViewHeight?.constant == 0 {
                    photosCollectionViewHeight?.constant = heightVal
                    self.photosCollectionView?.reloadData()
                }
            }
            cell = thisCell
        case "Location":
            let thisCell = tableView.dequeueReusableCellWithIdentifier("LocationLocationCell", forIndexPath: indexPath) as! LocationLocationTableViewCell
            if !thisCell.mapInitialized {
                var distance = 600.0
                if IS_IPAD() {
                    distance = 250.0
                }
                
                let mapCenter = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                let region = MKCoordinateRegionMakeWithDistance(mapCenter, distance, distance)
                thisCell.mapView.region = region
                thisCell.mapView.showsUserLocation = true
                thisCell.mapInitialized = true
                
                self.locationMapView = thisCell.mapView
            }
            if thisCell.addNearbyLocations {
                refreshNearbyLocationsAndListings()
                thisCell.addNearbyLocations = false
            }
            if thisCell.addNearbyListings {
                refreshNearbyLocationsAndListings()
                thisCell.addNearbyListings = false
            }
            mapViewCell = thisCell
            cell = thisCell
        case "Address":
            let thisCell = tableView.dequeueReusableCellWithIdentifier("LocationAddressCell", forIndexPath: indexPath) as! LocationAddressTableViewCell
            thisCell.addressTextView.text = location.address
            thisCell.addressTextView.contentInset = UIEdgeInsetsMake(-8, -4, 0, 0)
            
            thisCell.border1Thickness.constant = 0.5
            thisCell.border2Thickness.constant = 0.5
            
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
        if collectionView == photosCollectionView {
            return photos.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let item = indexPath.item
        var cell: UICollectionViewCell!
        if collectionView == photosCollectionView {
            let thisCell = collectionView.dequeueReusableCellWithReuseIdentifier("LocationPhotoCell", forIndexPath: indexPath) as! LocationPhotosCollectionViewCell
            let locationPhoto = photos[item]
            thisCell.photoImageView?.setImageWithURL(NSURL(string: locationPhoto.thumbnailURL)!)
            cell = thisCell
        }
        return cell
    }
    
    // MARK: - Collection view delegate flow layout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView == photosCollectionView {
            let numDesiredColumns = 2
            let itemSpacing = 7
            let width = (collectionView.frame.size.width - CGFloat(itemSpacing)) / CGFloat(numDesiredColumns)
            let height = width
            return CGSizeMake(width, height)
        }
        return CGSizeMake(0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    // MARK: - Address tapped
    
    @IBAction func addressTapped(sender: UIGestureRecognizer) {
        let oneLineAddress = self.location.oneLineAddress
        let escapedOneLineAddress = oneLineAddress.stringByAddingPercentEncodingWithAllowedCharacters(
            .URLQueryAllowedCharacterSet())!
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
        
        // open in apple maps
        alert.addAction(UIAlertAction(title: "Open in Apple Maps", style: UIAlertActionStyle.Default) { action in
            let appleMapsString = "http://maps.apple.com/?daddr=\(escapedOneLineAddress)"
            UIApplication.sharedApplication().openURL(NSURL(string: appleMapsString)!)
        })
        
        // open in google maps [if available]
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!) {
            alert.addAction(UIAlertAction(title: "Open in Google Maps", style: UIAlertActionStyle.Default) { action in
                let googleMapsString = "comgooglemaps://?daddr=\(escapedOneLineAddress)"
                UIApplication.sharedApplication().openURL(NSURL(string: googleMapsString)!)
            })
        }
        
        // copy to clipboard
        alert.addAction(UIAlertAction(title: "Copy", style: UIAlertActionStyle.Default) { action in
            UIPasteboard.generalPasteboard().string = oneLineAddress
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
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
            
            // for non-current location pin, show as green pin with, otherwise black
            if locationAnnotation.location.id != self.location.id {
                annotationView.image = UIImage(named: "pin-green")
                annotationView.rightCalloutAccessoryView = UIButton(type: .InfoDark)
            } else {
                annotationView.image = UIImage(named: "pin-black")
                annotationView.leftCalloutAccessoryView = nil
                
                locationAnnotation.title = self.location.name
            }
        } else if let listingAnnotation = annotation as? ListingPointAnnotation {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "listing")
            annotationView.canShowCallout = true
            
            // left callout accessory view
            let imageView = UIImageView(frame: CGRectMake(0, 0, 50, 50))
            imageView.setImageWithURL(NSURL(string: listingAnnotation.listing.thumbnailURL)!)
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            annotationView.leftCalloutAccessoryView = imageView
            
            annotationView.image = UIImage(named: "pin-red")
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
        if let locationAnnotation = view.annotation as? LocationPointAnnotation {
            let location = locationAnnotation.location
            self.location = location
            self.reloadView()
        } else if let listingAnnotation = view.annotation as? ListingPointAnnotation {
            performSegueWithIdentifier("listingDetail", sender: listingAnnotation.listing)
        }
    }
    
    // MARK: - Reload view
    
    func reloadView() {
        self.tableView.setContentOffset(CGPointZero, animated: false)
        
        // re-initialize view with no photos row
        let photosRowIndex = self.rows.indexOf("Photos")
        if let index = photosRowIndex {
            self.rows.removeAtIndex(index)
        }

        getPhotos() {
            self.tableView.reloadData()
            self.getNearbyLocationsAndListings()
        }
    }
    
    // MARK: - Favorite
    
    @IBAction func favorite(sender: UIButton) {
        if !UserData.isLoggedIn() {
            tabBarController?.selectedIndex = 4
            return
        }
        
        sender.selected = !sender.selected
        favoriteLocationAction(self.location, favorite: sender.selected)
    }
    
    @IBAction func favorite2(sender: UIGestureRecognizer) {
        if sender.state == .Ended {
            let point = sender.locationInView(tableView)
            if let indexPath = tableView.indexPathForRowAtPoint(point) {
                let imageCell = tableView.cellForRowAtIndexPath(indexPath) as! LocationImageTableViewCell
                let favoriteButton = imageCell.favoriteButton
                favorite(favoriteButton)
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "photos" {
            let cell = sender as! LocationPhotosCollectionViewCell
            let indexPath = photosCollectionView!.indexPathForCell(cell)
            
            let vc = segue.destinationViewController as! PhotosViewController
            vc.photos = self.photos
            vc.photoIndex = indexPath!.row
        } else if segue.identifier == "listingDetail" {
            let vc = segue.destinationViewController as! ListingDetailTableViewController
            let listing = sender as! Listing
            vc.listing = listing
        }
    }
}

// MARK: - Table view cells

// Image
class LocationImageTableViewCell: UITableViewCell {
    @IBOutlet var locationImageView: UIImageView!
    @IBOutlet var locationImageViewHeight: NSLayoutConstraint!
    var locationImageViewHeightSet: Bool = false
    @IBOutlet var favoriteButton: UIButton!
}

// Name
class LocationNameTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var borderThickness: NSLayoutConstraint!
}

// Description
class LocationDescriptionTableViewCell: UITableViewCell {
    @IBOutlet var descriptionLabel: UILabel!
}

// Photos
class LocationPhotosTableViewCell: UITableViewCell {
    @IBOutlet var photosCollectionView: UICollectionView!
    @IBOutlet var photosCollectionViewHeight: NSLayoutConstraint!
}

// Location
class LocationLocationTableViewCell: UITableViewCell {
    @IBOutlet var mapView: MKMapView!
    var mapInitialized = false
    var addNearbyLocations = true
    var addNearbyListings = true
}

// Address
class LocationAddressTableViewCell: UITableViewCell {
    @IBOutlet var addressTextView: UITextView!
    @IBOutlet var border1Thickness: NSLayoutConstraint!
    @IBOutlet var border2Thickness: NSLayoutConstraint!
}

// MARK: - Collection view cells

// Photos
class LocationPhotosCollectionViewCell: UICollectionViewCell {
    @IBOutlet var photoImageView: UIImageView!
}
