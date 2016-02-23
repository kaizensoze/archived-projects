//
//  LoginViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 6/14/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

import UIKit
import MBProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var loginButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet var orViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var orViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var facebookButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    
    var activeTextField: UITextField!
    
    var kbHeight: CGFloat!
    
    var embedded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar
        customizeNavigationBar()
        
        // facebook button
        facebookButton.imageView!.contentMode = UIViewContentMode.ScaleAspectFill
        
        // signup button
        let signupButtonItem = UIBarButtonItem(title: "Sign Up", style: .Plain, target: self, action: "goToSignup:")
        navigationItem.setRightBarButtonItem(signupButtonItem, animated: true)
        
        addKeyboardToolbar(textInputs: [emailTextField, passwordTextField], target: self)
        
        // check if embedded
        if isEmbedded() {
            self.embedded = true
        }
        
        // adjust distance above/below or label for smaller screens to ensure login button shows without scrolling
        if IS_IPHONE4() || IS_IPHONE5() {
            if (!self.embedded) {
                self.facebookButtonTopConstraint.constant = 19
                self.orViewTopConstraint.constant = 19
                self.orViewBottomConstraint.constant = 19
            } else {
                self.facebookButtonTopConstraint.constant = 5
                self.orViewTopConstraint.constant = 5
                self.orViewBottomConstraint.constant = 5
            }
        }
        
        // adjust distance between last textfield and login button
        var newDistance = view.frame.size.height - loginButton.frame.size.height
            - (passwordTextField.frame.origin.y + passwordTextField.frame.size.height)
            - self.navigationController!.navigationBar.frame.size.height
            - UIApplication.sharedApplication().statusBarFrame.size.height
        
        if self.embedded {
            if let tabBarHeight = (navigationController?.viewControllers[0] as UIViewController?)?.tabBarController?.tabBar.frame.size.height {
                newDistance -= tabBarHeight
            }
        }
        loginButtonTopConstraint.constant = max(newDistance, 20)
        
        // if embedded, adjust scroll view insets
        if self.embedded {
            if let tabBarHeight = (navigationController?.viewControllers[0] as UIViewController?)?.tabBarController?.tabBar.frame.size.height {
                let contentInsets = UIEdgeInsetsMake(0.0, 0.0, -1 * tabBarHeight, 0.0)
                self.scrollView.contentInset = contentInsets
                self.scrollView.scrollIndicatorInsets = contentInsets
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        if self.embedded {
            // hide back button
            navigationItem.hidesBackButton = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("Login")
    }
    
    override func viewWillDisappear(animated: Bool) {
        view.endEditing(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func goToSignup(sender: UIBarButtonItem) {
        performSegueWithIdentifier("signup", sender: nil)
    }
    
    @IBAction func tryLogin(sender: UIButton?) {
        // dismiss keyboard
        view.endEditing(true)
        
        let email = emailTextField.text!.strip()
        let password = passwordTextField.text!
        
        if email.characters.count == 0 {
            showErrorAlert(message: "Please provide an email.", vc: self)
            return
        }
        
        if password.characters.count == 0 {
            showErrorAlert(message: "Please provide a password.", vc: self)
            return
        }
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        ApiManager.login(email, password: password) { loginSucceeded in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            
            if loginSucceeded {
                self.advanceFromLogin()
            } else {
                showErrorAlert(message: "Invalid email/password.", vc: self)
            }
        }
    }
    
    // MARK: - Facebook button
    
    @IBAction func facebookLogin(sender: UIButton) {
        facebookAuth(vc: self) { facebookAuthSucceeded in
            if facebookAuthSucceeded {
                self.advanceFromLogin()
            } else {
                showErrorAlert(message: "Unable to login with Facebook.", vc: self)
            }
        }
    }
    
    func advanceFromLogin() {
        // post-login behavior determined by whether or not view is "embedded"
        if self.embedded {
            self.navigationController?.popToRootViewControllerAnimated(false)
        } else {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TabBar") as UIViewController!
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.window?.rootViewController = vc
        }
    }
    
    @IBAction func close(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    // MARK: - Embedded check
    
    func isEmbedded() -> Bool {
        // if coming to login view from something other than first time view, consider it embedded
        if let viewControllers = navigationController?.viewControllers {
            if viewControllers.count > 0 {
                if !viewControllers[0].isKindOfClass(FirstTimeViewController) {
                    return true
                }
            }
        }
        return false
    }
    
    // MARK: - Text field delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            tryLogin(nil)
        }
        return true
    }
    
    // MARK: - Keyboard toolbar
    
    @IBAction func nextTextInput(sender: UIBarButtonItem) {
        if activeTextField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func prevTextInput(sender: UIBarButtonItem) {
        if activeTextField == passwordTextField {
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
        if segue.identifier == "signup" {
            let vc = segue.destinationViewController as! SignupViewController
            vc.embedded = embedded
        }
    }
}
