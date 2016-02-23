//
//  ConversationMessagesViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 7/24/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

import UIKit

class ConversationMessagesViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var sendMessageToolbar: UIToolbar!
    @IBOutlet var bottomSpaceConstraint: NSLayoutConstraint!
    
    var conversation: Conversation!
    var messages = [ConversationMessage]()
    var sendTextField: UITextField!
    var kbHeight: CGFloat!
    var firstAppear = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // messages
        setMessages()
        
        // navigation bar
        customizeNavigationBar()
        
        tableView.estimatedRowHeight = 98.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // remove empty trailing table cell separators
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // toolbar
        setupSendMessageToolbar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // set messages
        setMessages()
        
        // sometimes skipping to messages won't even show conversations view first so we need to disable the skip flag
        // from the messages view
        let conversationsVC = self.navigationController?.viewControllers[0] as! ConversationsViewController
        conversationsVC.skipToMessages = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        // if not logged in, pop off view.
        if !UserData.isLoggedIn() {
            self.navigationController?.popViewControllerAnimated(false)
            return
        }
        
        // show who you're talking to in the title bar
        navigationItem.titleView = nil
        self.title = conversation.otherParticipantNames
        
        // reload data
        tableView.reloadData()
        
        // mark conversation as read
        if self.conversation.hasUnreadMessages {
            markConversationAsRead(conversation)
        }
        
        // focus send text field and scroll to bottom
        if self.firstAppear {
            scrollToBottom(animated: false)
            
            sendTextField.becomeFirstResponder()
            self.firstAppear = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("ConversationMessages")
    }
    
    override func viewWillDisappear(animated: Bool) {
        view.endEditing(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Set messages
    
    func setMessages() {
        self.messages = self.conversation.messages.sort({
            $0.createdAt.compare($1.createdAt) == NSComparisonResult.OrderedAscending
        })
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // last row is padding
        if indexPath.row >= self.messages.count {
            let cell = tableView.dequeueReusableCellWithIdentifier("bottom_padding", forIndexPath: indexPath)
            return cell
        }
        
        let message = self.messages[indexPath.row]
        
        // differentiate between logged in user's/another user's message
        var cell = tableView.dequeueReusableCellWithIdentifier("ConversationMessageCell", forIndexPath: indexPath) as! ConversationMessageTableViewCell
        if let agent = message.agent {
            if UserData.isLoggedInAgent(agentId: agent.id) {
                cell = tableView.dequeueReusableCellWithIdentifier("MyConversationMessageCell", forIndexPath: indexPath) as! ConversationMessageTableViewCell
            }
        }
        
        // date label
        cell.dateView.dateLabel.text = message.formattedUpdatedAtDate
        cell.dateView.border1Thickness.constant = 0.5
        cell.dateView.border2Thickness.constant = 0.5
        
        // only show date label if unique
        cell.dateView.hidden = true
        if indexPath.row - 1 >= 0 && indexPath.row - 1 < self.messages.count {
            let prevMessage = self.messages[indexPath.row - 1]
            if message.formattedUpdatedAtDate != prevMessage.formattedUpdatedAtDate {
                cell.dateView.hidden = false
            }
        } else {
            cell.dateView.hidden = false
        }
        
        // agent
        if let agent = message.agent {
            cell.agentImageView.setImageWithURL(NSURL(string: agent.thumbnailURL)!)
            cell.agentImageView.round()
            
            // add tap gesture to agent image that goes to their favorites view
            let tapGR = UITapGestureRecognizer(target: self, action: "goToFavorites:")
            cell.agentImageView.addGestureRecognizer(tapGR)
        }
        
        // message
        var imageName: String!
        var imageInsets: UIEdgeInsets!
        if cell.reuseIdentifier == "ConversationMessageCell" {
            imageName = "chat-bubble-them"
            imageInsets = UIEdgeInsetsMake(17, 24, 17, 17)
        } else {
            imageName = "chat-bubble-me"
            imageInsets = UIEdgeInsetsMake(17, 17, 17, 24)
        }
        let imageWithInsets = UIImage(named: imageName)?.resizableImageWithCapInsets(imageInsets, resizingMode: .Tile)
        cell.messageBubbleImageView.image = imageWithInsets
        cell.messageTextView.textContainerInset = UIEdgeInsetsMake(-2, -5, 0, 0)
        cell.messageTextView.text = message.message
//        cell.messageTextView.setBorder()
        
        // XXX: Look into placing the below calculation into a different UITableView method. It might be affecting scroll smoothness.
        
        // adjust width of message text
        var maxAllowedWidth: CGFloat!
        if cell.reuseIdentifier == "ConversationMessageCell" {
            maxAllowedWidth = self.view.frame.size.width - cell.messageTextView.frame.origin.x - cell.messageTextViewRightMargin.constant
        } else {
            maxAllowedWidth = self.view.frame.size.width - cell.messageTextViewRightMargin.constant - 105
        }
        let sizeThatFits = cell.messageTextView.sizeThatFits(CGSizeMake(maxAllowedWidth, CGFloat.max))
        cell.messageTextViewWidth.constant = sizeThatFits.width
        
        // change link text color on darker background
        if cell.reuseIdentifier == "MyConversationMessageCell" {
            cell.messageTextView.linkTextAttributes = [
                NSForegroundColorAttributeName: UIColor(hexString: "ffc03a")!,
                NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
            ]
        }
        
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        
        return cell
    }
    
    // MARK: - Setup toolbar
    
    func setupSendMessageToolbar() {
        sendMessageToolbar.translucent = false
        sendMessageToolbar.barTintColor = UIColor(hexString: "f7f7f7")
        
        let toolbarSize = CGSizeMake(self.view.frame.size.width, 44)
        
        // send textfield
        let textField = UITextField(frame: CGRectMake(0, 8, toolbarSize.width - 80, toolbarSize.height - 8*2))
        textField.font = UIFont.systemFontOfSize(15)
        textField.textColor = UIColor(hexString: "333333")
        textField.tintColor = UIColor(hexString: "333333")
        textField.backgroundColor = UIColor(hexString: "fafafa")
        textField.borderStyle = UITextBorderStyle.RoundedRect
        textField.autocorrectionType = .No
        sendTextField = textField
        let textFieldBarButtonItem = UIBarButtonItem(customView: textField)
        
        // send button
        let sendBarButtonItem = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.Plain, target: self, action: "sendMessage:")
        sendBarButtonItem.tintColor = UIColor(hexString: "161616")
        
//        // flexible spacing
//        let flexibleBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        // set toolbar items
        sendMessageToolbar.items = [textFieldBarButtonItem/*, flexibleBarButtonItem*/, sendBarButtonItem]
        sendMessageToolbar.sizeToFit()
    }
    
    // MARK: - Send message
    
    @IBAction func sendMessage(sender: UIBarButtonItem) {
        if sendTextField.text!.strip().characters.count == 0 {
            return
        }
        
        // check if we need to create a conversation first
        if conversation.id == "TEMP" {
            ApiManager.createConversation(self.conversation) { newConversation in
                self.conversation = newConversation
                self.setMessages()
                self.sendMessage()
            }
        } else {
            sendMessage()
        }
    }
    
    func sendMessage() {
        let messageText = sendTextField.text!
        
        // create temp message
        let messageToAdd = ConversationMessage()
        messageToAdd.id = "TEMP"
        messageToAdd.message = messageText
        messageToAdd.ipAddress = "127.0.0.1"
        messageToAdd.userAgent = "iOS"
        
        // set conversation
        messageToAdd.conversationId = self.conversation.id
        
        // set agent
        let loggedInAgent = CacheManager.getAgent(UserData.getLoggedInAgentId()!)
        messageToAdd.agent = loggedInAgent
        
        // clear text field
        self.sendTextField.text = ""
        
        // add message locally
        self.conversation.messages.append(messageToAdd)
        self.setMessages()
        
        self.tableView.reloadData()
        self.scrollToBottom(animated: false)
        
        // update on server
        ApiManager.sendMessage(conversation: self.conversation, message: messageToAdd) {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Scroll to bottom
    
    func scrollToBottom(animated animated: Bool) {
        if self.messages.count > 0 {
            let lastMessageIndex = NSIndexPath(forRow: self.messages.count, inSection: 0)
            tableView.scrollToRowAtIndexPath(lastMessageIndex, atScrollPosition: .Bottom, animated: animated)
        }
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
                
                scrollToBottom(animated: false)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        adjustView(KeyboardDirection.Down)
    }
    
    func adjustView(direction: KeyboardDirection) {
        let bottomInset = (direction == KeyboardDirection.Up) ? kbHeight : 0.0
        self.bottomSpaceConstraint.constant = bottomInset
        self.view.layoutIfNeeded()
    }
    
    // MARK: - Dismiss keyboard
    
    @IBAction func dismissKeyboard(sender: UIGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - Scroll View Delegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        sendTextField.resignFirstResponder()
    }
    
    // MARK: - Go to favorites
    
    @IBAction func goToFavorites(sender: UIGestureRecognizer) {
        if sender.state == .Ended {
            let point = sender.locationInView(tableView)
            if let indexPath = tableView.indexPathForRowAtPoint(point) {
                let message = self.messages[indexPath.row]
                performSegueWithIdentifier("favorites", sender: message.agent)
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "favorites" {
            let agent = sender as! Agent
            let vc = segue.destinationViewController as! FavoritesViewController
            vc.agent = agent
        }
    }
}

class ConversationMessageTableViewCell: UITableViewCell {
    @IBOutlet var dateView: MessageDateView!
    @IBOutlet var agentImageView: UIImageView!
    @IBOutlet var messageBubbleImageView: UIImageView!
    @IBOutlet var messageTextView: UITextView!
    @IBOutlet var messageTextViewWidth: NSLayoutConstraint!
    @IBOutlet var messageTextViewRightMargin: NSLayoutConstraint!
}

class MessageDateView: UIView {
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var border1Thickness: NSLayoutConstraint!
    @IBOutlet var border2Thickness: NSLayoutConstraint!
}
