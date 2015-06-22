//
//  HBSTConfirmationViewController.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/15/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTConfirmationViewController.h"

@interface HBSTConfirmationViewController ()
    @property (weak, nonatomic) IBOutlet UIButton *backButton;
    @property (weak, nonatomic) IBOutlet UILabel *checkEmailLabel;
    @property (weak, nonatomic) IBOutlet UILabel *emailLabel;
    @property (weak, nonatomic) IBOutlet UILabel *needHelpLabel;
    @property (weak, nonatomic) IBOutlet UIButton *alreadyVerifiedButton;
    @property (weak, nonatomic) IBOutlet UILabel *resendVerificationLabel;

    @property (strong, nonatomic) MFMailComposeViewController *mailVC;
@end

@implementation HBSTConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [HBSTUtil colorFromHex:@"64964b"];
    
    self.backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.emailLabel.text = self.email;
    
    self.checkEmailLabel.textColor = [UIColor whiteColor];
    self.emailLabel.textColor = [UIColor whiteColor];
    self.needHelpLabel.textColor = [UIColor whiteColor];
    self.resendVerificationLabel.textColor = [UIColor whiteColor];
    
    // underline labels
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    self.needHelpLabel.attributedText = [[NSAttributedString alloc] initWithString:self.needHelpLabel.text
                                                                        attributes:underlineAttribute];
    self.resendVerificationLabel.attributedText = [[NSAttributedString alloc] initWithString:self.resendVerificationLabel.text
                                                                                  attributes:underlineAttribute];
    
    [HBSTCustomStyler styleButton:self.alreadyVerifiedButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Help

- (IBAction)showHelp:(id)sender {
    self.mailVC = nil;
    self.mailVC = [[MFMailComposeViewController alloc] init];
    self.mailVC.mailComposeDelegate = self;
    [self.mailVC setToRecipients:@[@"thriveapp@hbs.edu"]];
    [self.mailVC setSubject:@"Thrive@HBS Account Verification Help"];
    [self.mailVC setMessageBody:@"" isHTML:NO];
    
    [self presentViewController:self.mailVC animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    [self.mailVC dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Resend

- (IBAction)resendVerificationRequest:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/send-verification-request", SITE_DOMAIN, API_PATH];
    NSDictionary *parameters = @{ @"email": self.email, @"device": appDelegate.deviceId };
    [appDelegate.requestManager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        [hud hide:YES];
        
        if (JSON[@"errors"]) {
            [HBSTUtil showErrorAlert:JSON[@"errors"][0] delegate:self];
        } else {
            [HBSTUtil showAlert:@"Success!" message:@"Verification sent." delegate:nil];
            [Flurry logEvent:@"Re-Send"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"%@", error);
        [hud hide:YES];
    }];
}

#pragma mark - Check verified

- (IBAction)alreadyVerified:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/check-verified", SITE_DOMAIN, API_PATH];
    NSDictionary *parameters = @{ @"email": self.email, @"device": appDelegate.deviceId };
    [appDelegate.requestManager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        [hud hide:YES];
        
        BOOL verified = [JSON[@"success"] boolValue];
        if (verified) {
            NSString *authToken = JSON[@"auth_token"];
            
            [Flurry logEvent:@"Verify"];
            
            NSString *userType = [JSON objectForKeyNotNull:@"user_type"];
            BOOL isNonstudent = userType && ![userType isEqualToString:@"student"];
            
            // store token on device
            [userDefaults setObject:authToken forKey:@"authToken"];
            #ifndef NONSTUDENT_OVERRIDE
            [userDefaults setBool:isNonstudent forKey:@"isNonstudent"];
            #endif
            [userDefaults synchronize];
            
            // store token with request manager
            NSString *authTokenValue = [NSString stringWithFormat:@"Token token=\"%@\"", authToken];
            [appDelegate.requestManager.requestSerializer setValue:authTokenValue forHTTPHeaderField:@"Authorization"];
            
            // advance to main tabbar view (initially showing home page)
            appDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
        } else {
            if (JSON[@"errors"]) {
                [HBSTUtil showErrorAlert:JSON[@"errors"][0] delegate:self];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"%@", error);
        [hud hide:YES];
    }];
}

@end
