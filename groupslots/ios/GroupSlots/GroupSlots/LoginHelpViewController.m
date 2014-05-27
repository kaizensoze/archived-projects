//
//  LoginHelpViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 4/9/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "LoginHelpViewController.h"

@interface LoginHelpViewController ()
    @property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
    @property (weak, nonatomic) IBOutlet UITextField *emailTextField;
    @property (weak, nonatomic) IBOutlet UIButton *sendReminderButton;
    @property (weak, nonatomic) UITextField *activeField;
@end

@implementation LoginHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // scroll view
    float viewHeight = ((UIView *)self.scrollView.subviews[0]).frame.size.height;
    [self.scrollView setContentSize: CGSizeMake(320, viewHeight)];
    
    // email text field
    [Util styleTextField:self.emailTextField];
    
    // send reminder button
    [Util styleButton:self.sendReminderButton];
    
    // register keyboard notifications
    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)sendReminder:(id)sender {
    if ([Util isEmpty:self.emailTextField]) {
        [Util showErrorAlert:@"Please enter an email." delegate:nil];
    } else if (![Util isValidEmail:self.emailTextField.text]) {
        [Util showErrorAlert:@"Invalid email." delegate:nil];
    } else {
        [Util showSuccessAlert:@"A reminder has been sent." delegate:self];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:TRUE];
}

#pragma mark - Back button
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
    if (!CGRectIsEmpty(appDelegate.keyboardFrame)) {
        [self shiftScrollView];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
