//
//  Signup2ViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 6/18/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

import UIKit
import MBProgressHUD

class Signup2ViewController: UIViewController {

    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    
    var userInfo: [String: String]!
    var embedded: Bool = false
    
    var kbHeight: CGFloat!
    var activeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar
        customizeNavigationBar()
        
        addKeyboardToolbar(textInputs: [firstNameTextField, lastNameTextField, phoneNumberTextField], target: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("Signup2")
    }
    
    override func viewWillDisappear(animated: Bool) {
        view.endEditing(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Go (Signup) button
    
    @IBAction func trySignup(sender: UIButton?) {
        // dismiss keyboard
        view.endEditing(true)
        
        let firstName = firstNameTextField.text!.strip()
        let lastName = lastNameTextField.text!.strip()
        let phoneNumber = phoneNumberTextField.text!.strip()
        
        if firstName.characters.count == 0 {
            showErrorAlert(message: "Please provide a first name.", vc: self)
            return
        }
        
        if lastName.characters.count == 0 {
            showErrorAlert(message: "Please provide a last name.", vc: self)
            return
        }
        
        // if phone number provided, check formatting
        let cleanedPhoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("[\\-]", withString: "",
            options: .RegularExpressionSearch)
        if phoneNumber.characters.count > 0 && cleanedPhoneNumber.characters.count != 10 {
            showErrorAlert(message: "Please provide a phone number of the format 555-555-5555.", vc: self)
            return
        }
        
        // add remaining fields to user info object
        userInfo["first-name"] = firstName
        userInfo["last-name"] = lastName
        userInfo["phone"] = cleanedPhoneNumber
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        // pass user info object to signup action
        ApiManager.signup(userInfo) { (signupSucceeded, errorMsg) in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            
            if signupSucceeded {
                self.handleSuccessfulSignup()
            } else {
                showErrorAlert(message: errorMsg, vc: self)
            }
        }
    }
    
    // MARK: - On successful signup
    
    func handleSuccessfulSignup() {
        let alert = UIAlertController(title: "Success", message: "A confirmation email has been sent.",
            preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { action in
//            if self.embedded {
//                self.navigationController?.popToRootViewControllerAnimated(false)
//            } else {
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TabBar") as UIViewController!
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.window?.rootViewController = vc
//            }
        })
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Text field delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == firstNameTextField {
            lastNameTextField.becomeFirstResponder()
        } else if textField == lastNameTextField {
            phoneNumberTextField.becomeFirstResponder()
        } else if textField == phoneNumberTextField {
            trySignup(nil)
        }
        return true
    }
    
    // MARK: - Keyboard toolbar
    
    @IBAction func nextTextInput(sender: UIBarButtonItem) {
        if activeTextField == firstNameTextField {
            lastNameTextField.becomeFirstResponder()
        } else if activeTextField == lastNameTextField {
            phoneNumberTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func prevTextInput(sender: UIBarButtonItem) {
        if activeTextField == phoneNumberTextField {
            lastNameTextField.becomeFirstResponder()
        } else if activeTextField == lastNameTextField {
            firstNameTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func dismissKeyboard(sender: UIBarButtonItem) {
        view.endEditing(true)
    }
    
    // MARK: - Keyboard notifications
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
                kbHeight = keyboardSize.height
                // edge case for embedded page, taking into account the bottom tabbar height
                if let tabBarHeight = (navigationController?.viewControllers[0] as UIViewController?)?.tabBarController?.tabBar.frame.size.height {
                    kbHeight = kbHeight - tabBarHeight
                }
                adjustView(KeyboardDirection.Up)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        adjustView(KeyboardDirection.Down)
    }
    
    func adjustView(direction: KeyboardDirection) {
        let bottomInset = (direction == KeyboardDirection.Up) ? kbHeight : 0.0
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, bottomInset, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
}
