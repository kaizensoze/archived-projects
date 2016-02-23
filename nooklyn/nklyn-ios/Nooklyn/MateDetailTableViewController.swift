//
//  MateDetailTableViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 10/16/15.
//  Copyright © 2016 Nooklyn. All rights reserved.
//

import UIKit

class MateDetailTableViewController: UITableViewController {

    var mate: Mate!
    var rows = ["Image", "Name", "Info", "Description"]
    
    var favoriteButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // navigation bar
        customizeNavigationBar()
        
        self.tableView.estimatedRowHeight = 182.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        print("mate: \(mate.id)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // if no longer logged in/facebook authenticated, pop off view
        if !UserData.isFacebookAuthenticated() {
            self.navigationController?.popViewControllerAnimated(false)
            return
        }
        
        // update favorite button
        if let favoriteButton = self.favoriteButton {
            updateMateFavoriteButton(favoriteButton, mate: self.mate)
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("MateDetail")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            let thisCell = tableView.dequeueReusableCellWithIdentifier("MateDetailImageCell", forIndexPath: indexPath) as! MateDetailImageTableViewCell
            thisCell.mateImageView?.setImageWithURL(NSURL(string: self.mate.imageURL)!)
            // one-time image height adjust for iphone 4/5
            if (IS_IPHONE4() || IS_IPHONE5()) && !thisCell.mateImageViewHeightSet {
                thisCell.mateImageViewHeight.constant = 300
                thisCell.mateImageViewHeightSet = true
            }
            cell = thisCell
        case "Name":
            let thisCell = tableView.dequeueReusableCellWithIdentifier("MateDetailNameCell", forIndexPath: indexPath) as! MateDetailNameTableViewCell
            thisCell.nameLabel?.text = self.mate.firstName
            updateMateFavoriteButton(thisCell.favoriteButton, mate: self.mate)
            self.favoriteButton = thisCell.favoriteButton
            thisCell.borderThickness.constant = 0.5
            cell = thisCell
        case "Info":
            let thisCell = tableView.dequeueReusableCellWithIdentifier("MateDetailInfoCell", forIndexPath: indexPath) as! MateDetailInfoTableViewCell
            thisCell.neighborhoodLabel?.text = self.mate.neighborhood?.name
            thisCell.budgetLabel?.text = "\(self.mate.formattedPrice)"
            thisCell.moveInLabel?.text = self.mate.formattedWhen
            thisCell.border1Thickness.constant = 0.5
            thisCell.border2Thickness.constant = 0.5
            thisCell.border3Thickness.constant = 0.5
            cell = thisCell
        case "Description":
            let thisCell = tableView.dequeueReusableCellWithIdentifier("MateDetailDescriptionCell", forIndexPath: indexPath) as! MateDetailDescriptionTableViewCell
            thisCell.descriptionTextView.setAttributedTextOnly(self.mate._description)
            thisCell.descriptionTextView.contentInset = UIEdgeInsetsMake(-8, -4, 0, 0)
            cell = thisCell
        default:
            break
        }
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        
        return cell
    }
    
    // MARK: - Message
    
    @IBAction func message(sender: UIButton) {
        let contextURL = "\(SITE_DOMAIN)/mate_posts/\(self.mate!.id)"
        messageAgent(agent: self.mate!.agent, contextURL: contextURL, vc: self)
    }
    
    // MARK: - Favorite
    
    @IBAction func favorite(sender: UIButton) {
        sender.selected = !sender.selected
        favoriteMateAction(self.mate, favorite: sender.selected)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "favorites" {
            let vc = segue.destinationViewController as! FavoritesViewController
            vc.agent = self.mate.agent
        }
    }
}

// Image
class MateDetailImageTableViewCell: UITableViewCell {
    @IBOutlet var mateImageView: UIImageView!
    @IBOutlet var mateImageViewHeight: NSLayoutConstraint!
    var mateImageViewHeightSet: Bool = false
}

// Name
class MateDetailNameTableViewCell: UITableViewCell {
    @IBOutlet var borderThickness: NSLayoutConstraint!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var favoriteButton: UIButton!
}

// Info
class MateDetailInfoTableViewCell: UITableViewCell {
    @IBOutlet var neighborhoodLabel: UILabel!
    @IBOutlet var budgetLabel: UILabel!
    @IBOutlet var moveInLabel: UILabel!
    
    @IBOutlet var border1Thickness: NSLayoutConstraint!
    @IBOutlet var border2Thickness: NSLayoutConstraint!
    @IBOutlet var border3Thickness: NSLayoutConstraint!
}

// Description + Message
class MateDetailDescriptionTableViewCell: UITableViewCell {
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var messageButton: UIButton!
}
