//
//  RewardConfigViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/6/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "ChallengeSetupViewController.h"
#import "Reward.h"
#import "PlayModeHelpViewController.h"
#import "User.h"
#import "Group.h"
#import "Challenge.h"

@interface ChallengeSetupViewController ()
    @property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
    @property (weak, nonatomic) IBOutlet UILabel *rewardNameLabel;
    @property (weak, nonatomic) IBOutlet UILabel *rewardPointsLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *rewardImageView;
    @property (weak, nonatomic) IBOutlet UIButton *howManyButton;
    @property (weak, nonatomic) IBOutlet UIButton *playModeButton;
    @property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;
    @property (weak, nonatomic) IBOutlet UIButton *confirmChallengeButton;

    @property (weak, nonatomic) UITextField *activeField;
@end

@implementation ChallengeSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [Util colorFromHex:@"3f3f3f"];
    
    // scroll view
    float viewHeight = ((UIView *)self.scrollView.subviews[0]).frame.size.height;
    [self.scrollView setContentSize: CGSizeMake(320, viewHeight)];
    ((UIView *)self.scrollView.subviews[0]).backgroundColor = [UIColor clearColor];
    
    [Util styleDisclosureButton:self.howManyButton];
    [Util styleDisclosureButton:self.playModeButton];
    [Util styleDisclosureTextField:self.groupNameTextField];
    
    [Util styleButton2:self.confirmChallengeButton];
    
    [self fillInView];
    
    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
}

- (void)fillInView {
    [self.rewardImageView setImageWithURL:[Util makeURL:self.reward.imageURL]
                         placeholderImage:[UIImage imageNamed:self.reward.testImagePath]];
    
    self.rewardNameLabel.text = self.reward.name;
    self.rewardPointsLabel.text = [NSString stringWithFormat:@"%@ pts", [self.reward formattedPoints]];
    
    // separator
    UIImage *image = [[UIImage imageNamed:@"table-separator"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImageView *separatorView = [[UIImageView alloc] initWithImage:image];
    
    float imageHeight = image.size.height;
    separatorView.frame = CGRectMake(14, 182, 290, imageHeight);
    [self.view addSubview:separatorView];
}

- (IBAction)showActionSheet:(UIButton *)button {
    UIActionSheet *actionSheet;
    
    if (button == self.howManyButton) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose how many."
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"One per player", @"One per group", nil];
        actionSheet.tag = 1;
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose play mode."
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"Straight Play", @"Scavenger Hunt", nil];
        actionSheet.tag = 2;
    }
    [actionSheet showInView:[self.view superview]];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIButton *button;
    if (actionSheet.tag == 1) {
        button = self.howManyButton;
    } else {
        button = self.playModeButton;
    }
    
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        [button setTitle:[actionSheet buttonTitleAtIndex:buttonIndex] forState:UIControlStateNormal];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (!appDelegate.loggedInUser.group) {
            appDelegate.loggedInUser.group = [[Group alloc] init];
        }
        appDelegate.loggedInUser.group.name = self.groupNameTextField.text;
        
        Challenge *challenge = [[Challenge alloc] initWithGroup:appDelegate.loggedInUser.group reward:self.reward];
        challenge.rewardQuantityType = self.howManyButton.currentTitle;
        challenge.playMode = self.playModeButton.currentTitle;
        #warning FIXME: this should be from server and not set by client
        challenge.timeLimit = 30*60;
        challenge.numStages = 2;
        
        DDLogInfo(@"%@", challenge);
        
        appDelegate.loggedInUser.challenge = challenge;
        #warning TODO: communicate with server
        [appDelegate saveLoggedInUserToDevice];
        
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"GroupPageActiveNav"];
        [Util setCenterViewController:vc];
    }
}

- (IBAction)confirmChallenge:(id)sender {
    if ([self.howManyButton.currentTitle isEqualToString:@"How many players"]) {
        [Util showErrorAlert:@"Please select how many." delegate:nil];
    } else if ([self.playModeButton.currentTitle isEqualToString:@"Choose play mode"]) {
        [Util showErrorAlert:@"Please select play mode." delegate:nil];
    } else if ([Util isEmpty:self.groupNameTextField]) {
        [Util showErrorAlert:@"Please enter a group name." delegate:nil];
    } else {
        [Util showConfirmCustomCancel:@"Create challenge?"
                              message:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes" delegate:self];
    }
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    if (CGRectIsEmpty(appDelegate.keyboardFrame)) {
        NSDictionary* info = [aNotification userInfo];
        CGRect kbFrame = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        appDelegate.keyboardFrame = kbFrame;
    }
    [self shiftScrollView];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)shiftScrollView {
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, appDelegate.keyboardFrame.size.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // calculate where to scroll to
    CGPoint scrollPoint = CGPointMake(0.0, self.activeField.frame.origin.y - 20);
    
    // height of visible area
    float visibleAreaHeight = self.scrollView.bounds.size.height - appDelegate.keyboardFrame.size.height;
    
    // if scroll will go past bottom of view, adjust scroll point
    if (scrollPoint.y + visibleAreaHeight >= self.scrollView.contentSize.height) {
        scrollPoint = CGPointMake(0.0, self.scrollView.contentSize.height - visibleAreaHeight);
    }
    
    [self.scrollView setContentOffset:scrollPoint animated:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
