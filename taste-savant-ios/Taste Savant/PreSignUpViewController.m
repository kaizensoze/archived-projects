//
//  PreSignUpViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 10/25/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "PreSignUpViewController.h"
#import "TWAPIManager.h"
#import "SignUpViewController.h"
#import "LoginViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "User.h"

@interface PreSignUpViewController ()
    @property (nonatomic) BOOL socialMethodChosen;
    @property (weak, nonatomic) IBOutlet UILabel *label1;
    @property (weak, nonatomic) IBOutlet UILabel *label2;
    @property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
    @property (weak, nonatomic) IBOutlet UIButton *loginButton;
@end

@implementation PreSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.label1.textColor = [Util colorFromHex:@"362f2d"];
    self.label2.textColor = [Util colorFromHex:@"362f2d"];
    
    [CustomStyler styleButton:self.createAccountButton];
    [CustomStyler styleButton:self.loginButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [appDelegate refreshTwitterAccounts];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate.tracker set:kGAIScreenName value:@"Pre-Signup Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.socialMethodChosen = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

- (void)loginSucceeded {
    if (appDelegate.newUserCreatedViaSocialAuth || [appDelegate.loggedInUser missingRequiredInfo]) {
        [self goToNewUserScreens];
    } else {
        [self goToMain];
    }
}

- (void)loginFailed {
    self.socialMethodChosen = YES;
    [Util hideHUD];
    [self goToSignUp];
}

- (void)goToMain {
    if (appDelegate.loginSignupAsModal) {
        [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self performSegueWithIdentifier:@"goToMain" sender:self];
    }
}

- (void)goToSignUp {
    [self performSegueWithIdentifier:@"goToSignUp" sender:self];
}

- (void)goToNewUserScreens {
    if (appDelegate.loggedInUser.following.count > 0) {
        [self performSegueWithIdentifier:@"goToYouAreNowFollowing" sender:self];
    } else {
        [self performSegueWithIdentifier:@"goToFriendSuggestions" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Go to sign up.
    if ([[segue identifier] isEqualToString:@"goToSignUp"]) {
        SignUpViewController *vc = segue.destinationViewController;
        
        if (self.socialMethodChosen) {
            if (appDelegate.facebookData != nil) {
                vc.username = [appDelegate.facebookData objectForKeyNotNull:@"username"];
                vc.email = [appDelegate.facebookData objectForKeyNotNull:@"email"];
            }
        }
    }
}

@end
