//
//  NeighborhoodOptionsTableViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 10/23/15.
//  Copyright © 2016 Nooklyn. All rights reserved.
//

import UIKit

class NeighborhoodOptionsTableViewController: UITableViewController {

    var regions = CacheManager.getRegions().sort({ $0.id < $1.id })
    var delegate: NeighborhoodOptionsTableViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sort neighborhoods of each region
        for region in regions {
            region.neighborhoods.sortInPlace({ $0.name < $1.name })
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("NeighborhoodOptions")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return regions.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let region = self.regions[section]
        return region.neighborhoods.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NeighborhoodCell", forIndexPath: indexPath) as! NeighborhoodTableViewCell
        let region = self.regions[indexPath.section]
        let neighborhood = region.neighborhoods[indexPath.row]
        
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(hexString: "F1E577")
        cell.selectedBackgroundView = selectedView
        
        cell.label?.text = neighborhood.name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let region = self.regions[section]
        return region.name
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let region = self.regions[indexPath.section]
        let selectedNeighborhood = region.neighborhoods[indexPath.row]
        self.delegate?.setNeighborhood(selectedNeighborhood)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let region = self.regions[section]
        
        let view = UIView()
        view.backgroundColor = UIColor.blackColor()
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFontOfSize(20)
        label.textColor = UIColor(hexString: "FFC03A")
        label.text = region.name
        
        view.addSubview(label)
        
        let views = ["label": label, "view": view]
        
        let horizontallayoutContraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[label]-16-|", options: .AlignAllCenterY, metrics: nil, views: views)
        view.addConstraints(horizontallayoutContraints)
        
        let verticalLayoutContraint = NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0)
        view.addConstraint(verticalLayoutContraint)
        
        return view
    }
}

class NeighborhoodTableViewCell: UITableViewCell {
    @IBOutlet var label: UILabel!
}

// MARK: - Neighborhood options table view delegate

protocol NeighborhoodOptionsTableViewDelegate {
    func setNeighborhood(neighborhood: Neighborhood)
}
