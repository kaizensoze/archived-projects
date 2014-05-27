//
//  ChatViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/2/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatMessage.h"
#import "User.h"
#import "ChatCell.h"
#import "NSDate+TimeAgo.h"

@interface ChatViewController ()
    @property (weak, nonatomic) IBOutlet UITableView *tableView;
    @property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
    @property (weak, nonatomic) IBOutlet UITextField *messageTextField;
    @property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // background
    self.view.backgroundColor = [Util colorFromHex:@"a11201"];
    
    // message text field
    CGRect frame = self.messageTextField.frame;
    frame.origin.y += 1;
    frame.size.height -= 1;
    self.messageTextField.frame = frame;
    self.messageTextField.delegate = self;
    
//    self.messageTextField.textColor = [Util colorFromHex:@"363636"];
    
    // send button
    UIImage *sendButtonImage = [[UIImage imageNamed:@"bar-button2.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(14, 6, 14, 6)];
    [self.sendButton setBackgroundImage:sendButtonImage
                               forState:UIControlStateNormal
                             barMetrics:UIBarMetricsDefault];
    
    // tapping the messages table dismisses keyboard
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(dismissKeyboard:)];
    tapGR.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGR];
    
    // add test messages
    [self addTestChatMessages];
    
    // register keyboard notifications
    [self registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateMessagesTable];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
    [self scrollToLastMessage];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addTestChatMessages {
    self.chatMessages = [[NSMutableArray alloc] init];
    
    ChatMessage *message = [[ChatMessage alloc] initWithUser:appDelegate.loggedInUser
                                                     message:@"Hey...let's pick up the pace!"];
    message.timeCreated = [Util timeMinusMinutes:message.timeCreated minutes:2];
    [self.chatMessages addObject:message];
    
    message = [[ChatMessage alloc] initWithUser:appDelegate.testUsers[@"jim"]
                                        message:@"Go go go!"];
    message.timeCreated = [Util timeMinusMinutes:message.timeCreated minutes:1];
    [self.chatMessages addObject:message];
    
    message = [[ChatMessage alloc] initWithUser:appDelegate.testUsers[@"sam"]
                                            message:@"Shifting into high gear."];
    message.timeCreated = [Util timeMinusMinutes:message.timeCreated minutes:1];
    [self.chatMessages addObject:message];
    
    message = [[ChatMessage alloc] initWithUser:appDelegate.testUsers[@"mike"]
                                        message:@"Let's get more people."];
    [self.chatMessages addObject:message];
    
    message = [[ChatMessage alloc] initWithUser:appDelegate.testUsers[@"kate"]
                                        message:@"Yep, a bunch of people are on their way down."];
    [self.chatMessages addObject:message];
}

- (void)updateMessagesTable {
    [self.tableView reloadData];
    [self scrollToLastMessage];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ChatCell";
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ChatCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    }
    
    ChatMessage *message = [self.chatMessages objectAtIndex:indexPath.row];
    
    // user image
    NSString *userImageName = [NSString stringWithFormat:@"%@.png", [message.user.firstName lowercaseString]];
    [cell.userImageView setImageWithURL:message.user.imageURL
                       placeholderImage:[UIImage imageNamed:userImageName]];
    
    // name
    cell.nameLabel.text = message.user.shortName;
    
    // time ago
    cell.timeAgoLabel.text = [message.timeCreated timeAgo];
    
    // message
    cell.messageLabel.text = message.message;
    
    // adjust height to fit message
    CGSize maxLabelSize = CGSizeMake(cell.messageLabel.frame.size.width, FLT_MAX);
    CGSize messageLabelSize = [message.message sizeWithFont:cell.messageLabel.font
                                          constrainedToSize:maxLabelSize
                                              lineBreakMode:cell.messageLabel.lineBreakMode];
    CGRect messageLabelFrame = cell.messageLabel.frame;
    messageLabelFrame.size.height = messageLabelSize.height;
    cell.messageLabel.frame = messageLabelFrame;
    
    // chat bubble
    cell.chatBubbleView.backgroundColor = [UIColor clearColor];
    
    // adjust height of chat bubble
    int chatBubbleHeight = 27 + messageLabelSize.height + 15;
    CGRect chatBubbleFrame = cell.chatBubbleView.frame;
    chatBubbleFrame.size.height = chatBubbleHeight;
    cell.chatBubbleView.frame = chatBubbleFrame;
    
    // add chat bubble background image
    UIImage *chatBubbleImage = [[UIImage imageNamed:@"chat-bubble.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(33, 114, 14, 114)];
    UIImageView *chatBubbleImageView = [[UIImageView alloc] initWithImage:chatBubbleImage];
    CGRect chatBubbleImageViewFrame = CGRectMake(0, 0, 229, chatBubbleHeight);
    chatBubbleImageView.frame = chatBubbleImageViewFrame;
    chatBubbleImageView.tag = 42;
    [[cell.chatBubbleView viewWithTag:42] removeFromSuperview];
    [cell.chatBubbleView addSubview:chatBubbleImageView];
    [cell.chatBubbleView sendSubviewToBack:chatBubbleImageView];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatMessage *message = [self.chatMessages objectAtIndex:indexPath.row];
    
    CGSize messageLabelSize = [message.message sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0]
                                          constrainedToSize:CGSizeMake(180.0f, MAXFLOAT)
                                              lineBreakMode:NSLineBreakByWordWrapping];
    
    int chatBubbleHeight = 27 + messageLabelSize.height + 15;
    int cellPadding = 21;
    
    return chatBubbleHeight + cellPadding;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.messageTextField) {
        [textField resignFirstResponder];
//        [self sendMessage:nil];
    }
    
    return YES;
}

- (IBAction)sendMessage:(id)sender {
    if ([Util isEmpty:self.messageTextField]) {
        return;
    }
    
    User *user = appDelegate.loggedInUser;
    NSString *messageContent = self.messageTextField.text;
    
    ChatMessage *message = [[ChatMessage alloc] initWithUser:user message:messageContent];
    [self.chatMessages addObject:message];
    [self.tableView reloadData];
    self.messageTextField.text = @"";
    [self scrollToLastMessage];
    
    #warning TODO: send message to backend
}

- (void)scrollToLastMessage {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatMessages.count-1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:NO];
}

#pragma mark - Keyboard Notifications

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect toolbarRect = self.toolbar.frame;
    toolbarRect.origin.y -= kbSize.height;
    self.toolbar.frame = toolbarRect;
    
    CGRect tableRect = self.tableView.frame;
    tableRect.size.height -= kbSize.height;
    self.tableView.frame = tableRect;
    
    [self scrollToLastMessage];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect toolbarRect = self.toolbar.frame;
    toolbarRect.origin.y += kbSize.height;
    self.toolbar.frame = toolbarRect;
    
    CGRect tableRect = self.tableView.frame;
    tableRect.size.height += kbSize.height;
    self.tableView.frame = tableRect;
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.view endEditing:YES];
    [appDelegate.viewDeckController openBottomView];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
