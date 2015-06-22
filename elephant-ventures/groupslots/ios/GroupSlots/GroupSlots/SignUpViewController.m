//
//  SignUpViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 4/9/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "SignUpViewController.h"
#import "CustomScrollView.h"
#import "FormCell.h"

@interface SignUpViewController ()
    @property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
    @property (weak, nonatomic) IBOutlet UIButton *backButton;
    @property (weak, nonatomic) IBOutlet UILabel *playersClubSignUpLink;
    @property (weak, nonatomic) IBOutlet UITableView *signupFormTableView;
    @property (weak, nonatomic) IBOutlet UITextField *playersClubIdTextField;
    @property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
    @property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
    @property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
    @property (weak, nonatomic) IBOutlet UITextField *emailTextField;
    @property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
    @property (weak, nonatomic) IBOutlet UITextField *passwordConfirmTextField;
    @property (strong, nonatomic) NSArray *textFieldPlaceholders;
    @property (weak, nonatomic) UITextField *activeField;
    @property (weak, nonatomic) IBOutlet UILabel *termsOfServiceLabel;
    @property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // scroll view
    float viewHeight = ((UIView *)self.scrollView.subviews[0]).frame.size.height;
    [self.scrollView setContentSize: CGSizeMake(320, viewHeight)];
    
    // form text field placeholders
    self.textFieldPlaceholders = @[@"Players Club ID",
                                   @"Username",
                                   @"First Name (PC ID)",
                                   @"Last Name (PC ID)",
                                   @"Email Address",
                                   @"Create GS Password",
                                   @"Confirm GS Password"];
    
    // form background color
    self.signupFormTableView.backgroundColor = [UIColor clearColor];
    
    // players club sign up link
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToPlayersClubSignUp:)];
    [self.playersClubSignUpLink addGestureRecognizer:tapGR];
    
    // terms of service label
    UITapGestureRecognizer *tapGR2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToTermsAndServices:)];
    [self.termsOfServiceLabel addGestureRecognizer:tapGR2];
    
    // signup button
    [Util styleButton:self.signUpButton];
    
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

#pragma mark - Players Club Sign Up
- (IBAction)goToPlayersClubSignUp:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.hotwatercasino.com/play.html"]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.textFieldPlaceholders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FormCell";
    FormCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[FormCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    int section = indexPath.section;
    int row = indexPath.row;
    
    // text field
    cell.textField.placeholder = self.textFieldPlaceholders[row];
    cell.textField.delegate = self;
    [self assignTextField:cell.textField];
    [Util styleFormTextField:cell.textField];
    
    // background
    int numRows = [self.signupFormTableView numberOfRowsInSection:section];
    [Util setFormTableCellBackground:cell row:row numRows:numRows];
    
    return cell;
}

- (void)assignTextField:(UITextField *)textField {
    int rowIndex = [self.textFieldPlaceholders indexOfObject:textField.placeholder];
    switch (rowIndex) {
        case 0:
            self.playersClubIdTextField = textField;
            self.playersClubIdTextField.returnKeyType = UIReturnKeyNext;
            self.playersClubIdTextField.delegate = self;
            break;
        case 1:
            self.usernameTextField = textField;
            self.usernameTextField.returnKeyType = UIReturnKeyNext;
            self.usernameTextField.delegate = self;
            break;
        case 2:
            self.firstNameTextField = textField;
            self.firstNameTextField.returnKeyType = UIReturnKeyNext;
            self.firstNameTextField.delegate = self;
            break;
        case 3:
            self.lastNameTextField = textField;
            self.lastNameTextField.returnKeyType = UIReturnKeyNext;
            self.lastNameTextField.delegate = self;
            break;
        case 4:
            self.emailTextField = textField;
            self.emailTextField.returnKeyType = UIReturnKeyNext;
            self.emailTextField.delegate = self;
            break;
        case 5:
            self.passwordTextField = textField;
            self.passwordTextField.returnKeyType = UIReturnKeyNext;
            self.passwordTextField.secureTextEntry = YES;
            break;
        case 6:
            self.passwordConfirmTextField = textField;
            self.passwordConfirmTextField.secureTextEntry = YES;
            self.passwordConfirmTextField.returnKeyType = UIReturnKeyDone;
            self.passwordConfirmTextField.delegate = self;
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.playersClubIdTextField) {
        [self.usernameTextField becomeFirstResponder];
    } else if (textField == self.usernameTextField) {
        [self.firstNameTextField becomeFirstResponder];
    } else if (textField == self.firstNameTextField) {
        [self.lastNameTextField becomeFirstResponder];
    } else if (textField == self.lastNameTextField) {
        [self.emailTextField becomeFirstResponder];
    } else if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self.passwordConfirmTextField becomeFirstResponder];
    } else if (textField == self.passwordConfirmTextField) {
        [self signUp:nil];
    }
    
    return YES;
}

- (IBAction)signUp:(UIButton *)button {
    if ([Util isEmpty:self.playersClubIdTextField]) {
        [Util showErrorAlert:@"Please enter a players club ID." delegate:nil];
    } else if ([Util isEmpty:self.usernameTextField]) {
        [Util showErrorAlert:@"Please enter a username." delegate:nil];
    } else if ([Util isEmpty:self.firstNameTextField]) {
        [Util showErrorAlert:@"Please enter your first name." delegate:nil];
    } else if ([Util isEmpty:self.lastNameTextField]) {
        [Util showErrorAlert:@"Please enter your last name." delegate:nil];
    } else if ([Util isEmpty:self.emailTextField]) {
        [Util showErrorAlert:@"Please enter an email." delegate:nil];
    } else if (![Util isValidEmail:self.emailTextField.text]) {
        [Util showErrorAlert:@"Please enter a valid email." delegate:nil];
    } else if ([Util isEmpty:self.passwordTextField]) {
        [Util showErrorAlert:@"Please enter a password." delegate:nil];
    } else if ([Util isEmpty:self.passwordConfirmTextField]) {
        [Util showErrorAlert:@"Please confirm your password." delegate:nil];
    } else if (![self.passwordTextField.text isEqualToString:self.passwordConfirmTextField.text]) {
        [Util showErrorAlert:@"Passwords do not match" delegate:nil];
    } else {
        #warning FIXME: stubbed out for now
        //        NSDictionary *data = @{@"casinoId" : appDelegate.casinoId,
        //                               @"playersClubId" : self.playersClubIdTextField.text,
        //                               @"username" : self.usernameTextField.text,
        //                               @"firstName" : self.firstNameTextField.text,
        //                               @"lastName" : self.lastNameTextField.text,
        //                               @"email" : self.emailTextField.text,
        //                               @"password" : self.passwordTextField.text
        //                               };
        //        [appDelegate.socketIO sendEvent:@"register" withData:data];
    }
}

- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    NSDictionary *response = [packet dataAsJSON];
    NSString *eventName = response[@"name"];
    NSDictionary *JSON = response[@"args"][0];
    
    if ([eventName isEqualToString:@"register"]) {
        if ([JSON[@"status"] isEqualToString:@"error"]) {
            [Util showErrorAlert:JSON[@"message"] delegate:nil];
        } else {
            [Util showSuccessAlert:@"Successfully registered." delegate:self];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
    float baseY = self.signupFormTableView.frame.origin.y;
    float formCellY = self.activeField.superview.superview.frame.origin.y;
    CGPoint scrollPoint = CGPointMake(0.0, baseY + formCellY - 20);
    
    // height of visible area
    float visibleAreaHeight = self.scrollView.bounds.size.height - appDelegate.keyboardFrame.size.height;
    
    // if scroll will go past bottom of view, adjust scroll point
    if (scrollPoint.y + visibleAreaHeight >= self.scrollView.contentSize.height) {
        scrollPoint = CGPointMake(0.0, self.scrollView.contentSize.height - visibleAreaHeight);
    }
    
    [self.scrollView setContentOffset:scrollPoint animated:YES];
}

#pragma mark - Segues

- (IBAction)goToTermsAndServices:(id)sender {
    #warning TODO: implement
}

@end
