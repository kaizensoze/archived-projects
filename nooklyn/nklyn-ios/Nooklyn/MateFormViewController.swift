//
//  MateFormViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 10/20/15.
//  Copyright © 2016 Nooklyn. All rights reserved.
//

import UIKit
import MobileCoreServices
import MBProgressHUD

class MateFormViewController: UIViewController, NeighborhoodOptionsTableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var uploadImageView: UIImageView!
    @IBOutlet var uploadImageHeight: NSLayoutConstraint!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var budgetTextField: UITextField!
    @IBOutlet var moveInTextField: UITextField!
    @IBOutlet var neighborhoodTextField: UITextField!
    @IBOutlet var privateSwitch: UISwitch!
    @IBOutlet var createButton: UIButton!
    
    var kbHeight: CGFloat!
    var activeTextInput: UITextInput!
    
    var imageAlertController: UIAlertController!
    var selectedImage: UIImage?
    var selectedNeighborhood: Neighborhood?
    
    var existingMate: Mate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar
        customizeNavigationBar()
        
        addKeyboardToolbar(textInputs: [descriptionTextView, budgetTextField, moveInTextField, neighborhoodTextField], target: self)
        
        self.moveInTextField.inputView = getDatePickerView()
        
        self.descriptionTextView.keyboardAppearance = UIKeyboardAppearance.Dark
        self.descriptionTextView.textContainerInset = UIEdgeInsetsMake(10, 7, 10, 4)
        
        // image alert controller
        setupImageAlertController()
        
        // adjust for smaller screens
        adjustForSmallerScreens()
        
        // if logged in user already has a mate post, pre-fill form
        if let loggedInAgent = CacheManager.getAgent(UserData.getLoggedInAgentId()!), mate = loggedInAgent.mate {
            self.existingMate = mate
            prefillForm(mate)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        // if no longer logged in/facebook authenticated, pop off view
        if !UserData.isFacebookAuthenticated() {
            self.navigationController?.popViewControllerAnimated(false)
            return
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("MateForm")
    }
    
    override func viewWillDisappear(animated: Bool) {
        view.endEditing(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Adjust for smaller screens
    
    func adjustForSmallerScreens() {
        if IS_IPHONE4() {
            self.uploadImageHeight.constant = 150
        } else if IS_IPHONE5() {
            self.uploadImageHeight.constant = 185
        }
        self.uploadImageView.layoutIfNeeded()
    }
    
    // MARK: - Pre-fill form
    func prefillForm(existingMate: Mate) {
        self.uploadImageView.image = UIImage(named: "mate-upload-image-done")
        self.descriptionTextView.text = existingMate._description
        self.budgetTextField.text = String(existingMate.price)
        self.moveInTextField.text = existingMate.formattedWhenFull
        if let neighborhood = existingMate.neighborhood {
            self.neighborhoodTextField.text = neighborhood.name
            self.selectedNeighborhood = neighborhood as Neighborhood
        }

        // update date picker
        (self.moveInTextField.inputView as? UIDatePicker)!.date = existingMate.when
        
        // update private switch
        self.privateSwitch.on = false
        if !existingMate.visible {
            self.privateSwitch.on = true
        }
        
        self.createButton.setTitle("Update", forState: .Normal)
    }
    
    // MARK: - Create mate
    
    @IBAction func createMate(sender: UIButton?) {
        // dismiss keyboard
        view.endEditing(true)
        
        // check if we're skipping image
        var skipImage = false
        if existingMate != nil && selectedImage == nil {
            skipImage = true
        }
        
        var imageFileSizeinMB = Float(0)
        if (!skipImage) {
            if let _image = self.selectedImage {
                imageFileSizeinMB = getImageFileSizeInMB(_image)
            }
        }
        
        let descriptionText = self.descriptionTextView.text.strip()
        let monthlyBudgetText = self.budgetTextField.text!.strip()
        let moveInText = self.moveInTextField.text!.strip()
        
        if imageFileSizeinMB > 10 {
            showErrorAlert(message: "Image exceeds 10MB file size limit.", vc: self)
            return
        }
        
        if !skipImage && self.selectedImage == nil {
            showErrorAlert(message: "Please provide a picture.", vc: self)
            return
        }
        
        if descriptionText.characters.count == 0 {
            showErrorAlert(message: "Please provide a description.", vc: self)
            return
        }
        
        if monthlyBudgetText.characters.count == 0 {
            showErrorAlert(message: "Please provide a monthly budget.", vc: self)
            return
        }
        
        if moveInText.characters.count == 0 {
            showErrorAlert(message: "Please select a move in date.", vc: self)
            return
        }
        
        if self.selectedNeighborhood == nil {
            showErrorAlert(message: "Please select a neighborhood.", vc: self)
            return
        }
        
        // compress image [if necessary] and encode to base64 string
        var base64String = ""
        if !skipImage {
            var imageData: NSData
            if imageFileSizeinMB >= 3 {
                imageData = UIImageJPEGRepresentation(self.selectedImage!, 0.70)!
            } else {
                imageData = UIImageJPEGRepresentation(self.selectedImage!, 1)!
            }
            base64String = imageData.base64EncodedStringWithOptions([.Encoding64CharacterLineLength])
        }
        
        // date formatter
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        // pass mate info to createMate
        let mate = Mate()
        if existingMate != nil { mate.id = existingMate!.id }
        if !skipImage { mate.image = base64String }
        mate._description = descriptionText
        mate.price = Int(monthlyBudgetText)!
        mate.when = dateFromString(moveInText, dateFormatter: dateFormatter) ?? NSDate()
        mate.agentId = UserData.getLoggedInAgentId()!
        mate.neighborhoodId = self.selectedNeighborhood!.id
        if self.privateSwitch.on { mate.visible = false }
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        ApiManager.createMate(mate) { (createMateSucceeded, errorMsg, createdMate) in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            
            if createMateSucceeded {
                // update logged in agent's mate post
                if let loggedInAgent = CacheManager.getAgent(UserData.getLoggedInAgentId()!) {
                    loggedInAgent.mate = createdMate
                    CacheManager.saveAgents([loggedInAgent])
                }
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                showErrorAlert(message: errorMsg, vc: self)
            }
        }
    }
    
    // MARK: - Date picker view
    
    func getDatePickerView() -> UIDatePicker {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        datePickerView.addTarget(self, action: "datePickerValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        return datePickerView
    }
    
    @IBAction func datePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        self.moveInTextField.text = stringFromDate(sender.date, dateFormatter: dateFormatter)
    }
    
    // MARK: - Neighborhoods table view delegate
    
    func setNeighborhood(neighborhood: Neighborhood) {
        self.neighborhoodTextField?.text = neighborhood.name
        self.selectedNeighborhood = neighborhood
    }
    
    // MARK: - Image alert controller
    
    func setupImageAlertController() {
        self.imageAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        // take image from camera
        let cameraAction = UIAlertAction(title: "Use Camera", style: .Default) { action in
            self.useCamera()
        }
        self.imageAlertController.addAction(cameraAction)
        
        // select from photo library
        let libraryAction = UIAlertAction(title: "Choose from photo library", style: .Default) { action in
            self.chooseFromPhotoLibrary()
        }
        self.imageAlertController.addAction(libraryAction)
        
        // cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
        }
        self.imageAlertController.addAction(cancelAction)
        
        // required for ipad
        self.imageAlertController.popoverPresentationController?.sourceView = self.uploadImageView
        self.imageAlertController.popoverPresentationController?.sourceRect = CGRectMake(0, 0,
            self.view.frame.size.width, 215)
        self.imageAlertController.popoverPresentationController?.permittedArrowDirections = .Up
    }
    
    @IBAction func showImageAlertController(sender: UIGestureRecognizer) {
        if sender.state == .Ended {
            self.presentViewController(self.imageAlertController, animated: true, completion: {
                // ipad edge case
                if IS_IPAD() {
                    self.setupImageAlertController()
                }
            })
        }
    }
    
    // MARK: - Use camera
    
    func useCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - Choose from photo library
    
    func chooseFromPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
            
                self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - Image picker controller delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // set selected image
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        if mediaType == (kUTTypeImage as String) {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.selectedImage = image
        }
        
        self.dismissViewControllerAnimated(true, completion: {
            // show thanks image
            self.uploadImageView.image = UIImage(named: "mate-upload-image-done")
        })
    }
    
    // MARK: - Text field delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextInput = textField
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == self.neighborhoodTextField {
            performSegueWithIdentifier("neighborhoodsTable", sender: nil)
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == descriptionTextView {
            budgetTextField.becomeFirstResponder()
        } else if textField == budgetTextField {
            moveInTextField.becomeFirstResponder()
        } else if textField == moveInTextField {
            neighborhoodTextField.becomeFirstResponder()
        } else {
            createMate(nil)
        }
        return true
    }
    
    // MARK: - Text view delegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        activeTextInput = textView
    }
    
    // MARK: - Keyboard toolbar
    
    @IBAction func nextTextInput(sender: UIBarButtonItem) {
        if (activeTextInput as? UITextView) == descriptionTextView {
            budgetTextField.becomeFirstResponder()
        } else if (activeTextInput as? UITextField) == budgetTextField {
            moveInTextField.becomeFirstResponder()
        } else if (activeTextInput as? UITextField) == moveInTextField {
            neighborhoodTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func prevTextInput(sender: UIBarButtonItem) {
        if (activeTextInput as? UITextField) == neighborhoodTextField {
            moveInTextField.becomeFirstResponder()
        } else if (activeTextInput as? UITextField) == moveInTextField {
            budgetTextField.becomeFirstResponder()
        } else if (activeTextInput as? UITextField) == budgetTextField {
            descriptionTextView.becomeFirstResponder()
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
        if segue.identifier == "neighborhoodsTable" {
            let vc = segue.destinationViewController as! NeighborhoodOptionsTableViewController
            vc.delegate = self
        }
    }
}
