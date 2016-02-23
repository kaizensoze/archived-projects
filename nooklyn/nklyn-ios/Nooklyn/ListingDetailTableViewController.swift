//
//  ListingDetailTableViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 6/24/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

import UIKit
import MapKit

class ListingDetailTableViewController: UITableViewController, UICollectionViewDataSource,
                                        UICollectionViewDelegateFlowLayout, MKMapViewDelegate {
    
    var listing: Listing!
    
    var rows = ["Image", "Info", "Description", "Amenities", "Photos", "Location", "Transit", "Contact"]
    
    var listingImageView: UIImageView!
    var favoriteButton: UIButton?
    
    var amenities = [String]()
    var amenitiesCollectionView: UICollectionView?
    
    var photos = [ListingPhoto]()
    var photosCollectionView: UICollectionView?
    var photosCollectionViewHeight: NSLayoutConstraint?
    var photosCollectionViewHeightVal: CGFloat?
    
    var nearbyLocations = [Location]()
    var nearbyListings = [Listing]()
    var mapViewCell: ListingDetailLocationTableViewCell!
    var locationMapView: MKMapView?
    
    var subwayLines = [String]()
    var subwayLinesCollectionView: UICollectionView?
    
    var adminRows = ["ID", "Address", "Apartment", "Access", "Listing Agent", "Date", "Term"]
    var adminRowData = [String: String]()
    var adminTableViewCell: ListingDetailAdminTableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar
        customizeNavigationBar()
        
        amenities = listing.amenitiesList
        subwayLines = listing.subwayLinesList
        
        tableView.estimatedRowHeight = 182.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // get photos, then nearby locations/listings
        getPhotos() {
            self.getNearbyLocationsAndListings()
        }
        
        print("listing: \(listing.id)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // update favorite button
        if let favoriteButton = self.favoriteButton {
            updateListingFavoriteButton(favoriteButton, listing: self.listing)
        }
        
        // refresh nearby locations
        refreshNearbyLocationsAndListings()
        
        // update admin info row
        updateAdminRow()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("ListingDetail")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Get photos
    
    func getPhotos(completion: (Void -> Void)?) {
        ApiManager.getListingPhotos(listing: self.listing) { photos in
            // sort listing photos by featured, id
            self.photos = photos.sort({
                switch ($0.featured, $1.featured) {
                case let (lhs, rhs) where lhs == rhs:
                    return $0.id < $1.id
                case let (lhs, rhs):
                    return lhs && !rhs
                }
            })
            
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
            
            completion?()
        }
    }
    
    // MARK: - Get nearby locations/listings
    
    func getNearbyLocationsAndListings() {
        // get nearby locations
        ApiManager.getNearbyLocations(latitude: listing.latitude, longitude: listing.longitude) { locations in
            self.nearbyLocations = locations
            
            // force update of map view cell
            if let _ = self.mapViewCell {
                self.mapViewCell.addNearbyLocations = true
            }
            self.reloadLocationTableViewCell()
        }
        
        // get nearby listings
        ApiManager.getNearbyListings(latitude: listing.latitude, longitude: listing.longitude) { listings in
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
    
    // MARK: - Update admin info row
    
    func updateAdminRow() {
        self.rows.removeObject("Admin")
        if UserData.loggedInAgentIsEmployee() {
            self.adminRowData = [
                "ID": self.listing.id,
                "Address": !self.listing.address.isEmpty ? self.listing.address : "N/A",
                "Apartment": !self.listing.apartment.isEmpty ? self.listing.apartment : "N/A",
                "Access": !self.listing.access.isEmpty ? self.listing.access : "N/A",
                "Listing Agent": !self.listing.listingAgentName.isEmpty ? self.listing.listingAgentName : "N/A",
                "Term": !self.listing.term.isEmpty ? self.listing.term : "N/A",
                "Date": !self.listing.dateAvailable.isEmpty ? self.listing.dateAvailable : "N/A"
            ]
            self.rows.append("Admin")
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return rows.count
        } else if tableView == self.adminTableViewCell?.adminTableView {
            return adminRows.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = indexPath.row
        var cell: UITableViewCell!
        if tableView == self.adminTableViewCell?.adminTableView {
            let rowLabel = adminRows[row]
            
            let thisCell = tableView.dequeueReusableCellWithIdentifier("ListingAdminInfoCell", forIndexPath: indexPath) as! ListingAdminInfoTableViewCell
            thisCell.myTextLabel?.text = rowLabel
            thisCell.myDetailTextLabel?.text = self.adminRowData[rowLabel]
            
            cell = thisCell
        } else {
            let rowLabel = rows[row]
            switch rowLabel {
            case "Image":
                let thisCell = tableView.dequeueReusableCellWithIdentifier("ListingDetailImageCell", forIndexPath: indexPath) as! ListingDetailImageTableViewCell
                thisCell.listingImageView?.setImageWithURL(NSURL(string: listing.imageURL)!)
                listingImageView = thisCell.listingImageView
                // one-time image height adjust for iphone 4/5
                if (IS_IPHONE4() || IS_IPHONE5()) && !thisCell.listingImageViewHeightSet {
                    thisCell.listingImageViewHeight.constant = 300
                    thisCell.listingImageViewHeightSet = true
                }
                thisCell.listingPriceLabel?.text = listing.formattedPrice
                updateListingFavoriteButton(thisCell.favoriteButton, listing: self.listing)
                self.favoriteButton = thisCell.favoriteButton
                cell = thisCell
            case "Info":
                let thisCell = tableView.dequeueReusableCellWithIdentifier("ListingDetailInfoCell", forIndexPath: indexPath) as! ListingDetailInfoTableViewCell
                thisCell.neighborhoodLabel?.text = listing?.neighborhood?.name
                thisCell.bedLabel?.text = String(listing.bedrooms)
                thisCell.bathLabel?.text = String(listing.bathrooms)
                thisCell.border1Thickness.constant = 0.5
                thisCell.border2Thickness.constant = 0.5
                thisCell.border3Thickness.constant = 0.5
                cell = thisCell
            case "Description":
                let thisCell = tableView.dequeueReusableCellWithIdentifier("ListingDetailDescriptionCell", forIndexPath: indexPath) as! ListingDetailDescriptionTableViewCell
                thisCell.descriptionLabel.setAttributedTextOnly(listing.listingDescription)
                cell = thisCell
            case "Amenities":
                let thisCell = tableView.dequeueReusableCellWithIdentifier("ListingDetailAmenitiesCell", forIndexPath: indexPath) as! ListingDetailAmenitiesTableViewCell
                amenitiesCollectionView = thisCell.amenitiesCollectionView
                if thisCell.amenitiesCollectionView?.contentSize.height == 0 {
                    let minLineSpacing = 3
                    let cellHeight = 20
                    let numAmenities = ceil(CGFloat(amenities.count) / 2)
                    let newHeight = (numAmenities * CGFloat(cellHeight)) + ((numAmenities - 1) * CGFloat(minLineSpacing))
                    thisCell.amenitiesCollectionViewHeight.constant = CGFloat(newHeight)
                }
                cell = thisCell
            case "Photos":
                let thisCell = tableView.dequeueReusableCellWithIdentifier("ListingDetailPhotosCell", forIndexPath: indexPath) as! ListingDetailPhotosTableViewCell
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
                let thisCell = tableView.dequeueReusableCellWithIdentifier("ListingDetailLocationCell", forIndexPath: indexPath) as! ListingDetailLocationTableViewCell
                if !thisCell.mapInitialized {
                    var distance = 600.0
                    
                    // make map view bigger on ipad
                    if IS_IPAD() {
                        thisCell.locationMapViewHeight.constant = 400
                        distance = 250.0
                    }
                    
                    let mapCenter = CLLocationCoordinate2DMake(listing.latitude, listing.longitude)
                    let region = MKCoordinateRegionMakeWithDistance(mapCenter, distance, distance)
                    thisCell.locationMapView.region = region
                    thisCell.locationMapView.showsUserLocation = true
                    thisCell.mapInitialized = true
                    
                    self.locationMapView = thisCell.locationMapView
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
            case "Transit":
                let thisCell = tableView.dequeueReusableCellWithIdentifier("ListingDetailTransitCell", forIndexPath: indexPath) as! ListingDetailTransitTableViewCell
                subwayLinesCollectionView = thisCell.subwayLinesCollectionView
                thisCell.subwayStationsLabel?.text = listing?.subwayStations
                thisCell.horizontalDividerHeight.constant = 0.5
                cell = thisCell
            case "Contact":
                let thisCell = tableView.dequeueReusableCellWithIdentifier("ListingDetailContactCell", forIndexPath: indexPath) as! ListingDetailContactTableViewCell
                if let contact = listing?.agent {
                    thisCell.listedByLabel?.text = "Listed by \(contact.firstName)"
                    thisCell.agentThumbnailImageView?.setImageWithURL(NSURL(string: contact.thumbnailURL)!)

                    if contact.onProbation || contact.suspended {
                        thisCell.messageButton.disable()
                    } else {
                        thisCell.messageButton.enable()
                    }
                }
                thisCell.agentThumbnailImageView.round()
                
                thisCell.horizontalDividerHeight.constant = 0.5
                cell = thisCell
            case "Admin":
                let thisCell = tableView.dequeueReusableCellWithIdentifier("ListingDetailAdminCell", forIndexPath: indexPath) as! ListingDetailAdminTableViewCell
                if !thisCell.tableInitialized {
                    thisCell.adminTableView.estimatedRowHeight = 44.0
                    thisCell.adminTableView.rowHeight = UITableViewAutomaticDimension
                    thisCell.adminTableView.tableFooterView = UIView(frame: CGRectZero)
                    thisCell.adminTableViewHeight.constant = calculatedAdminTableViewHeight()
                    
                    self.adminTableViewCell = thisCell
                    thisCell.tableInitialized = true
                }
                cell = thisCell
            default:
                break
            }
        }
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        
        return cell
    }
    
    func calculatedAdminTableViewHeight() -> CGFloat {
        let labelWidth = self.view.bounds.width - 8 - 95 - 8 - 8
        
        var height: CGFloat = 0
        for (_, val) in self.adminRowData {
            height += val.heightWithConstrainedWidth(CGFloat(labelWidth), font: UIFont.systemFontOfSize(14)) + 11 + 11 + 0.70
        }
        return height
    }
    
    // MARK: - Collection view data source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == amenitiesCollectionView {
            return amenities.count
        } else if collectionView == photosCollectionView {
            return photos.count
        } else if collectionView == subwayLinesCollectionView {
            return subwayLines.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let item = indexPath.item
        var cell: UICollectionViewCell!
        if collectionView == amenitiesCollectionView {
            let thisCell = collectionView.dequeueReusableCellWithReuseIdentifier("ListingAmenityCell", forIndexPath: indexPath) as! ListingDetailAmenitiesCollectionViewCell
            thisCell.amenityLabel?.text = amenities[item]
            cell = thisCell
        } else if collectionView == photosCollectionView {
            let thisCell = collectionView.dequeueReusableCellWithReuseIdentifier("ListingPhotoCell", forIndexPath: indexPath) as! ListingDetailPhotosCollectionViewCell
            let listingPhoto = photos[item]
            thisCell.photoImageView?.setImageWithURL(NSURL(string: listingPhoto.thumbnailURL)!)
            cell = thisCell
        } else if collectionView == subwayLinesCollectionView {
            let thisCell = collectionView.dequeueReusableCellWithReuseIdentifier("ListingSubwayLineCell", forIndexPath: indexPath) as! ListingDetailSubwayLinesCollectionViewCell
            let subwayLine = subwayLines[item]
            let subwayLineURL = listing.formattedSubwayLineURL(subwayLine)
            thisCell.subwayLineImageView?.setImageWithURL(NSURL(string: subwayLineURL)!)
            thisCell.subwayLineImageView.round()
            cell = thisCell
        }
        return cell
    }
    
    // MARK: - Collection view delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == subwayLinesCollectionView {
            let subwayLine = subwayLines[indexPath.item]
            
            // access the listings view controller and apply filters with selected subway line
            let tabBarViewControllers = tabBarController?.viewControllers
            let nc = tabBarViewControllers![0] as! UINavigationController
            let vc = nc.viewControllers[0] as! ListingsViewController
            var filters = vc.filters
            filters = ListingFilters()
            filters.subwayLine = subwayLine
            vc.applyFilters(filters)
            
            // have it pop off any detail view and show map
            vc.postFilterOnSubwayLine()
            
            // go to listings tab
            tabBarController?.selectedIndex = 0
        }
    }
    
    // MARK: - Collection view delegate flow layout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView == amenitiesCollectionView {
            let numDesiredColumns = 2
            let width = collectionView.frame.size.width / CGFloat(numDesiredColumns)
            let height = 20
            return CGSizeMake(width, CGFloat(height))
        } else if collectionView == photosCollectionView {
            let numDesiredColumns = 2
            let itemSpacing = 7
            let width = (collectionView.frame.size.width - CGFloat(itemSpacing)) / CGFloat(numDesiredColumns)
            let height = width
            return CGSizeMake(width, height)
        } else if collectionView == subwayLinesCollectionView {
            return CGSizeMake(60, 60)
        }
        return CGSizeMake(0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if collectionView == self.subwayLinesCollectionView {
            let subwayCellWidth = 60
            let spacing = 10
            let numSubwayCells = self.subwayLines.count
            let contentWidth = (numSubwayCells * subwayCellWidth) + (numSubwayCells - 1) * spacing
            var sideInset = (collectionView.frame.size.width - CGFloat(contentWidth)) / 2
            sideInset = max(0, sideInset)
            return UIEdgeInsetsMake(0, sideInset, 0, sideInset)
        }
        return UIEdgeInsetsZero
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
            annotationView.rightCalloutAccessoryView = UIButton(type: .InfoDark)
        } else if let listingAnnotation = annotation as? ListingPointAnnotation {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "listing")
            annotationView.canShowCallout = true
            
            // current listing pin
            if listingAnnotation.listing.id == self.listing?.id {
                listingAnnotation.title = "Your next home"
                annotationView.image = UIImage(named: "pin-black")
            } else {
                // left callout accessory view
                let imageView = UIImageView(frame: CGRectMake(0, 0, 50, 50))
                imageView.setImageWithURL(NSURL(string: listingAnnotation.listing.thumbnailURL)!)
                imageView.contentMode = UIViewContentMode.ScaleAspectFill
                annotationView.leftCalloutAccessoryView = imageView
                
                annotationView.image = UIImage(named: "pin-red")
                
                // right callout accessory view
                annotationView.rightCalloutAccessoryView = UIButton(type: .InfoDark)
            }
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
            performSegueWithIdentifier("locationDetail", sender: location)
        } else if let listingAnnotation = view.annotation as? ListingPointAnnotation {
            let listing = listingAnnotation.listing
            self.listing = listing
            tableView.setContentOffset(CGPointZero, animated: false)
            
            // force refresh
            self.viewDidLoad()
            self.viewWillAppear(false)
        }
    }
    
    // MARK: - Favorite
    
    @IBAction func favorite(sender: UIButton) {
        if !UserData.isLoggedIn() {
            tabBarController?.selectedIndex = 4
            return
        }
        
        sender.selected = !sender.selected
        favoriteListingAction(self.listing, favorite: sender.selected)
    }
    
    @IBAction func favorite2(sender: UIGestureRecognizer) {
        if sender.state == .Ended {
            let point = sender.locationInView(tableView)
            if let indexPath = tableView.indexPathForRowAtPoint(point) {
                let basicInfoCell = tableView.cellForRowAtIndexPath(indexPath) as! ListingDetailImageTableViewCell
                let favoriteButton = basicInfoCell.favoriteButton
                favorite(favoriteButton)
            }
        }
    }
    
    // MARK: - Call contact
    
    @IBAction func callContact(sender: UIButton) {
        callAgent(agent: listing.agent)
    }
    
    // MARK: - Message contact
    
    @IBAction func messageContact(sender: UIButton) {
        let contextURL = "\(SITE_DOMAIN)/listings/\(listing.id)"
        messageAgent(agent: listing.agent, contextURL: contextURL, vc: self)
    }
    
    // MARK: - Share
    
    @IBAction func share(sender: UIBarButtonItem) {
        var activityItems: [AnyObject] = []
        
        // text
        let linkText = "\(SITE_DOMAIN)/listings/\(listing.id)"
        let shareText = "\(linkText) in \(listing.neighborhood.name) #nooklyn"
        activityItems.append(shareText)
        
        // image
        activityItems.append(listingImageView.image!)
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypePrint]
        activityViewController.popoverPresentationController?.barButtonItem = sender
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "photos" {
            let cell = sender as! ListingDetailPhotosCollectionViewCell
            let indexPath = photosCollectionView!.indexPathForCell(cell)
            
            let vc = segue.destinationViewController as! PhotosViewController
            vc.photos = self.photos
            vc.photoIndex = indexPath!.row
        } else if segue.identifier == "locationDetail" {
            let location = sender as! Location
            let vc = segue.destinationViewController as! LocationDetailTableViewController
            vc.location = location
        } else if segue.identifier == "favorites" {
            let vc = segue.destinationViewController as! FavoritesViewController
            vc.agent = listing.agent
        }
    }
}

// MARK: - Table view cells

// Image
class ListingDetailImageTableViewCell: UITableViewCell {
    @IBOutlet var listingImageView: UIImageView!
    @IBOutlet var listingImageViewHeight: NSLayoutConstraint!
    var listingImageViewHeightSet: Bool = false
    @IBOutlet var listingPriceLabel: UILabel!
    @IBOutlet var favoriteButton: UIButton!
}

// Info
class ListingDetailInfoTableViewCell: UITableViewCell {
    @IBOutlet var neighborhoodLabel: UILabel!
    @IBOutlet var bedLabel: UILabel!
    @IBOutlet var bathLabel: UILabel!
    
    @IBOutlet var border1Thickness: NSLayoutConstraint!
    @IBOutlet var border2Thickness: NSLayoutConstraint!
    @IBOutlet var border3Thickness: NSLayoutConstraint!
}

// Description
class ListingDetailDescriptionTableViewCell: UITableViewCell {
    @IBOutlet var descriptionLabel: UILabel!
}

// Amenities
class ListingDetailAmenitiesTableViewCell: UITableViewCell {
    @IBOutlet var amenitiesCollectionView: UICollectionView!
    @IBOutlet var amenitiesCollectionViewHeight: NSLayoutConstraint!
}

// Photos
class ListingDetailPhotosTableViewCell: UITableViewCell {
    @IBOutlet var photosCollectionView: UICollectionView!
    @IBOutlet var photosCollectionViewHeight: NSLayoutConstraint!
}

// Location
class ListingDetailLocationTableViewCell: UITableViewCell {
    @IBOutlet var locationMapView: MKMapView!
    @IBOutlet var locationMapViewHeight: NSLayoutConstraint!
    var mapInitialized = false
    var addNearbyLocations = true
    var addNearbyListings = true
}

// Transit
class ListingDetailTransitTableViewCell: UITableViewCell {
    @IBOutlet var subwayLinesCollectionView: UICollectionView!
    @IBOutlet var subwayStationsLabel: UILabel!
    @IBOutlet var horizontalDividerHeight: NSLayoutConstraint!
}

// Contact
class ListingDetailContactTableViewCell: UITableViewCell {
    @IBOutlet var listedByLabel: UILabel!
    @IBOutlet var agentThumbnailImageView: UIImageView!
    @IBOutlet var callButton: UIButton!
    @IBOutlet var messageButton: UIButton!
    
    @IBOutlet var horizontalDividerHeight: NSLayoutConstraint!
}

// Admin
class ListingDetailAdminTableViewCell: UITableViewCell {
    var tableInitialized = false
    @IBOutlet var adminTableView: UITableView!
    @IBOutlet var adminTableViewHeight: NSLayoutConstraint!
}

class ListingAdminInfoTableViewCell: UITableViewCell {
    @IBOutlet var myTextLabel: UILabel!
    @IBOutlet var myDetailTextLabel: UILabel!
}

// MARK: - Collection view cells

// Amenities
class ListingDetailAmenitiesCollectionViewCell: UICollectionViewCell {
    @IBOutlet var amenityLabel: UILabel!
}

// Photos
class ListingDetailPhotosCollectionViewCell: UICollectionViewCell {
    @IBOutlet var photoImageView: UIImageView!
}

// Subway lines
class ListingDetailSubwayLinesCollectionViewCell: UICollectionViewCell {
    @IBOutlet var subwayLineImageView: UIImageView!
}

// MARK: - Location point annotation

class LocationPointAnnotation: MKPointAnnotation {
    var location: Location!
}

// MARK: - Listing point annotation

class ListingPointAnnotation: MKPointAnnotation {
    var listing: Listing!
}
