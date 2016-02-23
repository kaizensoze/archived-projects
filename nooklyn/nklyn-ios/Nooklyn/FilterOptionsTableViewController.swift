//
//  FilterOptionsTableViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 7/3/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

import UIKit

class FilterOptionsTableViewController: UITableViewController {

    var filterOptions = FilterOptions()
    var option: String!
    var vals = [Any]()
    var delegate: FilterOptionsTableViewDelegate?
    
    let defaultColor = UIColor(hexString: "888888")
    let selectedColor = UIColor(hexString: "333333")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar
        customizeNavigationBar()
        
        // adjust insets
        let delegate1 = delegate as! FiltersViewController  // not exactly best practices on display here
        let delegate2 = delegate1.delegate as! UIViewController
        if let tabBarHeight = delegate2.tabBarController?.tabBar.frame.size.height {
            tableView.contentInset.bottom = tabBarHeight
            tableView.scrollIndicatorInsets.bottom = tabBarHeight
        }
        
        // remove empty trailing table cell separators
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // select rows to reflect current filters
        let optionVals = filterOptions.options[option]!["vals"]
        if ["ListingNeighborhoods", "MateNeighborhoods", "Amenities"].contains(option) {
            var coercedOptionVals = [String]()
            for optionVal in optionVals! {
                coercedOptionVals.append(optionVal as! String)
            }
            
            for val in vals {
                let theVal = val as! String
                
                // exception for showing neighborhood filter specified via neighborhood detail view
                if !coercedOptionVals.contains(theVal) {
                    if let neighborhoodToInclude = CacheManager.getNeighborhood(theVal) {
                        filterOptions.options[option]!["vals"]!.append(neighborhoodToInclude.id)
                        filterOptions.options[option]!["displayVals"]!.append(neighborhoodToInclude.name)
                        coercedOptionVals.append(theVal)
                    }
                }
                
                // select row
                if let valIndex = coercedOptionVals.indexOf(theVal) {
                    tableView.selectRowAtIndexPath(NSIndexPath(forRow: valIndex, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
                }
            }
        } else {
            var coercedOptionVals = [Int]()
            for optionVal in optionVals! {
                coercedOptionVals.append(optionVal as! Int)
            }
            for val in vals {
                let theVal = val as! Int
                if let valIndex = coercedOptionVals.indexOf(theVal) {
                    tableView.selectRowAtIndexPath(NSIndexPath(forRow: valIndex, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("FilterOptions: \(option)")
    }
    
    override func viewWillDisappear(animated: Bool) {
        var selectedVals = tableView.indexPathsForSelectedRows?.map({
            self.filterOptions.options[self.option]!["vals"]![$0.row]
        })
        if selectedVals == nil {
            selectedVals = [Any]()
        }
        delegate?.applySelected(option, selectedVals: selectedVals!)
        
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterOptions.options[option]!["displayVals"]!.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FilterOptionCell", forIndexPath: indexPath) as! FilterOptionTableViewCell
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        
        var displayVals = filterOptions.options[option]!["displayVals"]
        let displayVal = displayVals![indexPath.row]
        
        cell.optionLabel?.text = (displayVal as! String)
        cell.optionLabel?.textColor = defaultColor
        cell.checkmarkImageView?.hidden = true
        
        if cell.selected {
            cell.optionLabel?.textColor = selectedColor
            cell.checkmarkImageView?.hidden = false
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as? FilterOptionTableViewCell
        cell?.optionLabel?.textColor = selectedColor
        cell?.checkmarkImageView?.hidden = false
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as? FilterOptionTableViewCell
        cell?.optionLabel?.textColor = defaultColor
        cell?.checkmarkImageView?.hidden = true
    }
}

class FilterOptionTableViewCell: UITableViewCell {
    @IBOutlet var optionLabel: UILabel!
    @IBOutlet var checkmarkImageView: UIImageView!
}

// MARK: - Filter options table view delegate

protocol FilterOptionsTableViewDelegate {
    func applySelected(option: String, selectedVals: [Any])
}

// MARK: - Filter options

struct FilterOptions {
    var options: [String: [String: [Any]]] = [
        "Bedrooms": [
            "vals": [0, 1, 2, 3, 4, 5],
            "displayVals": ["0", "1", "2", "3", "4", "5+"]
        ],
        "Bathrooms": [
            "vals": [0, 1, 2, 3, 4, 5],
            "displayVals": ["0", "1", "2", "3", "4", "5+"]
        ],
        "ListingNeighborhoods": [
            "vals": [],
            "displayVals": []
        ],
        "MateNeighborhoods": [
            "vals": [],
            "displayVals": []
        ],
        "Amenities": [
            "vals": [],
            "displayVals": []
        ]
    ]
    
    init() {
        // fill in neighborhood options
        let neighborhoods = CacheManager.getListingNeighborhoods().sort({ $0.activeListingCount > $1.activeListingCount })
        for neighborhood in neighborhoods {
            options["ListingNeighborhoods"]!["vals"]!.append(neighborhood.id)
            options["ListingNeighborhoods"]!["displayVals"]!.append(neighborhood.name)
        }
        
        // fill in mate neighborhood options
        let mateNeighborhoods = CacheManager.getMateNeighborhoods().sort({
            $0.name.localizedCaseInsensitiveCompare($1.name) == NSComparisonResult.OrderedAscending
        })
        for mateNeighborhood in mateNeighborhoods {
            options["MateNeighborhoods"]!["vals"]!.append(mateNeighborhood.id)
            options["MateNeighborhoods"]!["displayVals"]!.append(mateNeighborhood.name)
        }
        
        // fill in amenities
        let amenities = CacheManager.getAmenities().sort({
            $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending
        })
        for amenity in amenities {
            options["Amenities"]!["vals"]!.append(amenity)
            options["Amenities"]!["displayVals"]!.append(amenity)
        }
    }
}
