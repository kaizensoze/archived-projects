//
//  GroupInviteFacebookViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 6/19/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "GroupInviteFacebookViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "User.h"
#import "GroupInviteFacebookCell.h"
#import "MBProgressHUD.h"

@interface GroupInviteFacebookViewController ()
    @property (strong, nonatomic) NSArray *facebookFriends;
    @property (weak, nonatomic) IBOutlet UITableView *tableView;
    @property (weak, nonatomic) IBOutlet UIButton *cancelButton;
    @property (weak, nonatomic) IBOutlet UIButton *inviteButton;
    @property (strong, nonatomic) UIAlertView *inviteSuccessAlert;
@end

@implementation GroupInviteFacebookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    UIColor *backgroundColor = [Util colorFromHex:@"3f3f3f"];
    
    self.view.backgroundColor = backgroundColor;
    self.tableView.backgroundColor = backgroundColor;
    
    [Util styleButton:self.cancelButton];
    [Util styleButton:self.inviteButton];
    
    [Util disableButton:self.inviteButton];
    
    [self openSession];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Facebook login

- (void)openSession {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error {
    switch (state) {
        case FBSessionStateOpen: {
            // Get user's facebook info.
            [[FBRequest requestForMe] startWithCompletionHandler:
             ^(FBRequestConnection *connection,
               NSDictionary<FBGraphUser> *user,
               NSError *error) {
                 if (!error) {
                     if (!appDelegate.loggedInUser.facebookId) {
                         appDelegate.loggedInUser.facebookId = user[@"id"];
                         [appDelegate saveLoggedInUserToDevice];
                     }
                     
                     [self loadGroupSlotsFacebookFriends];
                 }
             }];
        } break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed: {
            [FBSession.activeSession closeAndClearTokenInformation];
        } break;
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:@"Facebook login failed."  //error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

- (void)loadGroupSlotsFacebookFriends {
    [[FBRequest requestForMyFriends] startWithCompletionHandler:
     ^(FBRequestConnection *connection,
       NSDictionary *result,
       NSError *error) {
         self.facebookFriends = [result objectForKey:@"data"];
//         DDLogInfo(@"%@", self.facebookFriends);
         #warning TODO: get list of all group slots users in server database with facebook id and intersect with facebook friends list
         [self.tableView reloadData];
         [MBProgressHUD hideHUDForView:self.view animated:YES];
     }];
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)invite:(id)sender {
    #warning TODO: create group invite
    
    self.inviteSuccessAlert = [[UIAlertView alloc] initWithTitle:nil
                                                         message:@"Invitation Sent!"
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil];
    [self.inviteSuccessAlert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.facebookFriends subarrayWithRange:NSMakeRange(0, 6)].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *user = [self.facebookFriends objectAtIndex:indexPath.row];
    
    static NSString *cellIdentifier = @"GroupInviteFacebookCell";
    GroupInviteFacebookCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[GroupInviteFacebookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal", user[@"id"]]];
    [cell.userImageView setImageWithURL:imageURL
                   placeholderImage:[UIImage imageNamed:@"user-default.png"]];
    cell.userImageView.layer.cornerRadius = 5.0;
    cell.userImageView.layer.masksToBounds = YES;
    
    cell.nameLabel.text = user[@"name"];
    cell.usernameLabel.text = user[@"username"];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // bottom separator
    [Util addSeparator:cell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [Util enableButton:self.inviteButton];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.tableView indexPathsForSelectedRows].count == 0) {
        [Util disableButton:self.inviteButton];
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView == self.inviteSuccessAlert) {
        [self autoAcceptInvite];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)autoAcceptInvite {
    
}

@end
