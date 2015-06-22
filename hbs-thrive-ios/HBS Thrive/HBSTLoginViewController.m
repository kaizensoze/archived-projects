//
//  HBSTLoginViewController.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/4/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTLoginViewController.h"
#import "HBSTConfirmationViewController.h"

@interface HBSTLoginViewController ()
    @property (weak, nonatomic) IBOutlet UITextField *emailTextField;
    @property (weak, nonatomic) IBOutlet UIButton *sendEmailVerificationButton;

    @property (nonatomic) CGPoint originalCenter;
@end

@implementation HBSTLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [HBSTUtil colorFromHex:@"64964b"];
    self.originalCenter = self.view.center;
    
    [HBSTCustomStyler styleTextField:self.emailTextField];
    [HBSTCustomStyler styleButton:self.sendEmailVerificationButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.emailTextField resignFirstResponder];
    [self unregisterForKeyboardNotifications];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)sendEmailVerification:(id)sender {
    NSString *trimmedEmail = [HBSTUtil trim:self.emailTextField.text];
    BOOL validEmail = [self validateEmail:trimmedEmail];
    if (validEmail) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        NSString *url = [NSString stringWithFormat:@"%@/%@/send-verification-request", SITE_DOMAIN, API_PATH];
        NSDictionary *parameters = @{ @"email": trimmedEmail, @"device": appDelegate.deviceId };
        [appDelegate.requestManager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
            [hud hide:YES];
            
            if (JSON[@"errors"]) {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Error"
                                      message:JSON[@"errors"][0]
                                      delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:@"Email us", @"OK", nil];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            } else {
                [Flurry logEvent:@"Email Submit"];
                
                // store email on device
                [userDefaults setObject:trimmedEmail forKey:@"email"];
                [userDefaults synchronize];
                
                [self performSegueWithIdentifier:@"goToConfirmation" sender:nil];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DDLogError(@"%@", error);
            [hud hide:YES];
        }];
    }
}

- (BOOL)validateEmail:(NSString *)email {
    if (email.length == 0) {
        [HBSTUtil showErrorAlert:@"Please enter your email." delegate:nil];
        return NO;
    }
    if (![self isValidEmail:email]) {
        [HBSTUtil showErrorAlert:@"Please enter a valid email." delegate:nil];
        return NO;
    }
    if (![email hasSuffix:@"hbs.edu"] && !([email isEqualToString:@"jgallo@happyfuncorp.com"]
                                           || [email isEqualToString:@"robb@happyfuncorp.com"]
                                           || [email isEqualToString:@"admin@admin.com"])) {
        [HBSTUtil showErrorAlert:@"Please enter your hbs.edu email." delegate:nil];
        return NO;
    }
    
    return YES;
}

- (BOOL)isValidEmail:(NSString *)email {
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        appDelegate.mailVC = nil;
        appDelegate.mailVC = [[MFMailComposeViewController alloc] init];
        appDelegate.mailVC.mailComposeDelegate = appDelegate;
        [appDelegate.mailVC setToRecipients:@[@"thriveapp@hbs.edu"]];
        [appDelegate.window.rootViewController presentViewController:appDelegate.mailVC animated:YES completion:nil];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendEmailVerification:nil];
    return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
    CGSize kbSize = [[info objectForKeyNotNull:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    float keyboardY = self.view.frame.size.height - kbSize.height;
    float distance = keyboardY - self.emailTextField.frame.origin.y;
    
    float desiredDistance = 150;
    
    if (distance < desiredDistance) {
        float amountToMoveViewCenter = desiredDistance - distance;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25];
        self.view.center = CGPointMake(self.originalCenter.x, self.view.center.y - amountToMoveViewCenter);
        [UIView commitAnimations];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.view.center = self.originalCenter;
    [UIView commitAnimations];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"goToConfirmation"]) {
        HBSTConfirmationViewController *vc = (HBSTConfirmationViewController *)segue.destinationViewController;
        vc.email = [HBSTUtil trim:self.emailTextField.text];
    }
}

@end
