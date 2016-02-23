//
//  CustomUI.swift
//  Nooklyn
//
//  Created by Joe Gallo on 6/19/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

import UIKit
import AlamofireImage

// MARK: - UIViewController

extension UIViewController {
    func customizeNavigationBar() {
        // ensure status bar has white text
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        navigationController?.navigationBar.tintColor = UIColor(hexString: "ffc03a")
        
        setTitleView()
    }
    
    func setTitleView() {
        let view = UIView(frame: CGRectMake(250, 6, 100, 33))
        view.backgroundColor = UIColor.clearColor()
        
        let label = UILabel(frame: CGRectMake(8, 6, 84, 21))
        label.text = ""
        label.font = UIFont(name: "NooklynCons", size: 18)
        label.textColor = UIColor(hexString: "FFC03A")
        label.textAlignment = NSTextAlignment.Center
        label.backgroundColor = UIColor.clearColor()
        view.addSubview(label)
        
        navigationItem.titleView = view
    }
}

// MARK: - UIView

extension UIView {
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(CGColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue?.CGColor
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var theTintColor: UIColor? {
        get {
            return self.tintColor
        }
        set {
            self.tintColor = newValue
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = true
        }
    }
    
    func setBorder(color: UIColor = UIColor.blackColor()) {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = color.CGColor
    }
    
    func enable() {
        self.userInteractionEnabled = true
        self.alpha = 1
    }
    
    func disable() {
        self.userInteractionEnabled = false
        self.alpha = 0.5
    }
}

// MARK: - UILabel

extension UILabel {
    func setAttributedTextOnly(text: String) {
        var attributes: [String : AnyObject]?
        if !text.isEmpty && self.attributedText!.length > 0 {
            attributes = self.attributedText?.attributesAtIndex(0, effectiveRange: nil)
        }
        self.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
    
    func setAttributedFontOnly(font: UIFont) {
        guard let attributedText = self.attributedText else {
            return
        }
        
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
        let fullRange = NSRange(location: 0, length: self.text!.characters.count)
        mutableAttributedString.removeAttribute(NSFontAttributeName, range: fullRange)
        mutableAttributedString.addAttribute(NSFontAttributeName, value: font, range: fullRange)
        self.attributedText = mutableAttributedString
    }
}

class TopAlignedLabel: UILabel {
    override func drawTextInRect(rect: CGRect) {
        if let stringText = text {
            let stringTextAsNSString = stringText as NSString
            let labelStringSize = stringTextAsNSString.boundingRectWithSize(CGSizeMake(CGRectGetWidth(self.frame), CGFloat.max),
                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes: [NSFontAttributeName: font],
                context: nil).size
            super.drawTextInRect(CGRectMake(0, 0, CGRectGetWidth(self.frame), ceil(labelStringSize.height)))
        } else {
            super.drawTextInRect(rect)
        }
    }
}

// MARK: - UITextView

extension UITextView {
    func setAttributedTextOnly(text: String) {
        var attributes: [String : AnyObject]?
        if !text.isEmpty && self.attributedText!.length > 0 {
            attributes = self.attributedText?.attributesAtIndex(0, effectiveRange: nil)
        }
        self.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
    
    func setAttributedFontOnly(font: UIFont) {
        guard let attributedText = self.attributedText else {
            return
        }
        
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
        let fullRange = NSRange(location: 0, length: self.text!.characters.count)
        mutableAttributedString.removeAttribute(NSFontAttributeName, range: fullRange)
        mutableAttributedString.addAttribute(NSFontAttributeName, value: font, range: fullRange)
        self.attributedText = mutableAttributedString
    }
}

// MARK: - UIScrollView

extension UIScrollView {
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !dragging {
            nextResponder()?.touchesBegan(touches, withEvent: event)
        } else {
            super.touchesBegan(touches, withEvent: event)
        }
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !dragging {
            nextResponder()?.touchesMoved(touches, withEvent: event)
        } else {
            super.touchesMoved(touches, withEvent: event)
        }
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !dragging {
            nextResponder()?.touchesEnded(touches, withEvent: event)
        } else {
            super.touchesEnded(touches, withEvent: event)
        }
    }
}

// MARK: - UIImageView

extension UIImageView {
    func round() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.layer.masksToBounds = true
    }
    
    func setImageWithURL(URL: NSURL, fadeIn: Bool = true) {
        if URL.absoluteString == "/missing.png" {
            self.image = UIImage(named: "missing")
        } else {
            if fadeIn {
                self.af_setImageWithURL(URL,
                    placeholderImage: UIImage(named: "blank")?.resizableImageWithCapInsets(UIEdgeInsetsZero, resizingMode: .Tile),
                    filter: nil,
                    imageTransition: .CrossDissolve(0.15),
                    completion: nil
                )
            } else {
                self.af_setImageWithURL(URL)
            }
        }
    }
}

// MARK: - UIImage

extension UIImage {
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

// MARK: - Custom text field

class CustomTextField: UITextField {
    var clearImageTintColor: UIColor! = UIColor(hexString: "555555")
    var tintedClearImage: UIImage?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        // NOTE: Not using this.
    }
    
    func setup() {
        self.keyboardAppearance = UIKeyboardAppearance.Dark
        
        let paddingView = UIView(frame: CGRectMake(0, 0, 10, 20))
        leftView = paddingView
        leftViewMode = UITextFieldViewMode.Always
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setValue(clearImageTintColor, forKeyPath: "_placeholderLabel.textColor")
        tintClearImage()
    }
    
    private func tintClearImage() {
        for view in subviews {
            if view is UIButton {
                let button = view as! UIButton
                if let uiImage = button.imageForState(.Highlighted) {
                    if tintedClearImage == nil {
                        tintedClearImage = tintImage(uiImage, color: clearImageTintColor)
                    }
                    button.setImage(tintedClearImage, forState: .Normal)
                    button.setImage(tintedClearImage, forState: .Highlighted)
                }
            }
        }
    }
    
    func tintImage(image: UIImage, color: UIColor) -> UIImage {
        let size = image.size
        
        UIGraphicsBeginImageContextWithOptions(size, false, 2)
        let context = UIGraphicsGetCurrentContext()
        image.drawAtPoint(CGPointZero, blendMode: CGBlendMode.Normal, alpha: 1.0)
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextSetBlendMode(context, CGBlendMode.SourceIn)
        CGContextSetAlpha(context, 1.0)
        
        let rect = CGRectMake(
            CGPointZero.x,
            CGPointZero.y,
            image.size.width,
            image.size.height)
        CGContextFillRect(UIGraphicsGetCurrentContext(), rect)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tintedImage
    }
}

// MARK: - Custom switch

class CustomSwitch: UISwitch {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.onTintColor = UIColor(hexString: "FFC03A")
    }
}

// MARK: - Yellow button

class YellowButton: UIButton {
    var startColor: UIColor! = UIColor(hexString: "ffc03a")
    var endColor: UIColor! = UIColor(hexString: "ffc03a")
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // NOTE: Not using this.
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.borderColor = UIColor.blackColor()
        self.borderWidth = 0.0

        self.titleLabel?.textColor = UIColor.blackColor()
        self.cornerRadius = 0.0
        self.layer.masksToBounds = true
        
        let colors: Array = [startColor.CGColor, endColor.CGColor]
        gradientLayer.colors = colors
        gradientLayer.cornerRadius = cornerRadius
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        
        self.setNeedsDisplay()
    }
    
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    override class func layerClass() -> AnyClass {
        return CAGradientLayer.self
    }
}

// MARK: - Black button

class BlackButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // NOTE: Not using this.
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel?.textColor = UIColor.whiteColor()
        self.cornerRadius = 5.0
        self.layer.masksToBounds = true
        
        self.setNeedsDisplay()
    }
}

// MARK: - Custom tab bar controller

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        // hack to dismiss mate/listing filter view if open when going to another tab
        if selectedIndex == 0 || selectedIndex == 2 {
            if let nc = viewControllers?[selectedIndex] as? UINavigationController {
                nc.dismissViewControllerAnimated(false, completion: nil)
            }
        }
        
        // prevent login view from being popped off when selecting already selected tab
        if tabBarController.selectedViewController == viewController {
            if let navigationController = viewController as? UINavigationController {
                if let _ = navigationController.viewControllers.last as? LoginViewController {
                    return false
                }
            }
        }
        
        return true
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        // clear selected tab bar item's badge
        viewController.tabBarItem.badgeValue = nil
        
        // mates tab: if no longer logged in, but showing mate detail, pop off to mates view
        if selectedIndex == 2 {
            if !UserData.isFacebookAuthenticated() {
                if let navigationController = viewController as? UINavigationController {
                    navigationController.popToRootViewControllerAnimated(false)
                }
            }
        }
        
        // messages, favorites tabs: if logged in but an embedded login view is showing, remove it
        if selectedIndex == 3 || selectedIndex == 4 {
            if let navigationController = viewController as? UINavigationController {
                if UserData.isLoggedIn() {
                    if navigationController.viewControllers.count >= 2 {
                        if let _ = navigationController.viewControllers[1] as? LoginViewController {
                            navigationController.popToRootViewControllerAnimated(false)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - SliderTabBarView

class SliderTabBarView: UIView {
    @IBOutlet var sliderBarView: UIView!
    
    var currentTabIndex = 0
    
    var buttons = [UIButton]()
    var buttonWidthConstraints = [NSLayoutConstraint]()
    var contentViews = [UIView]()
    var centerConstraints = [NSLayoutConstraint]()
    var analyticsViewNames = [String]()
    
    var delegateView: UIView?
    var delegate: SliderTabBarViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // NOTE: Not using this.
    }
    
    func initialize() {
        // delegate view
        if let _ = delegateView {
        } else {
            delegateView = delegate?.view
        }
        
        // buttons
        for (index, button) in buttons.enumerate() {
            // add center constraint (NOTE: initial center constraint provided as IBOutlet)
            if index != currentTabIndex {
                let centerConstraint = NSLayoutConstraint(item: sliderBarView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: button, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
                centerConstraints.insert(centerConstraint, atIndex: index)
            }
        
            // mark button as select/unselected
            button.selected = false
            if index == currentTabIndex {
                button.selected = true
            }
        }
        
        // show current content view
        for contentView in contentViews {
            contentView.hidden = true
        }
        contentViews[currentTabIndex].hidden = false
    }
    
    // MARK: - Select tab with index
    
    func selectTabWithIndex(tabIndex: Int) {
        if tabIndex >= 0 && tabIndex < buttons.count {
            let button = buttons[tabIndex]
            sliderBarButtonSelected(button)
        }
    }
    
    // MARK: - Show all tabs
    
    func showAllTabs() {
        for (index, _) in buttons.enumerate() {
            let width = getSuperviewWidth() / Float(buttons.count)
            adjustButtonWidth(index, width: width)
        }
        self.delegateView?.layoutIfNeeded()
    }
    
    // MARK: - Hide tab with index
    
    func hideTabWithIndex(tabIndex: Int) {
        // if tab to hide is currently selected, select nearest tab
        if tabIndex == currentTabIndex {
            var remainingButtons = buttons
            remainingButtons.removeAtIndex(tabIndex)
            if remainingButtons.count == 0 {
                // hiding last remaining tab so just hide its content view
                contentViews[tabIndex].hidden = true
            } else {
                var tabIndexToSwitchTo: Int
                var remainingTabIndexes = remainingButtons.map({
                    return buttons.indexOf($0)!
                })
                if tabIndex >= remainingTabIndexes.count {
                    tabIndexToSwitchTo = remainingTabIndexes.last!
                } else {
                    tabIndexToSwitchTo = remainingTabIndexes[tabIndex]
                }
                selectTabWithIndex(tabIndexToSwitchTo)
            }
        }
        
        // adjust button widths
        for (index, _) in buttons.enumerate() {
            // set button width of tab to hide to 0
            var newButtonWidth: Float
            if index == tabIndex {
                newButtonWidth = 0
            } else {
                newButtonWidth = getSuperviewWidth() / Float(buttons.count - 1)
            }
            adjustButtonWidth(index, width: newButtonWidth)
        }
        self.delegateView?.layoutIfNeeded()
    }
    
    // MARK: - Adjust button width
    
    func adjustButtonWidth(tabIndex: Int, width: Float) {
        // do nothing if button width constraint hasn't been set
        guard let _ = buttonWidthConstraints[safe: tabIndex] else {
            return
        }
        
        // remove old width constraint
        let widthConstraint = buttonWidthConstraints[tabIndex]
        delegateView?.removeConstraint(widthConstraint)
        widthConstraint.active = false
        
        // set new width constraint
        let newWidthConstraint = NSLayoutConstraint(item: buttons[tabIndex], attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 0, constant: CGFloat(width))
        buttonWidthConstraints[tabIndex] = newWidthConstraint
        delegateView?.addConstraint(newWidthConstraint)
    }
    
    // MARK: - Get superview width
    
    func getSuperviewWidth() -> Float {
        var superviewWidth: Float
        if let delegateView = delegateView {
            superviewWidth = Float(delegateView.frame.size.width)
        } else {
            superviewWidth = Float(UIScreen.mainScreen().bounds.width)
        }
        return superviewWidth
    }
    
    // MARK: - Slider bar button selected
    
    @IBAction func sliderBarButtonSelected(sender: UIButton) {
        // do nothing if already selected
        if sender.selected {
            return
        }
        
        // make sure button is associated with slider tab bar view
        guard let selectedIndex = buttons.indexOf(sender) else {
            return
        }
        
        // update button selected states
        for button in buttons { button.selected = false }
        buttons[selectedIndex].selected = true
        
        // update content view hidden states
        for contentView in contentViews { contentView.hidden = true }
        contentViews[selectedIndex].hidden = false

        // track selection
        let viewName = analyticsViewNames[selectedIndex]
        trackViewInGoogleAnalytics(viewName)
        
        // move slider bar
        moveSliderBar(selectedIndex)
        
        // update tab index
        currentTabIndex = selectedIndex
        
        delegate?.sliderTabBarView?(self, tabSelected: selectedIndex)
    }
    
    // MARK: - Move slider bar
    
    func moveSliderBar(selectedIndex: Int) {
        // update constraints
        for (_, constraint) in centerConstraints.enumerate() { delegateView?.removeConstraint(constraint) }
        for constraint in centerConstraints { constraint.active = false }
        
        let activeConstraint = centerConstraints[selectedIndex]
        delegateView?.addConstraint(activeConstraint)
        
        // animate
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0,
            options: UIViewAnimationOptions.CurveLinear, animations: {
            self.delegateView?.layoutIfNeeded()
        }, completion: nil)
    }
}

// MARK: - Slider tab bar view delegate

@objc protocol SliderTabBarViewDelegate {
    var view: UIView! { get set }
    optional func sliderTabBarView(sliderTabBarView: SliderTabBarView, tabSelected tabIndex: Int)
}

// MARK: - Loading view

class LoadingView: UIView {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
}

// MARK: - PushNoAnimationSegue

class PushNoAnimationSegue: UIStoryboardSegue {
    override func perform() {
        let source = sourceViewController 
        if let navigation = source.navigationController {
            navigation.pushViewController(destinationViewController , animated: false)
        }
    }
}
