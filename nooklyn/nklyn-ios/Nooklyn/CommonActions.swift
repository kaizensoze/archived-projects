//
//  CommonButtonActions.swift
//  Nooklyn
//
//  Created by Joe Gallo on 10/19/15.
//  Copyright © 2016 Nooklyn. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKLoginKit
import MBProgressHUD
import MessageUI

private var _fbLoginManager: FBSDKLoginManager?

var fbLoginManager: FBSDKLoginManager {
    get {
        if _fbLoginManager == nil {
            _fbLoginManager = FBSDKLoginManager()
        }
        return _fbLoginManager!
    }
}

// MARK: - Update listing favorite button

func updateListingFavoriteButton(button: UIButton, listing: Listing) {
    button.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
    button.selected = false
    if let _ = CacheManager.getListingFavorite(listing.id) {
        button.selected = true
    }
}

// MARK: - Update mate favorite button

func updateMateFavoriteButton(button: UIButton, mate: Mate) {
    button.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
    button.selected = false
    if let _ = CacheManager.getMateFavorite(mate.id) {
        button.selected = true
    }
}

// MARK: - Update location favorite button

func updateLocationFavoriteButton(button: UIButton, location: Location) {
    button.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
    button.selected = false
    if let _ = CacheManager.getLocationFavorite(location.id) {
        button.selected = true
    }
}

// MARK: - Favorite listing action

func favoriteListingAction(listing: Listing, favorite: Bool) {
    if !UserData.isLoggedIn() {
        return
    }
    
    // favorite
    if favorite {
        // add locally
        let listingFavorite = ListingFavorite(listing: listing)
        CacheManager.saveListingFavorites([listingFavorite])
        
        // add on server
        ApiManager.favoriteListing(listing.id)
    } else { // unfavorite
        // remove locally
        CacheManager.removeListingFavorite(listing.id)
        
        // remove on server
        ApiManager.unfavoriteListing(listing.id)
    }
}

// MARK: - Favorite mate action

func favoriteMateAction(mate: Mate, favorite: Bool) {
    if !UserData.isLoggedIn() {
        return
    }
    
    // favorite
    if favorite {
        // add locally
        let mateFavorite = MateFavorite(mate: mate)
        CacheManager.saveMateFavorites([mateFavorite])
        
        // add on server
        ApiManager.favoriteMate(mate.id)
    } else { // unfavorite
        // remove locally
        CacheManager.removeMateFavorite(mate.id)
        
        // remove on server
        ApiManager.unfavoriteMate(mate.id)
    }
}

// MARK: - Favorite location action

func favoriteLocationAction(location: Location, favorite: Bool) {
    if !UserData.isLoggedIn() {
        return
    }
    
    // favorite
    if favorite {
        // add locally
        let locationFavorite = LocationFavorite(location: location)
        CacheManager.saveLocationFavorites([locationFavorite])
        
        // add on server
        ApiManager.favoriteLocation(location.id)
    } else { // unfavorite
        // remove locally
        CacheManager.removeLocationFavorite(location.id)
        
        // remove on server
        ApiManager.unfavoriteLocation(location.id)
    }
}

// MARK: - Ignore listing action

func ignoreListingAction(listing: Listing) {
    if !UserData.isLoggedIn() {
        return
    }
    
    // update locally
    let listingIgnore = ListingIgnore(listing: listing)
    CacheManager.saveListingIgnores([listingIgnore])
    
    // update on server
    ApiManager.ignoreListing(listing.id)
}

// MARK: - Ignore mate action

func ignoreMateAction(mate: Mate) {
    if !UserData.isLoggedIn() {
        return
    }
    
    // update locally
    let mateIgnore = MateIgnore(mate: mate)
    CacheManager.saveMateIgnores([mateIgnore])
    
    // update on server
    ApiManager.ignoreMate(mate.id)
}

// MARK: - Archive conversation

func archiveConversation(conversation: Conversation) {
    if !UserData.isLoggedIn() {
        return
    }
    
    // update locally
    conversation.archived = true
    
    // update on server
    ApiManager.archiveConversation(conversation)
}

// MARK: - Unarchive conversation

func unarchiveConversation(conversation: Conversation) {
    if !UserData.isLoggedIn() {
        return
    }
    
    // update locally
    conversation.archived = false
    
    // update on server
    ApiManager.unarchiveConversation(conversation)
}

// MARK: - Mark conversation as read

func markConversationAsRead(conversation: Conversation) {
    if !UserData.isLoggedIn() {
        return
    }
    
    // update locally
    conversation.hasUnreadMessages = false
    
    // update on server
    ApiManager.markConversationAsRead(conversation)
}

// MARK: - Call agent

func callAgent(agent agent: Agent) {
    var contactNumber = NOOKLYN_OFFICE_PHONE_NUMBER // default to nooklyn office
    
    if agent.hasPhoneNumber() && !agent.onProbation && !agent.suspended {
        contactNumber = agent.formattedPhoneNumber!
    }
    let telURL = NSURL(string: "telprompt://\(contactNumber)")
    UIApplication.sharedApplication().openURL(telURL!)
}

// MARK: - Message agent

func messageAgent(agent agent: Agent, contextURL: String, vc: UIViewController) {
    if UserData.isLoggedIn() {
        let tabIndexToSwitchTo = 3
        
        let tabBarViewControllers = vc.tabBarController?.viewControllers
        let nc = tabBarViewControllers![tabIndexToSwitchTo] as! UINavigationController
        let vc = nc.viewControllers[0] as! ConversationsViewController
        
        // create contact object from listing
        let contact = Contact()
        contact.agent = agent
        contact.contextURL = contextURL
        
        // start new conversation
        vc.skipToMessages = true
        vc.startNewConversation(contact)
        
        // switch to messages tab
        vc.tabBarController?.selectedIndex = tabIndexToSwitchTo
    } else {
        var contactNumber = NOOKLYN_OFFICE_PHONE_NUMBER // default to nooklyn office
        if agent.hasPhoneNumber() {
            contactNumber = agent.formattedPhoneNumber!
        }
        let smsURL = NSURL(string: "sms://\(contactNumber)")
        UIApplication.sharedApplication().openURL(smsURL!)
    }
}

// MARK: - Facebook auth

func facebookAuth(vc vc: UIViewController, completion: (facebookAuthSucceeded: Bool) -> Void) {
    // just logout before logging in again (save the headache of potential stuck state)
    facebookLogout()
    
    let facebookPermissions = ["public_profile", "email"]
    
    fbLoginManager.logInWithReadPermissions(facebookPermissions, fromViewController: vc, handler: {
        (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
        if error != nil {
            facebookLogout()
            showErrorAlert(message: error.localizedDescription, vc: vc)
            completion(facebookAuthSucceeded: false)
        } else if result.isCancelled {
            // user cancelled
            facebookLogout()
        } else {
            var allPermsGranted = true
            
            let grantedPermissions = Array(result.grantedPermissions).map({ "\($0)" })
            for permission in facebookPermissions {
                if !grantedPermissions.contains(permission) {
                    allPermsGranted = false
                    break
                }
            }
            
            if allPermsGranted {
                let accessToken = result.token.tokenString
                let accessTokenExpiration = result.token.expirationDate
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
                let accessTokenExpirationString = stringFromDate(accessTokenExpiration, dateFormatter: dateFormatter)
                
                MBProgressHUD.showHUDAddedTo(vc.view, animated: true)
                
                ApiManager.facebookLogin(accessToken, accessTokenExpiration: accessTokenExpirationString) { loginSucceeded in
                    MBProgressHUD.hideHUDForView(vc.view, animated: true)
                    
                    if loginSucceeded {
                        completion(facebookAuthSucceeded: true)
                    } else {
                        completion(facebookAuthSucceeded: false)
                    }
                }
            } else {
                // user didn't grant all permissions requested
                completion(facebookAuthSucceeded: false)
            }
        }
    })
}

// MARK: - Logout

func logout(completion: (Void -> Void)?) {
    // clear device token
    ApiManager.updateDeviceToken("")
    
    // remove logged in agent
    CacheManager.removeLoggedInAgent()
    
    // log out of facebook
    facebookLogout()
    
    completion?()
}

// MARK: - Facebook logout

func facebookLogout() {
    fbLoginManager.logOut()
    _fbLoginManager = nil
}

// MARK: - UIAlertController

func showAlert(title title: String, message: String, vc: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
    vc.presentViewController(alert, animated: true, completion: nil)
}

func showErrorAlert(message message: String, vc: UIViewController) {
    showAlert(title: "Error", message: message, vc: vc)
}

func showSendMailErrorAlert(vc vc: UIViewController) {
    let errorMsg = "Your device could not send email.  Please check your email configuration and try again."
    showErrorAlert(message: errorMsg, vc: vc)
}

func showNetworkingErrorAlert(response: Response<AnyObject, NSError>? = nil) {
    let vc = UIApplication.sharedApplication().keyWindow?.rootViewController
    showErrorAlert(message: "Oops something went wrong.\nPlease try again.", vc: vc!)
    
    // print any helpful debugging output
    if let res = response {
        print(res.request!.URLString, res.result.value)
    }
}

// MARK: - Add keyboard toolbar

func addKeyboardToolbar(textInputs textInputs: [UITextInput], target: UIViewController) {
    let toolbar = UIToolbar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 44))
    toolbar.barStyle = UIBarStyle.BlackTranslucent
    
    let tintColor = UIColor(hexString: "FFC03A")
    
    let prevButton = UIBarButtonItem(image: UIImage(named: "arrow-prev"), style: UIBarButtonItemStyle.Plain, target: target, action: "prevTextInput:")
    prevButton.tintColor = tintColor
    
    let nextButton = UIBarButtonItem(image: UIImage(named: "arrow-next"), style: UIBarButtonItemStyle.Plain, target: target, action: "nextTextInput:")
    nextButton.tintColor = tintColor
    
    let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    
    let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: target, action: "dismissKeyboard:")
    doneButton.tintColor = tintColor
    
    toolbar.items = [prevButton, nextButton, flexSpace, doneButton]
    toolbar.sizeToFit()
    
    // associate text inputs with toolbar
    for textInput in textInputs {
        if textInput is UITextField {
            (textInput as! UITextField).inputAccessoryView = toolbar
        } else {
            (textInput as! UITextView).inputAccessoryView = toolbar
        }
    }
}

// MARK: - Google analytics

func trackViewInGoogleAnalytics(viewName: String) {
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: viewName)
    tracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject: AnyObject])
}

// MARK: - Mail compose view controller

func configuredMailComposeViewController() -> MFMailComposeViewController {
    let mailComposeVC = MFMailComposeViewController()
    mailComposeVC.setToRecipients(["help@nooklyn.com"])
    mailComposeVC.setSubject("Nooklyn app help")
    mailComposeVC.setMessageBody(messageBodyWithDeviceInfo(), isHTML: false)
    return mailComposeVC
}

func messageBodyWithDeviceInfo() -> String  {
    let device = UIDevice.currentDevice()
    let appVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
    let appBuildNumber = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String
    let platformStr = platform()
    let messageBody = "\n\n\n"
        + "------------------------------------\n"
        + "Information for the developers: \n"
        + "Application: Nooklyn: Apartments, Roommates, Neighborhoods \n"
        + "Version: \(appVersion) - \(appBuildNumber)\n"
        + "Model: \(platformStr)\n"
        + "System: \(device.systemName) \(device.systemVersion)\n"
        + "------------------------------------\n"
    return messageBody
}

func platform() -> String {
    var size : Int = 0
    sysctlbyname("hw.machine", nil, &size, nil, 0)
    var machine = [CChar](count: Int(size), repeatedValue: 0)
    sysctlbyname("hw.machine", &machine, &size, nil, 0)
    return String.fromCString(machine)!
}
