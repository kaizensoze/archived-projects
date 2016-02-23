//
//  SettingsTableViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 7/20/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    var options = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar
        customizeNavigationBar()
        
        // only show logout option if logged in
        if UserData.isLoggedIn() {
            options.append("Logout")
        }
        options.appendContentsOf(["Support?", "Follow us on Instagram", "Like us on Facebook", "Follow us on Twitter", "Version"])
        
        tableView.reloadData()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("Settings")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell", forIndexPath: indexPath) 
        cell.textLabel?.text = options[indexPath.row]
        cell.detailTextLabel?.text = ""
        if options[indexPath.row] == "Version" {
            let appVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
            cell.detailTextLabel?.text = appVersion
        }
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let option = options[indexPath.row]
        switch option {
        case "Logout":
            let alert = UIAlertController(title: "Logout?", message: "", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { action in
                logout() {
                    self.options.removeLast()
                    self.tableView.reloadData()
                    self.navigationController?.popToRootViewControllerAnimated(false)
                }
            })
            dispatch_async(dispatch_get_main_queue()) {
                self.presentViewController(alert, animated: true, completion: nil)
            }
        case "Support?":
            let mailComposeViewController = configuredMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                showSendMailErrorAlert(vc: self)
            }
        case "Follow us on Instagram":
            let instagramURL = NSURL(string: "https://www.instagram.com/nooklyn/")
            UIApplication.sharedApplication().openURL(instagramURL!)
        case "Like us on Facebook":
            let facebookURL = NSURL(string: "https://www.facebook.com/nooklynrentalarmy")
            UIApplication.sharedApplication().openURL(facebookURL!)
        case "Like us on Twitter":
            let twitterURL = NSURL(string: "https://twitter.com/nooklyn")
            UIApplication.sharedApplication().openURL(twitterURL!)
        default:
            break
        }
    }
    
    // MARK: - Mail compose delegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
