//
//  ConversationsTableViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 5/28/15.
//  Copyright (c) 2016 Nooklyn. All rights reserved.
//

import UIKit

class ConversationsViewController: UIViewController, SliderTabBarViewDelegate {

    // slider tab bar
    @IBOutlet var sliderTabBarView: SliderTabBarView!
    @IBOutlet var sliderTabBarButton1: UIButton!
    @IBOutlet var sliderTabBarButton2: UIButton!
    @IBOutlet var sliderTabBarInitialConstraint: NSLayoutConstraint!
    
    let kInboxTabIndex = 0
    let kArchiveTabIndex = 1
    
    // inbox/archived table views
    @IBOutlet var conversationsTableView: UITableView!
    
    // refresh control
    var refreshControl: UIRefreshControl!
    
    var inboxConversations = [Conversation]()
    var archivedConversations = [Conversation]()
    
    var loading = false
    var skipToMessages = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // navigation bar
        customizeNavigationBar()
        
        // slider tab bar
        setupSliderTabBarView()
        
        // inbox table view
        self.conversationsTableView.estimatedRowHeight = 100.0
        self.conversationsTableView.rowHeight = UITableViewAutomaticDimension
        self.conversationsTableView.tableFooterView = UIView(frame: CGRectZero)
        
        // refresh control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "getConversations", forControlEvents: UIControlEvents.ValueChanged)
        self.conversationsTableView.addSubview(refreshControl)
        
        self.conversationsTableView.alwaysBounceVertical = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // check if logged in
        if !UserData.isLoggedIn() {
            performSegueWithIdentifier("login", sender: nil)
            return
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("Conversations")
        
        // XXX: For whatever reason, after logging in via facebook, viewWillAppear doesn't trigger, but viewDidAppear does.
        //      The reason this is strange is that post facebook login triggers a viewWillAppear on favorites view.
        
        // If we're skipping to messages view [and implicitly creating a new conversation], we don't care about
        // getting list of conversations right now and even want to prevent it because it'll delete all conversation
        // objects, including the temp conversation created before skipping to messages view.
        if !self.skipToMessages {
            self.loading = true
            self.reloadData()
            getConversations()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Setup slider tab bar view
    
    func setupSliderTabBarView() {
        self.sliderTabBarView.buttons = [self.sliderTabBarButton1, self.sliderTabBarButton2]
        self.sliderTabBarView.contentViews = [self.conversationsTableView, self.conversationsTableView]
        self.sliderTabBarView.analyticsViewNames = ["Conversations#Inbox", "Conversations#Archived"]
        self.sliderTabBarView.centerConstraints = [sliderTabBarInitialConstraint]
        self.sliderTabBarView.delegate = self
        
        self.sliderTabBarView.initialize()
    }
    
    // MARK: - SliderTabBarViewDelegate
    
    func sliderTabBarView(sliderTabBarView: SliderTabBarView, tabSelected tabIndex: Int) {
        self.reloadData()
    }
    
    // MARK: - Get conversations
    
    func getConversations() {
        ApiManager.getConversations() { conversations in
            // inbox conversations
            self.inboxConversations = conversations.filter({ !$0.archived }).sort({
                $0.updatedAt.compare($1.updatedAt) == NSComparisonResult.OrderedDescending
            })
            
            // archived conversations
            self.archivedConversations = conversations.filter({ $0.archived }).sort({
                $0.updatedAt.compare($1.updatedAt) == NSComparisonResult.OrderedDescending
            })
            
            self.loading = false
            self.refreshControl.endRefreshing()
            self.reloadData()
        }
    }
    
    func isShowingInbox() -> Bool {
        return self.sliderTabBarView.currentTabIndex == kInboxTabIndex
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isShowingInbox() {
            return inboxConversations.count
        } else {
            return archivedConversations.count
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ConversationCell", forIndexPath: indexPath) as! ConversationTableViewCell
        var conversation: Conversation!
        if self.isShowingInbox() {
            conversation = inboxConversations[indexPath.row]
        } else {
            conversation = archivedConversations[indexPath.row]
        }
        
        // date label
        cell.lastUpdatedLabel?.text = conversation.formattedUpdatedAt
        
        let otherParticipants = conversation.otherParticipants
        
        // image
        cell.conversationImageView.image = nil
        if otherParticipants.count == 1 {
            cell.conversationImageView.setImageWithURL(NSURL(string: (otherParticipants.first?.agent?.thumbnailURL)!)!)
            cell.conversationImageView.contentMode = .ScaleAspectFill
            cell.conversationImageView.round()
        } else {
            cell.conversationImageView.image = UIImage(named: "group-conversation")
            cell.conversationImageView.contentMode = .Center
        }
        
        // participants label
        cell.otherParticipantsLabel?.text = conversation.otherParticipantNames
        
        // last message label
        let lastMessageText = conversation.messages.first?.message ?? ""
        cell.lastMessageLabel.setAttributedTextOnly(lastMessageText)
        
        // flag as read/unread
        if conversation.hasUnreadMessages {
            // bold
            let boldColor = UIColor.blackColor()
            
            cell.lastUpdatedLabel.font = UIFont.boldSystemFontOfSize(10)
            cell.lastUpdatedLabel.textColor = boldColor
            
            cell.otherParticipantsLabel.font = UIFont.boldSystemFontOfSize(16)
            cell.otherParticipantsLabel.textColor = boldColor
            
            // necessary hack since attributed text doesn't work with variant of SF Display UI font
            cell.lastMessageLabel.setAttributedFontOnly(UIFont.boldSystemFontOfSize(10))
        } else {
            // unbold
            cell.lastUpdatedLabel.font = UIFont.systemFontOfSize(10)
            cell.lastUpdatedLabel.textColor = UIColor(hexString: "333333")
            
            cell.otherParticipantsLabel.font = UIFont.systemFontOfSize(16)
            cell.otherParticipantsLabel.textColor = UIColor(hexString: "222222")

            // necessary hack since attributed text doesn't work with variant of SF Display UI font
            cell.lastMessageLabel.setAttributedFontOnly(UIFont.systemFontOfSize(10))
        }
        
        cell.accessoryView = UIImageView(image: UIImage(named: "conversation-cell-accessory-view"))
        
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // NOTE: Actions are implemented in editActionsForRowAtIndexPath. Just need to have this function here so the buttons appear on swipe.
    }
    
    // MARK: - Table view delegate
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if inboxConversations.count > 0 || (self.loading || !self.isShowingInbox()) {
            return nil
        } else {
            let tableHeaderView = tableView.dequeueReusableCellWithIdentifier("TableHeaderCell") as UITableViewCell!
            return tableHeaderView
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if inboxConversations.count > 0 || (self.loading || !self.isShowingInbox()) {
            return 0.0
        } else {
            return 197.0
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if self.isShowingInbox() {
            let archiveAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Archive") { (action, indexPath) in
                let conversation = self.inboxConversations[indexPath.row]
                archiveConversation(conversation)
                self.archivedConversations.append(self.inboxConversations.removeAtIndex(indexPath.row))
                self.reloadData()
            }
            archiveAction.backgroundColor = UIColor(hexString: "2d2d2d")
            return [archiveAction]
        } else {
            let unarchiveAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Move to Inbox") { (action, indexPath) in
                let conversation = self.archivedConversations[indexPath.row]
                unarchiveConversation(conversation)
                self.inboxConversations.append(self.archivedConversations.removeAtIndex(indexPath.row))
                self.reloadData()
            }
            unarchiveAction.backgroundColor = UIColor(hexString: "2d2d2d")
            return [unarchiveAction]
        }
    }
    
    func startNewConversation(contact: Contact) {
        navigationController?.popToRootViewControllerAnimated(false)
        
        // conversation
        let conversation = Conversation()
        conversation.id = "TEMP"
        conversation.contextURL = contact.contextURL
        
        // participant 1
        let participant1 = ConversationParticipant()
        participant1.id = "TEMP1"
        participant1.agent = contact.agent
        participant1.conversationId = conversation.id
        conversation.participants.append(participant1)
        
        // participant 2
        let participant2 = ConversationParticipant()
        participant2.id = "TEMP2"
        participant2.agent = CacheManager.getAgent(UserData.getLoggedInAgentId()!) // logged in agent
        participant2.conversationId = conversation.id
        conversation.participants.append(participant2)
        
        self.reloadData()
        
        // trigger segue to messages view
        performSegueWithIdentifier("messages", sender: conversation)
    }
    
    // MARK: - Reload data
    
    func reloadData() {
        self.conversationsTableView?.reloadData()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "messages" {
            var conversation: Conversation!
            if let convo = sender as? Conversation {
                conversation = convo
            } else {
                let indexPath = self.conversationsTableView.indexPathForSelectedRow!
                if self.isShowingInbox() {
                    conversation = inboxConversations[indexPath.row]
                } else {
                    conversation = archivedConversations[indexPath.row]
                }
            }
            
            let vc = segue.destinationViewController as! ConversationMessagesViewController
            vc.conversation = conversation
        }
    }
}

class ConversationTableViewCell: UITableViewCell {
    @IBOutlet var conversationImageView: UIImageView!
    @IBOutlet var otherParticipantsLabel: UILabel!
    @IBOutlet var lastUpdatedLabel: UILabel!
    @IBOutlet var lastMessageLabel: UILabel!
}

class Contact {
    var agent: Agent!
    var contextURL: String!
}
