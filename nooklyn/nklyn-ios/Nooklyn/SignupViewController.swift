//
//  SignupViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 6/7/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var nextButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet var orViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var orViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    
    var kbHeight: CGFloat!
    var activeTextField: UITextField!
    
    var userInfo = [String: String]()
    var embedded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar
        customizeNavigationBar()
        
        addKeyboardToolbar(textInputs: [emailTextField, passwordTextField, confirmPasswordTextField], target: self)
        
        // facebook button
        facebookButton.imageView!.contentMode = UIViewContentMode.ScaleAspectFill
        
        // adjust distance above/below or label for smaller screens to ensure next button shows without scrolling
        if IS_IPHONE4() || IS_IPHONE5() {
            if (!self.embedded) {
                self.orViewTopConstraint.constant = 23
                self.orViewBottomConstraint.constant = 22
            } else {
                self.orViewTopConstraint.constant = 5
                self.orViewBottomConstraint.constant = 5
            }
        }
        
        // adjust distance between last textfield and next button
        // NOTE: not entirely sure why this isn't working for iphone 5 screen (manually skip for now)
        if view.frame.size.height - (nextButton.frame.origin.y + nextButton.frame.size.height) > 0 && !IS_IPHONE5() {
            var newDistance = view.frame.size.height - nextButton.frame.size.height
                - (confirmPasswordTextField.frame.origin.y + confirmPasswordTextField.frame.size.height)
                - self.navigationController!.navigationBar.frame.size.height
                - UIApplication.sharedApplication().statusBarFrame.size.height
            
            if self.embedded {
                if let tabBarHeight = (navigationController?.viewControllers[0] as UIViewController?)?.tabBarController?.tabBar.frame.size.height {
                    newDistance -= tabBarHeight
                }
            }
            nextButtonTopConstraint.constant = newDistance
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("Signup")
    }
    
    override func viewWillDisappear(animated: Bool) {
        view.endEditing(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Facebook button
    
    @IBAction func facebookSignup(sender: UIButton) {
        facebookAuth(vc: self) { facebookAuthSucceeded in
            if facebookAuthSucceeded {
                self.shortcutSignup()
            } else {
                showErrorAlert(message: "Unable to sign up with Facebook.", vc: self)
            }
        }
    }
    
    func shortcutSignup() {
        // behavior determined by whether or not view is "embedded"
        if self.embedded {
            self.navigationController?.popToRootViewControllerAnimated(false)
        } else {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TabBar") as UIViewController!
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.window?.rootViewController = vc
        }
    }
    
    // MARK: - [Attempt to] advance to second signup form (next)
    
    @IBAction func next(sender: UIButton?) {
        let email = emailTextField.text!.strip()
        let password = passwordTextField.text!
        let passwordConfirmation = confirmPasswordTextField.text!
        
        if email.characters.count == 0 {
            showErrorAlert(message: "Please provide an email.", vc: self)
            return
        }
        
        if password.characters.count == 0 {
            showErrorAlert(message: "Please provide a password.", vc: self)
            return
        }
        
        if passwordConfirmation.characters.count == 0 {
            showErrorAlert(message: "Please confirm the password.", vc: self)
            return
        }
        
        if password != passwordConfirmation {
            showErrorAlert(message: "Passwords do not match.", vc: self)
            return
        }
        
        // add fields to user info object to pass to signup2 view
        userInfo["email"] = email
        userInfo["password"] = password
        
        performSegueWithIdentifier("signup2", sender: nil)
    }
    
    // MARK: - Text field delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        } else if textField == confirmPasswordTextField {
            next(nil)
        }
        return true
    }
    
    // MARK: - Keyboard toolbar
    
    @IBAction func nextTextInput(sender: UIBarButtonItem) {
        if activeTextField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if activeTextField == passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func prevTextInput(sender: UIBarButtonItem) {
        if activeTextField == confirmPasswordTextField {
            passwordTextField.becomeFirstResponder()
        } else if activeTextField == passwordTextField {
            emailTextField.becomeFirstResponder()
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "signup2" {
            let vc = segue.destinationViewController as! Signup2ViewController
            vc.userInfo = userInfo
            vc.embedded = embedded
        }
    }
}
