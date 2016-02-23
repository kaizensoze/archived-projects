//
//  FiltersViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 6/9/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

import UIKit
import MessageUI

enum FilterType {
    case Listings
    case Mates
}

enum FilterRestriction {
    case None
    case Favorited
    case Ignored
}

class FiltersViewController: UIViewController, FilterOptionsTableViewDelegate, MFMailComposeViewControllerDelegate,
                             UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var filterOverlay: UIView!
    @IBOutlet var filterOverlayTopConstraint: NSLayoutConstraint!
    
    @IBOutlet var bottomConstraint1: NSLayoutConstraint!
    @IBOutlet var bottomConstraint2: NSLayoutConstraint!
    
    var type: FilterType!
    var options: [String]!
    var filters: Filters!
    var delegate: FiltersViewDelegate?
    
    var startPriceTextField: UITextField?
    var endPriceTextField: UITextField?
    
    var startDateTextField: UITextField?
    var endDateTextField: UITextField?
    
    var activeTextField: UITextField?
    
    var subwayLineOptions = Util.sortedSubwayLines(Array(subwayLineColorPriorityMap.keys))
    var filterSubwayLineTableViewCell: FilterSubwayLineTableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar
        customizeNavigationBar()
        
        setOptions()
        
        // adjust view insets so that view doesn't go under tab bar
        if let tabBarHeight = (delegate as! UIViewController).tabBarController?.tabBar.frame.size.height {
            bottomConstraint1.constant = tabBarHeight
            bottomConstraint2.constant = tabBarHeight
        }
        
        // remove empty trailing table cell separators
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // hide filter overlay
        filterOverlay.hidden = true
        
        // update tableview to match filters object
        tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("Filters: \(self.type)")
    }
    
    override func viewWillDisappear(animated: Bool) {
        view.endEditing(false)
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Set options
    
    func setOptions() {
        if self.type == FilterType.Listings {
            self.options = ["Price", "Bedrooms", "Bathrooms", "ListingNeighborhoods", "Subway Line", "Amenities", "Need Help?", "Clear Filters"]
        } else {
            self.options = ["Price", "MoveIn", "MateNeighborhoods", "Need Help?", "Clear Filters"]
        }
        
        // allow filtering on favoriting/ignored if logged in
        if UserData.isLoggedIn() {
            self.options.insert("Show", atIndex: self.options.indexOf("Need Help?")!)
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let option = options[indexPath.row]
        
        var cell: UITableViewCell!
        if option == "Show" {
            let thisCell = tableView.dequeueReusableCellWithIdentifier("FilterRestrictionCell", forIndexPath: indexPath) as! FilterRestrictionTableViewCell
            thisCell.filterLabel?.text = option
            cell = thisCell
        } else if option == "Price" || option == "MoveIn" {
            let thisCell = tableView.dequeueReusableCellWithIdentifier("FilterRangeCell", forIndexPath: indexPath) as! FilterRangeTableViewCell
            if option == "MoveIn" {
                thisCell.startTextField.inputView = getDatePickerView()
                thisCell.endTextField.inputView = getDatePickerView()
            } else {
                thisCell.startTextField.inputView = nil
                thisCell.endTextField.inputView = nil
            }
            thisCell.borderThickness.constant = 0.5
            cell = thisCell
        } else if option == "Subway Line" {
            let thisCell = tableView.dequeueReusableCellWithIdentifier("FilterSubwayLineCell", forIndexPath: indexPath) as! FilterSubwayLineTableViewCell
            thisCell.filterLabel?.text = option
            self.filterSubwayLineTableViewCell = thisCell
            cell = thisCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("FilterCell", forIndexPath: indexPath)
            cell.textLabel?.text = option
            
            // exception for MateNeighborhoods
            if cell.textLabel?.text == "ListingNeighborhoods" || cell.textLabel?.text == "MateNeighborhoods" {
                cell.textLabel?.text = "Neighborhoods"
            }
        }
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        
        updateCell(cell, option: option)
        return cell
    }
    
    // MARK: - Update cell
    
    func updateCell(cell: UITableViewCell, option: String) {
        switch option {
        case "Show":
            let restrictions = self.filters.restrictions
            
            let restrictionCell = cell as! FilterRestrictionTableViewCell
            restrictionCell.favoritedButton.selected = false
            restrictionCell.ignoredButton.selected = false
            
            if restrictions.contains(.Favorited) {
                restrictionCell.favoritedButton.selected = true
            }
            if restrictions.contains(.Ignored) {
                restrictionCell.ignoredButton.selected = true
            }
        case "Price":
            let rangeCell = cell as! FilterRangeTableViewCell
            rangeCell.startTextField.text = formatPrice(filters.startPrice)
            rangeCell.endTextField.text = formatPrice(filters.endPrice)
            
            if self.type == FilterType.Mates {
                rangeCell.startTextField.placeholder = "Min Rent"
                rangeCell.endTextField.placeholder = "Max Rent"
            }
        case "MoveIn":
            let rangeCell = cell as! FilterRangeTableViewCell
            rangeCell.startTextField.text = stringFromShortDate((self.filters as! MateFilters).startDate)
            rangeCell.endTextField.text = stringFromShortDate((self.filters as! MateFilters).endDate)
            
            rangeCell.startTextField.placeholder = "Start"
            rangeCell.endTextField.placeholder = "End"
            // multi-select table views (NOTE: There's a bug with the empty string so leave these as " ")
        case "Bedrooms":
            let filterBeds = (self.filters as! ListingFilters).beds
            if filterBeds.count > 0 {
                let selectedDisplayVals = getSelectedDisplayVals(option, selectedFilterVals: filterBeds)
                cell.detailTextLabel?.text = selectedDisplayVals.joinWithSeparator(", ")
            } else {
                cell.detailTextLabel?.text = " "
            }
        case "Bathrooms":
            let filterBaths = (self.filters as! ListingFilters).baths
            if filterBaths.count > 0 {
                let selectedDisplayVals = getSelectedDisplayVals(option, selectedFilterVals: filterBaths)
                cell.detailTextLabel?.text = selectedDisplayVals.joinWithSeparator(", ")
            } else {
                cell.detailTextLabel?.text = " "
            }
        case "ListingNeighborhoods":
            let filterNeighborhoods = (self.filters as! ListingFilters).neighborhoodIds
            cell.detailTextLabel?.text = (filterNeighborhoods.count > 0) ? "\(filterNeighborhoods.count) Selected" : " "
        case "MateNeighborhoods":
            let filterNeighborhoods = (self.filters as! MateFilters).neighborhoodIds
            cell.detailTextLabel?.text = (filterNeighborhoods.count > 0) ? "\(filterNeighborhoods.count) Selected" : " "
        case "Subway Line":
            let subwayLineCell = cell as! FilterSubwayLineTableViewCell
            if let subwayLine = (self.filters as! ListingFilters).subwayLine {
                let subwayLineURL = Util.formattedSubwayLineURL(subwayLine)
                subwayLineCell.selectedSubwayLineImageView?.setImageWithURL(NSURL(string: subwayLineURL)!)
            } else {
                subwayLineCell.selectedSubwayLineImageView.image = nil
            }
            subwayLineCell.selectedSubwayLineImageView.round()
        case "Amenities":
            let filterAmenities = (self.filters as! ListingFilters).amenities
            cell.detailTextLabel?.text = (filterAmenities.count > 0) ? "\(filterAmenities.count) Selected" : " "
        case "Need Help?":
            cell.detailTextLabel?.text = ""
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        case "Clear Filters":
            cell.detailTextLabel?.text = ""
        default:
            break
        }
    }
    
    // MARK: - Get selected display vals
    
    func getSelectedDisplayVals(option: String, selectedFilterVals: [Int]) -> [String] {
        // (Used by bed/bath filters.)
        let filterOptions = FilterOptions().options
        let filterDisplayVals = filterOptions[option]!["displayVals"]
        var selectedFilterDisplayVals: [String] = []
        for selectedFilterVal in selectedFilterVals {
            selectedFilterDisplayVals.append(filterDisplayVals![selectedFilterVal] as! String)
        }
        return selectedFilterDisplayVals.sort()
    }
    
    // MARK: - Table view delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let option = options[indexPath.row]
        handleRowSelect(option)
        
        // expand/collapse subway line
        if option == "Subway Line" {
            if let subwayCell = self.filterSubwayLineTableViewCell {
                self.tableView.reloadData()
                subwayCell.expanded = !subwayCell.expanded
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
    }
    
    // MARK: - Handle row select
    
    func handleRowSelect(option: String) {
        switch option {
        case "Bedrooms", "Bathrooms", "ListingNeighborhoods", "MateNeighborhoods", "Amenities":
            performSegueWithIdentifier("filterOptionsTable", sender: option)
        case "Need Help?":
            let mailComposeViewController = configuredMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                showSendMailErrorAlert(vc: self)
            }
        case "Clear Filters":
            let alert = UIAlertController(title: "Clear Filters?", message: "", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { action in
                self.clearFilters()
                })
            dispatch_async(dispatch_get_main_queue()) {
                self.presentViewController(alert, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let option = options[indexPath.row]
        if option == "Subway Line" {
            guard let subwayCell = self.filterSubwayLineTableViewCell else {
                return tableView.rowHeight
            }
            if subwayCell.expanded {
                if IS_IPHONE4() || IS_IPHONE5() {
                    return 245
                } else if IS_IPAD() {
                    return 155
                } else {
                    return 195
                }
            }
        }
        return tableView.rowHeight
    }
    
    // MARK: - Collection view data source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subwayLineOptions.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let subwayLine = subwayLineOptions[indexPath.item]
        let subwayLineURL = Util.formattedSubwayLineURL(subwayLine)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterSubwayLineOptionCell", forIndexPath: indexPath) as! FilterSubwayLineOptionCollectionViewCell
        if subwayLine == (self.filters as! ListingFilters).subwayLine {
            cell.alpha = 1
        } else {
            cell.alpha = 0.5
        }
        cell.subwayLineImageView?.setImageWithURL(NSURL(string: subwayLineURL)!)
        cell.subwayLineImageView?.round()
        return cell
    }
    
    // MARK: - Collection view delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedSubwayLine = subwayLineOptions[indexPath.item]
        let listingFilters = self.filters as! ListingFilters
        // toggle subway line
        if selectedSubwayLine == listingFilters.subwayLine {
            listingFilters.subwayLine = nil
        } else {
            listingFilters.subwayLine = selectedSubwayLine
        }
        collectionView.reloadData()
    }
    
    // MARK: - Collection view delegate flow layout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellWidth: CGFloat = 44.0
        let collectionViewWidth = collectionView.frame.width
        let numberOfColumns = floor(collectionViewWidth / cellWidth)

        return CGSizeMake(collectionViewWidth / numberOfColumns, cellWidth)
    }
    
    // MARK: - Update filter restrictions
    
    @IBAction func updateRestriction(sender: UIButton) {
        sender.selected = !sender.selected
        
        if sender.tag == 1 {
            if sender.selected {
                self.filters.restrictions.insert(.Favorited)
            } else {
                self.filters.restrictions.remove(.Favorited)
            }
        } else {
            if sender.selected {
                self.filters.restrictions.insert(.Ignored)
            } else {
                self.filters.restrictions.remove(.Ignored)
            }
        }
    }
    
    // MARK: - Filter toggle
    
    @IBAction func filterToggle(sender: UISwitch) {
//        let togglePoint = sender.convertPoint(CGPointZero, toView: tableView)
//        if let indexPath = tableView.indexPathForRowAtPoint(togglePoint) {
//            if options[indexPath.row] == "..." {
//                (self.filters as! ListingFilters).rental = sender.on
//            }
//        }
    }
    
    // MARK: - Textfield delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // show filter overlay, adjust top constraint based on listings/mates filter
        filterOverlay.hidden = false
        var newTopConstant = CGFloat(120)
        if self.type == FilterType.Mates {
            newTopConstant = 180
        }
        self.filterOverlayTopConstraint.constant = newTopConstant
        
        // figure out which filter this text field is for
        if let cell = textField.superview?.superview?.superview as? FilterRangeTableViewCell {
            if let indexPath = self.tableView.indexPathForCell(cell) {
                let option = self.options[indexPath.row]
                if option == "Price" {
                    textField.text = ""
                    
                    if textField.tag == 1 {
                        self.startPriceTextField = textField
                    } else if textField.tag == 2 {
                        self.endPriceTextField = textField
                    }
                } else if option == "MoveIn" {
                    if textField.tag == 1 {
                        self.startDateTextField = textField
                        if let startDate = (self.filters as! MateFilters).startDate {
                            (textField.inputView as? UIDatePicker)!.date = startDate
                        }
                    } else if textField.tag == 2 {
                        self.endDateTextField = textField
                        if let endDate = (self.filters as! MateFilters).endDate {
                            (textField.inputView as? UIDatePicker)!.date = endDate
                        }
                    }
                }
                self.activeTextField = textField
            }
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        updateRangeFilters()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let fullText = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        if fullText.characters.count > 12 {
            return false
        }
        textField.text = formatPrice(priceFromString(fullText))
        
        return false
    }
    
    func updateRangeFilters() {
        // price range
        if let startPriceTextField = self.startPriceTextField {
            self.filters.startPrice = priceFromString(startPriceTextField.text!)
        }
        if let endPriceTextField = self.endPriceTextField {
            self.filters.endPrice = priceFromString(endPriceTextField.text!)
        }
        
        // move in date range
        if let startMoveInTextField = self.startDateTextField {
            (self.filters as! MateFilters).startDate = shortDateFromString(startMoveInTextField.text!)
        }
        if let endMoveInTextField = self.endDateTextField {
            (self.filters as! MateFilters).endDate = shortDateFromString(endMoveInTextField.text!)
        }
    }
    
    // MARK: - Dismiss range keyboard
    
    @IBAction func dismissRangeKeyboard(sender: UITapGestureRecognizer) {
        filterOverlay.hidden = true
        view.endEditing(true)
    }
    
    // MARK: - Mail compose delegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Clear filters
    
    func clearFilters() {
        if self.type == FilterType.Listings {
            filters = ListingFilters()
        } else {
            filters = MateFilters()
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Submit (Filter)
    
    @IBAction func submit(sender: AnyObject) {
        updateRangeFilters()
        delegate?.applyFilters(filters!)
        delegate?.resetGridScroll()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Filter options view delegate
    
    func applySelected(option: String, selectedVals: [Any]) {
        switch option {
        case "Bedrooms":
            var tempVals = [Int]()
            for selectedVal in selectedVals {
                tempVals.append(selectedVal as! Int)
            }
            (self.filters as! ListingFilters).beds = tempVals
        case "Bathrooms":
            var tempVals = [Int]()
            for selectedVal in selectedVals {
                tempVals.append(selectedVal as! Int)
            }
            (self.filters as! ListingFilters).baths = tempVals
        case "ListingNeighborhoods":
            var tempVals = [String]()
            for selectedVal in selectedVals {
                tempVals.append(selectedVal as! String)
            }
            (self.filters as! ListingFilters).neighborhoodIds = tempVals
        case "MateNeighborhoods":
            var tempVals = [String]()
            for selectedVal in selectedVals {
                tempVals.append(selectedVal as! String)
            }
            (self.filters as! MateFilters).neighborhoodIds = tempVals
        case "Amenities":
            var tempVals = [String]()
            for selectedVal in selectedVals {
                tempVals.append(selectedVal as! String)
            }
            (self.filters as! ListingFilters).amenities = tempVals
        default:
            break
        }
        tableView.reloadData()
    }
    
    // MARK: - Date picker view
    
    func getDatePickerView() -> UIDatePicker {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        datePickerView.addTarget(self, action: "datePickerValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        return datePickerView
    }
    
    @IBAction func datePickerValueChanged(sender: UIDatePicker) {
        if let textField = activeTextField {
            textField.text = stringFromShortDate(sender.date)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Get vals to pass to filter options table view
    
    func getVals(option: String) -> [Any] {
        switch option {
        case "Bedrooms":
            var tmpFilterBeds = [Any]()
            for filterBed in (self.filters as! ListingFilters).beds {
                tmpFilterBeds.append(filterBed)
            }
            return tmpFilterBeds
        case "Bathrooms":
            var tmpFilterBaths = [Any]()
            for filterBath in (self.filters as! ListingFilters).baths {
                tmpFilterBaths.append(filterBath)
            }
            return tmpFilterBaths
        case "ListingNeighborhoods":
            var tmpFilterNeighborhoods = [Any]()
            for filterNeighborhood in (self.filters as! ListingFilters).neighborhoodIds {
                tmpFilterNeighborhoods.append(filterNeighborhood)
            }
            return tmpFilterNeighborhoods
        case "MateNeighborhoods":
            var tmpFilterNeighborhoods = [Any]()
            for filterNeighborhood in (self.filters as! MateFilters).neighborhoodIds {
                tmpFilterNeighborhoods.append(filterNeighborhood)
            }
            return tmpFilterNeighborhoods
        case "Amenities":
            var tmpFilterAmenities = [Any]()
            for filterAmenity in (self.filters as! ListingFilters).amenities {
                tmpFilterAmenities.append(filterAmenity)
            }
            return tmpFilterAmenities
        default:
            return []
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "filterOptionsTable" {
            let vc = segue.destinationViewController as! FilterOptionsTableViewController
            let option = sender as! String
            vc.option = option
            vc.vals = getVals(option)
            vc.delegate = self
        }
    }
}

// MARK: - Filters view delegate

protocol FiltersViewDelegate {
    func applyFilters(var filters: Filters)
    func resetGridScroll()
}

// MARK: - Filter Restriction Table View Cell

class FilterRestrictionTableViewCell: UITableViewCell {
    @IBOutlet var filterLabel: UILabel!
    @IBOutlet var favoritedButton: UIButton!
    @IBOutlet var ignoredButton: UIButton!
}

// MARK: - Filter Range Table View Cell

class FilterRangeTableViewCell: UITableViewCell {
    @IBOutlet var startTextField: UITextField!
    @IBOutlet var endTextField: UITextField!
    @IBOutlet var borderThickness: NSLayoutConstraint!
}

// MARK: - Filter Toggle Table View Cell

class FilterToggleTableViewCell: UITableViewCell {
    @IBOutlet var filterLabel: UILabel!
    @IBOutlet var filterToggle: UISwitch!
}

// MARK: - Filter Subway Line Table View Cell

class FilterSubwayLineTableViewCell: UITableViewCell {
    @IBOutlet var filterLabel: UILabel!
    @IBOutlet var selectedSubwayLineImageView: UIImageView!
    @IBOutlet var subwayLineOptionsCollectionView: UICollectionView!
    var expanded: Bool = false
}

// MARK: - Filter Subway Line Option Collection View Cell

class FilterSubwayLineOptionCollectionViewCell: UICollectionViewCell {
    @IBOutlet var subwayLineImageView: UIImageView!
}

// MARK: - Filters

class Filters: CustomStringConvertible {
    var startPrice: Int?
    var endPrice: Int?
    var neighborhoodIds = [String]()
    var restrictions = Set<FilterRestriction>()
    
    var formattedPriceRange: String! {
        return "\(formatPrice(startPrice)) - \(formatPrice(endPrice))"
    }
    
    var description: String {
        return ""
    }
}

// MARK: - Listing Filters

class ListingFilters: Filters {
    var beds = [Int]()
    var baths = [Int]()
    var subwayLine: String?
    var amenities = [String]()
}

func ==(lhs: ListingFilters, rhs: ListingFilters) -> Bool {
    return lhs.startPrice == rhs.startPrice
        && lhs.endPrice == rhs.endPrice
        && lhs.neighborhoodIds == rhs.neighborhoodIds
        && lhs.restrictions == rhs.restrictions
        && lhs.beds == rhs.beds
        && lhs.baths == rhs.baths
        && lhs.subwayLine == rhs.subwayLine
        && lhs.amenities == rhs.amenities
}

// MARK: - Mate Filters

class MateFilters: Filters {
    var startDate: NSDate?
    var endDate: NSDate?
}

func ==(lhs: MateFilters, rhs: MateFilters) -> Bool {
    return lhs.startPrice == rhs.startPrice
        && lhs.endPrice == rhs.endPrice
        && lhs.startDate == rhs.startDate
        && lhs.endDate == rhs.endDate
        && lhs.neighborhoodIds == rhs.neighborhoodIds
        && lhs.restrictions == rhs.restrictions
}
