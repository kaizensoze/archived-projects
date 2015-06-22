//
//  SignUpViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 10/25/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()
    @property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
    @property (weak, nonatomic) UITextField *activeField;
    @property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    // background color
    self.view.backgroundColor = [UIColor greenColor];
    
    // scroll view
    UIView *scrollViewSubview = ((UIView *)self.scrollView.subviews[0]);
    [self.scrollView setContentSize:scrollViewSubview.frame.size];
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    // fill in text fields if data available
    if (self.username) {
        self.usernameField.text = self.username;
    }
    if (self.email) {
        self.emailField.text = self.email;
    }
    
    // style text fields
    [CustomStyler styleTextField:self.usernameField];
    [CustomStyler styleTextField:self.emailField];
    [CustomStyler styleTextField:self.passwordField];
    [CustomStyler styleTextField:self.passwordConfirmField];
    
    // style button
    [CustomStyler styleButton:self.createAccountButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate.tracker set:kGAIScreenName value:@"Signup Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resetSomeData];
//    [self unregisterForKeyboardNotifications];
}

- (void)viewDidUnload {
    self.usernameField = nil;
    self.emailField = nil;
    self.passwordField = nil;
    self.passwordConfirmField = nil;
     
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameField) {
        [self.emailField becomeFirstResponder];
    } else if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    } else if (textField == self.passwordField) {
        [self.passwordConfirmField becomeFirstResponder];
    } else if (textField == self.passwordConfirmField) {
        [self signUp:nil];
    }
    
    return YES;
}

- (IBAction)signUp:(id)sender {
    if (![self validatePreSubmit]) {
        return;
    }
    
    [self signupSubmit];
}

- (BOOL)validatePreSubmit {
    // Validate username.
    if ([Util isEmptyTextField:self.usernameField]) {
        [Util showErrorAlert:@"Please enter a username." delegate:self];
        return NO;
    }
    
    // Validate email.
    if ([Util isEmptyTextField:self.emailField]) {
        [Util showErrorAlert:@"Please enter your email address." delegate:self];
        return NO;
    }
    if (![Util emailValid:self.emailField.text]) {
        [Util showErrorAlert:@"Please enter a valid email address." delegate:self];
        return NO;
    }
    
    if ([Util isEmptyTextField:self.passwordField]) {
        [Util showErrorAlert:@"Please enter your password." delegate:self];
        return NO;
    }
    
    if ([Util isEmptyTextField:self.passwordConfirmField]) {
        [Util showErrorAlert:@"Please confirm your password." delegate:self];
        return NO;
    }
    
    // Check that password and passwordConfirm match.
    if (![self.passwordField.text isEqualToString:self.passwordConfirmField.text]) {
        [Util showErrorAlert:@"Passwords do not match." delegate:self];
        return NO;
    }
    
    return YES;
}

- (void)signupSubmit {
    NSString *url = [NSString stringWithFormat: @"%@/register/", API_URL_PREFIX];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:self.usernameField.text forKey:@"username"];
    [params setObject:self.emailField.text forKey:@"email"];
    [params setObject:self.passwordField.text forKey:@"password1"];
    [params setObject:self.passwordConfirmField.text forKey:@"password2"];
    [params setValue:appDelegate.cachedData.nearestCity forKey:@"city"];
    
    DDLogInfo(@"%@ %@", url, params);
    
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"POST" path:url parameters:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        id username = [JSON objectForKeyNotNull:@"username"];
        id email = [JSON objectForKeyNotNull:@"email"];
        if ([username isKindOfClass:[NSArray class]]) {
            [Util showErrorAlert:((NSArray *)username)[0] delegate:self];
        } else if ([email isKindOfClass:[NSArray class]]) {
            [Util showErrorAlert:((NSArray *)email)[0] delegate:self];
        } else {
            // Subscribe to mailchimp list.
//            [self subscribeToMailChimp:self.emailField.text];
            
            // Show activation message and upon clicking OK, go to login page.
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:username forKey:@"registerToLoginRedirectFillinUsername"];
            
            NSString *successMsg = @"An activation email has been sent. You can log in after activating your account.";
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"Success!"
                                  message: successMsg
                                  delegate: self
                                  cancelButtonTitle: nil
                                  otherButtonTitles: @"OK",
                                  nil];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            
            [self resetSomeData];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

- (void)subscribeToMailChimp:(NSString *)email {
    ChimpKit *ck = [[ChimpKit alloc] initWithDelegate:self andApiKey:MAILCHIMP_KEY];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"9e81c4feb0" forKey:@"id"];
    [params setValue:email forKey:@"email_address"];
    [params setValue:@"false" forKey:@"double_optin"];
    [params setValue:@"true" forKey:@"update_existing"];
    
    // note from which city user signed up
    NSString *city = appDelegate.cachedData.nearestCity;
    NSDictionary *interestGroupingStruct = @{
                                             @"name": @"City",
                                             @"groups": [NSString stringWithFormat:@"Mobile - %@", city]
                                             };
    NSArray *groupings = @[interestGroupingStruct];
    
    NSMutableDictionary *mergeVars = [NSMutableDictionary dictionary];
    [mergeVars setValue:groupings forKey:@"groupings"];
    [params setValue:mergeVars forKey:@"merge_vars"];
    
    [ck callApiMethod:@"listSubscribe" withParams:params];
}

- (void)ckRequestSucceeded:(ChimpKit *)ckRequest {
    DDLogInfo(@"HTTP Status Code: %ld", (long)[ckRequest responseStatusCode]);
    DDLogInfo(@"Response String: %@", [ckRequest responseString]);
}

- (void)ckRequestFailed:(NSError *)error {
    DDLogInfo(@"Response Error: %@", error);
}

- (void)resetSomeData {
    self.username = nil;
    self.email = nil;
}

- (IBAction)cancel:(id)sender {
    [self goToMain];
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goToMain {
    if (appDelegate.loginSignupAsModal) {
        [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self performSegueWithIdentifier:@"goToMain" sender:self];
    }
}

#pragma mark - Keyboard Notifications

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKeyNotNull:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGPoint scrollPoint = CGPointMake(0.0, self.activeField.frame.origin.y - 10);
    [self.scrollView setContentOffset:scrollPoint animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // NOTE: This should only be called for success alert on dismiss.
    if ([alertView.title isEqualToString:@"Success!"]) {
        [self performSegueWithIdentifier:@"goToLogin" sender:self];
    }
}

@end
