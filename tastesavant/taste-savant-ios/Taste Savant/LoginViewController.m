//
//  LoginViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 10/25/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "LoginViewController.h"
#import "TWAPIManager.h"
#import "User.h"
#import "MainTabBarController.h"

@interface LoginViewController ()
    @property (strong, nonatomic) User *profileCheck;
    @property (weak, nonatomic) IBOutlet UITextField *usernameField;
    @property (weak, nonatomic) IBOutlet UITextField *passwordField;
    @property (weak, nonatomic) IBOutlet UILabel *forgotLabel;
    @property (weak, nonatomic) IBOutlet UIButton *loginButton;
    @property (weak, nonatomic) IBOutlet UIButton *signupButton;
    @property (weak, nonatomic) IBOutlet UILabel *label1;
    @property (weak, nonatomic) IBOutlet UILabel *label2;
    @property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // scroll view
    UIView *scrollViewSubview = ((UIView *)self.scrollView.subviews[0]);
    [self.scrollView setContentSize:scrollViewSubview.frame.size];
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    [CustomStyler styleTextField:self.usernameField];
    [CustomStyler styleTextField:self.passwordField];
    
    [self styleForgotLabel];
    
    self.label1.textColor = [Util colorFromHex:@"362f2d"];
    self.label2.textColor = [Util colorFromHex:@"362f2d"];
    
    [CustomStyler styleButton:self.loginButton];
    [CustomStyler styleButton:self.signupButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [appDelegate refreshTwitterAccounts];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *fillinUsername = [userDefaults objectForKey:@"registerToLoginRedirectFillinUsername"];
    if (fillinUsername != nil) {
        self.usernameField.text = fillinUsername;
        [self.passwordField becomeFirstResponder];
        [userDefaults removeObjectForKey:@"registerToLoginRedirectFillinUsername"];
        [userDefaults synchronize];
    }
    
    [appDelegate.tracker set:kGAIScreenName value:@"Login Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewDidUnload {
    self.usernameField = nil;
    self.passwordField = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)styleForgotLabel {
    // color
    self.forgotLabel.textColor = [Util colorFromHex:@"f26c4f"];
    
    [self.forgotLabel sizeToFit];
    
    // allow user interaction
    self.forgotLabel.userInteractionEnabled = YES;
    
    // attach event handler
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToPasswordReset:)];
    [self.forgotLabel addGestureRecognizer:tapGR];
}

- (void)goToPasswordReset:(UIGestureRecognizer *)recognizer {
    [self performSegueWithIdentifier:@"goToPasswordReset" sender:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameField) {
        [self.passwordField becomeFirstResponder];
    } else if (textField == self.passwordField) {
        [self login:nil];
    }
    
    return YES;
}

- (IBAction)login:(id)sender {
    if (![self validatePreSubmit]) {
        return;
    }
    
    [self loginSubmit];
}

- (BOOL)validatePreSubmit {
    // Validate username.
    if ([Util isEmptyTextField:self.usernameField]) {
        [Util showErrorAlert:@"Please enter a username." delegate:self];
        return NO;
    }
    
    if ([Util isEmptyTextField:self.passwordField]) {
        [Util showErrorAlert:@"Please enter your password." delegate:self];
        return NO;
    }
    
    return YES;
}

- (void)loginSubmit {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:self.usernameField.text forKey:@"username"];
    [params setObject:self.passwordField.text forKey:@"password"];
    
    appDelegate.loginDelegate = self;
    [appDelegate login:params];
}

- (void)loginSucceeded {
    if (appDelegate.newUserCreatedViaSocialAuth || [appDelegate.loggedInUser missingRequiredInfo]) {
        [self goToNewUserScreens];
    } else {
        [self goToMain];
    }
}

- (void)loginFailed {
    [Util showErrorAlert:@"Invalid username and/or password." delegate:self];
}

- (IBAction)cancel:(id)sender {
    [self goToMain];
}

- (IBAction)facebookLogin:(id)sender {
    appDelegate.loginDelegate = self;
    [appDelegate openSession];
}

- (IBAction)twitterLogin:(id)sender {
    if ([TWAPIManager isLocalTwitterAccountAvailable]) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an Account"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:nil];
        
        for (ACAccount *acct in appDelegate.twitterAccounts) {
            [sheet addButtonWithTitle:acct.username];
        }
        
        sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
        
        [sheet showInView:self.view];
    }
    else {
        [Util showErrorAlert:@"Please add a Twitter account in device settings." delegate:nil];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [Util showHUDWithTitle:nil];
        [appDelegate refreshTwitterAccounts];
        [appDelegate twitterLogin:appDelegate.twitterAccounts[buttonIndex] loginDelegate:self];
    }
}

- (void)goToNewUserScreens {
    if (appDelegate.loggedInUser.following.count > 0) {
        [self performSegueWithIdentifier:@"goToYouAreNowFollowing" sender:self];
    } else {
        [self performSegueWithIdentifier:@"goToFriendSuggestions" sender:self];
    }
}

- (void)goToMain {
    if (appDelegate.loginSignupAsModal) {
        [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self performSegueWithIdentifier:@"goToMain" sender:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}   

@end
