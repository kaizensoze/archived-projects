//
//  FriendsViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/28/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "FriendsViewController.h"
#import "FriendCell.h"
#import "User.h"
#import "Group.h"

@interface FriendsViewController ()

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [appDelegate useMainNav:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return appDelegate.loggedInUser.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    User *friend = [appDelegate.loggedInUser.friends objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"FriendCell";
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.usernameLabel.text = friend.username;
    if (appDelegate.loggedInUser.group == nil || [appDelegate.loggedInUser.group hasUser:friend]) {
        [Util disableButton:cell.inviteToGroupButton];
    } else {
        [Util enableButton:cell.inviteToGroupButton];
    }
    
    return cell;
}

- (IBAction)unfriend:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    User *friend = [appDelegate.loggedInUser.friends objectAtIndex:indexPath.row];
    [appDelegate.loggedInUser.friends removeObject:friend];
    [appDelegate saveLoggedInUserToDevice];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (IBAction)inviteToGroup:(id)sender {
    #warning TODO implement
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
