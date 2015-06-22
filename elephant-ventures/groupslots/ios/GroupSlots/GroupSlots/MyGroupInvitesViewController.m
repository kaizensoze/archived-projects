//
//  GroupInvitesViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 6/12/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "MyGroupInvitesViewController.h"
#import "User.h"
#import "GroupInvite.h"
#import "GroupInviteCell.h"
#import "Group.h"

@interface MyGroupInvitesViewController ()
    @property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation MyGroupInvitesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [appDelegate useMainNav:self];
    
    UIColor *backgroundColor = [Util colorFromHex:@"3f3f3f"];
    
    // background color
    self.view.backgroundColor = backgroundColor;
    
    // table view
    self.tableView.backgroundColor = backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return appDelegate.loggedInUser.groupInvites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GroupInviteCell";
    GroupInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GroupInviteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    GroupInvite *groupInvite = [appDelegate.loggedInUser.groupInvites objectAtIndex:indexPath.row];
    
    // inviter image
    NSString *inviterImageName = [NSString stringWithFormat:@"%@.png", [groupInvite.inviter.firstName lowercaseString]];
    [cell.inviterImageView setImageWithURL:groupInvite.inviter.imageURL
                       placeholderImage:[UIImage imageNamed:inviterImageName]];
    
    // inviter label
    cell.inviterLabel.text = groupInvite.inviter.shortName;
    [Util adjustText:cell.inviterLabel width:234 height:15];
    cell.inviterLabel.textColor = [UIColor whiteColor];
    
    // invitation label
    cell.invitationLabel.text = [NSString stringWithFormat:@"Invited you to join %@", groupInvite.inviter.group.name];
    [Util adjustText:cell.invitationLabel width:234 height:14];
    cell.invitationLabel.textColor = [UIColor whiteColor];
    
//    if (groupInvite.status != INVITE_PENDING) {
//        cell.acceptButton.hidden = YES;
//        cell.ignoreButton.hidden = YES;
//        cell.resultLabel.hidden = NO;
//        cell.resultLabel.text = [[[Util enumToString:groupInvite.status] componentsSeparatedByString:@"INVITE_"] lastObject];
//    }
//    
//    if (groupInvite.status == INVITE_ACCEPTED) {
//        cell.resultLabel.textColor = [UIColor greenColor];
//    } else if (groupInvite.status == INVITE_IGNORED) {
//        cell.resultLabel.textColor = [UIColor redColor];
//    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // bottom separator
    [Util addSeparator:cell];
    
    if (indexPath.row == 0) {
        // top separator
        [Util addTopSeparator:cell];
    }
}

- (IBAction)acceptInvite:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    GroupInvite *groupInvite = [appDelegate.loggedInUser.groupInvites objectAtIndex:indexPath.row];
    [self acceptGroupInvite:groupInvite];
    
    [self.tableView reloadData];
}

- (IBAction)ignoreInvite:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    GroupInvite *groupInvite = [appDelegate.loggedInUser.groupInvites objectAtIndex:indexPath.row];
    [self ignoreGroupInvite:groupInvite];
    
    [self.tableView reloadData];
}

- (void)acceptGroupInvite:(GroupInvite *)groupInvite {
    if (appDelegate.loggedInUser.group) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:@"You're already in a group."
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        return;
    }
    
    groupInvite.status = INVITE_ACCEPTED;
    appDelegate.loggedInUser.group = groupInvite.inviter.group;
    #warning TODO: communicate with backend
    [appDelegate saveLoggedInUserToDevice];
}

- (void)ignoreGroupInvite:(GroupInvite *)groupInvite {
    groupInvite.status = INVITE_IGNORED;
    #warning TODO: communicate with backend
    [appDelegate saveLoggedInUserToDevice];
}

@end
