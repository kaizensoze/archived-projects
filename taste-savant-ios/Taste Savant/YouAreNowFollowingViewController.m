//
//  YouAreNowFollowingViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 11/16/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "YouAreNowFollowingViewController.h"
#import "SocialSignupCell.h"
#import "User.h"

@interface YouAreNowFollowingViewController ()
    @property (strong, nonatomic) NSArray *nowFollowing;
@end

@implementation YouAreNowFollowingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.nowFollowing = [appDelegate.loggedInUser.following copy];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate.tracker set:kGAIScreenName value:@"You Are Now Following Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.nowFollowing.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SocialSignupCell";
    SocialSignupCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[SocialSignupCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    User *profile = self.nowFollowing[indexPath.row];
    
    // user image
    NSURL *avatarURL = [NSURL URLWithString:profile.imageURL];
    [cell.userImageView setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"profile-placeholder.png"]];
    
    // # reviews label
    cell.numReviewsLabel.text = [[NSString stringWithFormat:@"%ld reviews", (long)profile.numReviews] uppercaseString];
    
    // name label
    cell.nameLabel.text = [NSString stringWithFormat:@"%@", profile.name];
    
//    // type of reviewer label
//    NSString *reviewerTypeDisplay = profile.reviewerTypeDisplay;
//    if (reviewerTypeDisplay == nil || [reviewerTypeDisplay isEqualToString:@"Type of Reviewer"]) {
//        cell.reviewerTypeLabel.text = @"";
//    } else {
//        cell.reviewerTypeLabel.text = reviewerTypeDisplay;
//    }
//    
//    // user location label
//    NSString *profileLocation = profile.location;
//    if (profileLocation == nil || profileLocation.length == 0) {
//        cell.locationLabel.text = @"";
//    } else {
//        cell.locationLabel.text = [NSString stringWithFormat: @"%@ Resident", profileLocation];
//    }
    
    // follow/unfollow button
    [CustomStyler styleButton:cell.followUnfollowButton];
    
    return cell;
}

- (IBAction)followUnfollow:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    // get containing table view cell
    id view = [button superview];
    while (![view isKindOfClass:[UITableViewCell class]]) {
        view = [view superview];
    }
    UITableViewCell *tableViewCell = (UITableViewCell *)view;
    
    // get containing table view
    while (![view isKindOfClass:[UITableView class]]) {
        view = [view superview];
    }
    UITableView *tableView = (UITableView *)view;
    
    // get table view cell index
    NSIndexPath *indexPath = [tableView indexPathForCell:tableViewCell];
    
    User *profile = self.nowFollowing[indexPath.row];
    
    NSString *username = profile.username;
    
    if ([button.currentTitle isEqualToString:@"Follow"]) {
        [Util follow:username];
        [button setTitle:@"Unfollow" forState:UIControlStateNormal];
        [button setTitle:@"Unfollow" forState:UIControlStateHighlighted];
        [button setTitle:@"Unfollow" forState:UIControlStateSelected];
    } else {
        [Util unfollow:username];
        [button setTitle:@"Follow" forState:UIControlStateNormal];
        [button setTitle:@"Follow" forState:UIControlStateHighlighted];
        [button setTitle:@"Follow" forState:UIControlStateSelected];
    }
    [CustomStyler styleButton:button];
}

@end
