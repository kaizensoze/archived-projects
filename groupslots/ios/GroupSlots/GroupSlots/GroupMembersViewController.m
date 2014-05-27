//
//  InviteViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/2/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "GroupMembersViewController.h"
#import "User.h"
#import "Group.h"
#import "GroupMemberCell.h"

@interface GroupMembersViewController ()
    @property (weak, nonatomic) IBOutlet UIBarButtonItem *inviteButton;
    @property (weak, nonatomic) IBOutlet UITableView *tableView;
    @property (weak, nonatomic) IBOutlet UIButton *leaveGroupButton;
@end

@implementation GroupMembersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // navigation bar
    UIImage *image = [[UIImage imageNamed:@"navigationbar.png"]
                      resizableImageWithCapInsets:UIEdgeInsetsMake(22, 5, 22, 5)];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    UIColor *backgroundColor = [Util colorFromHex:@"3f3f3f"];
    
    // background color
    self.view.backgroundColor = backgroundColor;
    
    // table view
    self.tableView.backgroundColor = backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // leave group button
    [Util styleButton2:self.leaveGroupButton];
    
    if (appDelegate.loggedInUser.group == nil) {
        self.leaveGroupButton.hidden = YES;
    } else {
        self.leaveGroupButton.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return appDelegate.loggedInUser.group.members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"GroupMemberCell";
    GroupMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[GroupMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSArray *groupMembers = [appDelegate.loggedInUser.group.members sortedArrayUsingSelector:@selector(compare:)];
    User *user = [groupMembers objectAtIndex:indexPath.row];
    
    // user image
    NSString *userImageName = [NSString stringWithFormat:@"%@.png", [user.firstName lowercaseString]];
    [cell.userImageView setImageWithURL:user.imageURL
                       placeholderImage:[UIImage imageNamed:userImageName]];
    
    // name label
    cell.nameLabel.text = user.shortName;
    cell.nameLabel.textColor = [UIColor whiteColor];
    
    // friend button
    NSString *imageFilename;
    if ([appDelegate.loggedInUser.friends containsObject:user]) {
        imageFilename = @"unfriend-button.png";
    } else {
        imageFilename = @"friend-button.png";
    }
    UIImage *friendButtonImage = [[UIImage imageNamed:imageFilename]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(13, 12, 13, 12)];
    [cell.friendButton setBackgroundImage:friendButtonImage forState:UIControlStateNormal];
    
//    if ([user isEqual:appDelegate.loggedInUser]) {
//        [cell.friendButton removeFromSuperview];
//    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // bottom separator
    [Util addSeparator:cell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 42;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [@"Group Members" uppercaseString];
    
    // view
    UIImage *image = [[UIImage imageNamed:@"table-header.png"]
                      resizableImageWithCapInsets:UIEdgeInsetsMake(21, 129, 21, 129)];
    UIView *view = [[UIImageView alloc] initWithImage:image];
    
    // header label
    float labelX = 14;
    float labelWidth = view.frame.size.width - labelX;
    float labelHeight = view.frame.size.height;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 0, labelWidth, labelHeight)];
    label.text = title;
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    
    // friend label
    labelX = view.frame.size.width - 56;
    
    UILabel *friendLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 0, 30, labelHeight)];
    friendLabel.text = @"Friend";
    friendLabel.font = [UIFont fontWithName:@"Helvetica" size:10];
    friendLabel.textColor = [UIColor whiteColor];
    friendLabel.backgroundColor = [UIColor clearColor];
    [view addSubview:friendLabel];
    
    return view;
}

- (IBAction)inviteOthers:(id)sender {
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"GroupInvite"];
    [(UINavigationController *)appDelegate.viewDeckController.centerController pushViewController:vc animated:NO];
    
    [appDelegate.viewDeckController closeRightView];
}

- (IBAction)friendUnfriend:(UIButton *)button {
    CGPoint buttonPosition = [button convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    NSArray *groupMembers = [appDelegate.loggedInUser.group.members sortedArrayUsingSelector:@selector(compare:)];
    User *user = [groupMembers objectAtIndex:indexPath.row];
    
    NSString *imageFilename;
    if ([appDelegate.loggedInUser.friends containsObject:user]) {  // remove
        [appDelegate.loggedInUser.friends removeObject:user];
        imageFilename = @"friend-button.png";
    } else {  // add
        [appDelegate.loggedInUser.friends addObject:user];
        imageFilename = @"unfriend-button.png";
    }
    UIImage *friendButtonImage = [[UIImage imageNamed:imageFilename]
                                  resizableImageWithCapInsets:UIEdgeInsetsMake(13, 12, 13, 12)];
    [button setBackgroundImage:friendButtonImage forState:UIControlStateNormal];
    
    [appDelegate saveLoggedInUserToDevice];
}

- (IBAction)leaveGroup:(id)sender {
    [Util showConfirm:@"Leave Group?"
              message:@"You won't be able to chat or play with current group members unless invited back."
    otherButtonTitles:@"Leave"
             delegate:self];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        appDelegate.loggedInUser.group = nil;
        appDelegate.loggedInUser.challenge = nil;
        [appDelegate saveLoggedInUserToDevice];
        [self.tableView reloadData];
        self.leaveGroupButton.hidden = YES;
        
        UIViewController *vc = [Util determineActiveOrInactiveGroupVC];
        [Util setCenterViewController:vc];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
