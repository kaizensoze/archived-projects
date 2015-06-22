//
//  BFKSidebarViewController.m
//  Keeper
//
//  Created by Joe Gallo on 10/23/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import "BFKSidebarViewController.h"
#import "BFKUtil.h"
#import "BFKFeedback1TableViewCell.h"
#import "BFKFeedback2TableViewCell.h"
#import <SendGrid/SendGrid.h>
#import "BFKAppDelegate.h"
#import "BFKCustomStyler.h"

@interface BFKSidebarViewController ()
    @property (weak, nonatomic) IBOutlet UIView *feedbackView;
    @property (weak, nonatomic) IBOutlet UITableView *feedbackTableView;

    @property (weak, nonatomic) IBOutlet UIView *aboutView;
    @property (weak, nonatomic) IBOutlet UITextView *aboutTextView;

    @property (weak, nonatomic) IBOutlet UIButton *feedbackButton;
    @property (weak, nonatomic) IBOutlet UIButton *aboutButton;

    @property (strong, nonatomic) NSArray *feedbackEntries;
    @property (strong, nonatomic) NSMutableSet *selectedFeedEntries;
    @property (strong, nonatomic) NSString *textViewPlaceholderText;
    @property (strong, nonatomic) UIView *activeView;

    @property (nonatomic) UIEdgeInsets originalContentInsets;
    @property (nonatomic) UIEdgeInsets originalScrollIndicatorInsets;

    @property (strong, nonatomic) NSString *answer1;
    @property (strong, nonatomic) NSString *answer2;
    @property (strong, nonatomic) NSString *email;
@end

@implementation BFKSidebarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [BFKUtil colorFromHex:@"d0d8e2"];
    
    // make navigation bar transparent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;

    // set navigation bar title
    self.navigationItem.title = @"THE NOT-SO-SECRET SIDEBAR";

    NSDictionary *navbarTitleAttributes = @{
                                            NSFontAttributeName: [UIFont fontWithName:@"BrandonGrotesque-Bold" size:12],
                                            NSForegroundColorAttributeName: [BFKUtil colorFromHex:@"693148"]
                                            };
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleAttributes];
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:-2 forBarMetrics:UIBarMetricsDefault];
    
    // allow swipe to close
    UISwipeGestureRecognizer *swipeGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeSidebar)];
    swipeGR.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeGR];
    
    // close button
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                    target:self
                                    action:@selector(closeSidebar)];
    closeButton.tintColor = [BFKUtil colorFromHex:@"693148"];
    self.navigationItem.rightBarButtonItem = closeButton;
    
    // feedback table view
    self.feedbackEntries = @[
                             @"Q1: What do you like about this app?",
                             @"Q2: What can we do better?",
                             @"Email Address"
                             ];
    
    self.selectedFeedEntries = [[NSMutableSet alloc] init];
    
    self.textViewPlaceholderText = @"Answer...";
    
    // feedback table view
    self.feedbackTableView.backgroundColor = [UIColor clearColor];
    self.feedbackTableView.tableHeaderView = [self getTableHeaderView];
    self.feedbackTableView.tableFooterView = [self getTableFooterView];
    
    self.originalContentInsets = self.feedbackTableView.contentInset;
    self.originalScrollIndicatorInsets = self.feedbackTableView.scrollIndicatorInsets;
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapGR.cancelsTouchesInView = NO;
    [self.feedbackTableView addGestureRecognizer:tapGR];
    
    // about text view
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.minimumLineHeight = 16.5;
    paragraphStyle.maximumLineHeight = 16.5;
    
    NSDictionary *attributes = @{
                   NSFontAttributeName: self.aboutTextView.font,
                   NSForegroundColorAttributeName: self.aboutTextView.textColor,
                   NSParagraphStyleAttributeName: paragraphStyle
                   };
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.aboutTextView.text
                                                                           attributes:attributes];
    self.aboutTextView.attributedText = attributedString;
    
    // initially show feedback view
    [self showFeedback:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.tracker set:kGAIScreenName value:@"Sidebar View"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self unregisterForKeyboardNotifications];
    [self.view endEditing:YES];
    [self keyboardWillBeHidden:nil];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Close sidebar

- (void)closeSidebar {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.viewDeckController closeLeftView];
}

#pragma mark - Show feedback

- (IBAction)showFeedback:(id)sender {
    self.feedbackButton.selected = YES;
    self.aboutButton.selected = NO;
    
    self.feedbackView.hidden = NO;
    self.aboutView.hidden = YES;
}

#pragma mark - Show about

- (IBAction)showAbout:(id)sender {
    self.aboutButton.selected = YES;
    self.feedbackButton.selected = NO;
    
    self.aboutView.hidden = NO;
    self.feedbackView.hidden = YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.feedbackEntries.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier;
    
    NSString *feedbackEntryTitle = self.feedbackEntries[indexPath.section];
    
    // email address feedback cell
    if ([feedbackEntryTitle isEqualToString:@"Email Address"]) {
        cellIdentifier = @"Feedback2Cell";
        
        BFKFeedback2TableViewCell *cell = (BFKFeedback2TableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[BFKFeedback2TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        if (!self.email) {
            cell.textField.text = @"";
        }
        
        return cell;
    }
    
    // question feedback cell
    cellIdentifier = @"Feedback1Cell";
    
    BFKFeedback1TableViewCell *cell = (BFKFeedback1TableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[BFKFeedback1TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.label.text = feedbackEntryTitle;
    
    if (!self.answer1 && indexPath.section == 0 && indexPath.row == 0) {
        cell.textView.text = @"";
    }
    if (!self.answer2 && indexPath.section == 1 && indexPath.row == 0) {
        cell.textView.text = @"";
    }
    
    if ([BFKUtil isEmpty:cell.textView.text] || [cell.textView.text isEqualToString:self.textViewPlaceholderText]) {
        cell.textView.text = self.textViewPlaceholderText;
        cell.textView.textColor = [BFKUtil colorFromHex:@"693148" alpha:0.65];
    } else {
        if (indexPath.section == 0) {
            cell.textView.text = self.answer1;
        } else {
            cell.textView.text = self.answer2;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *feedbackEntryTitle = self.feedbackEntries[indexPath.section];
    if ([feedbackEntryTitle isEqualToString:@"Email Address"]) {
        return 50;
    }
    
    NSInteger section = indexPath.section;
    
    if ([self.selectedFeedEntries containsObject:@(section)]) {
        return 150;
    } else {
        return 50;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    
    if ([self.selectedFeedEntries containsObject:@(section)]) {
        [self.selectedFeedEntries removeObject:@(section)];
    } else {
        [self.selectedFeedEntries addObject:@(section)];
    }
    
    [tableView beginUpdates];
    [tableView endUpdates];
}

- (UIView *)getTableHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.feedbackTableView.bounds.size.width, 140)];
    
    // label 1
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, self.feedbackTableView.bounds.size.width, 24)];
    label1.text = @"Let's make great things—together.";
    label1.font = [UIFont fontWithName:@"BrandonGrotesque-Medium" size:18];
    label1.textColor = [BFKUtil colorFromHex:@"693148"];
    label1.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:label1];
    
    // label 2
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.minimumLineHeight = 15;
    paragraphStyle.maximumLineHeight = 15;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont fontWithName:@"BrandonGrotesque-Regular" size:12],
                                 NSForegroundColorAttributeName: [BFKUtil colorFromHex:@"693148"],
                                 NSParagraphStyleAttributeName: paragraphStyle
                                 };
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:@"Community feedback fuels everything we do. We'd love to hear\nyour thoughts, it helps us make better products for everyone."
                                                                           attributes:attributes];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 82, self.feedbackTableView.bounds.size.width, 35)];
    label2.attributedText = attributedString;
    label2.textAlignment = NSTextAlignmentCenter;
    label2.numberOfLines = 0;
    [headerView addSubview:label2];
    
    return headerView;
}

- (UIView *)getTableFooterView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.feedbackTableView.bounds.size.width, 190)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(19, 77, 271, 42);
    [button setTitle:@"SUBMIT" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(submitFeedback:) forControlEvents:UIControlEventTouchUpInside];
    [BFKCustomStyler styleButton:button];
    [footerView addSubview:button];
    
    return footerView;
}

#pragma mark - Submit feedback

- (IBAction)submitFeedback:(id)sender {
    // email
    if ([BFKUtil isEmpty:self.email]) {
        [BFKUtil showAlert:@"" message:@"Please enter an email." delegate:nil];
        return;
    }
    if (![self isValidEmail:self.email]) {
        [BFKUtil showAlert:@"" message:@"Please enter a valid email." delegate:nil];
        return;
    }
    
    // Q1
    NSString *question1 = self.feedbackEntries[0];
    
    if (!self.answer1) {
        self.answer1 = @"";
    }
    
    // Q2
    NSString *question2 = self.feedbackEntries[1];
    
    if (!self.answer2) {
        self.answer2 = @"";
    }
    
    if (([BFKUtil isEmpty:self.answer1] || [self.answer1 isEqualToString:self.textViewPlaceholderText])
        && ([BFKUtil isEmpty:self.answer2]  || [self.answer2 isEqualToString:self.textViewPlaceholderText])) {
        [BFKUtil showAlert:@"" message:@"Please answer at least one question." delegate:nil];
        return;
    }
    
//    DDLogInfo(@"%@ %@", self.answer1, self.answer2);

    // create and send email
    SendGrid *sendgrid = [SendGrid apiUser:@"keeperapi" apiKey:@"climbingFigs9"];

    SendGridEmail *email = [[SendGridEmail alloc] init];
    email.to = @"hello@baronfig.com";
    email.from = self.email;
    email.subject = @"Keeper Feedback";
    email.html = [NSString stringWithFormat:@"<b>%@</b><br />%@<br /><br /><b>%@</b><br />%@<br /><br />",
                  question1, self.answer1, question2, self.answer2];
    email.text = [NSString stringWithFormat:@"%@\r\n%@\r\n\r\n%@\r\n%@",
                  question1, self.answer1, question2, self.answer2];

    [sendgrid sendWithWeb:email];
    
    [BFKUtil showAlert:@"" message:@"Feedback sent, thank you!" delegate:nil];
    
    [self clearFeedbackForm];
}

- (void)clearFeedbackForm {
    self.answer1 = nil;
    self.answer2 = nil;
    self.email = nil;
    
    // collapse table
    self.selectedFeedEntries = [[NSMutableSet alloc] init];
    
    [self.feedbackTableView reloadData];
}

#pragma mark - Valid email check

- (BOOL)isValidEmail:(NSString *)email {
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark - Visit website

- (IBAction)visitWebsite:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.baronfig.com/"]];
}

#pragma mark - Touches ended

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.activeView = textView;
    
    if ([textView.text isEqualToString:self.textViewPlaceholderText]) {
        textView.text = @"";
        textView.textColor = [BFKUtil colorFromHex:@"693148"];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        textView.text = self.textViewPlaceholderText;
        textView.textColor = [BFKUtil colorFromHex:@"693148" alpha:0.65];
    } else {
        NSInteger section = [self.feedbackTableView indexPathForCell:(UITableViewCell *)textView.superview.superview].section;
        if (section == 0) {
            self.answer1 = textView.text;
        } else {
            self.answer2 = textView.text;
        }
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeView = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (![BFKUtil isEmpty:textField.text]) {
        self.email = textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Keyboard Notifications

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWillBeShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(-10, 0.0, kbSize.height - 35, 0.0);
    self.feedbackTableView.contentInset = contentInsets;
    self.feedbackTableView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeView.frame.origin)) {
        [self.feedbackTableView scrollRectToVisible:self.activeView.frame animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    self.feedbackTableView.contentInset = self.originalContentInsets;
    self.feedbackTableView.scrollIndicatorInsets = self.originalScrollIndicatorInsets;
}

@end
