//
//  FriendSuggestionsViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 11/16/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "FriendSuggestionsViewController.h"
#import "ProfileViewController.h"
#import "MainTabBarController.h"
#import "SocialSignupCell.h"
#import "User.h"

@interface FriendSuggestionsViewController ()
    @property (strong, nonatomic) NSMutableArray *friendSuggestions;
@end

@implementation FriendSuggestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    User *loggedInUser = appDelegate.loggedInUser;
    
    self.friendSuggestions = [[NSMutableArray alloc] init];
    [self.friendSuggestions addObjectsFromArray:loggedInUser.suggestions[@"friends_of_friends"]];
    [self.friendSuggestions addObjectsFromArray:loggedInUser.suggestions[@"reciprocal_friends"]];
    [self.friendSuggestions addObjectsFromArray:loggedInUser.suggestions[@"most_active_users"]];
    [self.friendSuggestions addObjectsFromArray:loggedInUser.suggestions[@"bloggers"]];

    // remove duplicates (need to maintain order otherwise I would've cast to NSSet and back)
    NSArray *copy = [self.friendSuggestions copy];
    NSInteger index = [copy count] - 1;
    for (id object in [copy reverseObjectEnumerator]) {
        if ([self.friendSuggestions indexOfObject:object inRange:NSMakeRange(0, index)] != NSNotFound) {
            [self.friendSuggestions removeObjectAtIndex:index];
        } else {
            // also remove users with no name
            User *user = (User *)self.friendSuggestions[index];
            if (user.isEmpty) {
                [self.friendSuggestions removeObjectAtIndex:index];
            }
        }
        
        index--;
    }
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate.tracker set:kGAIScreenName value:@"Friend Suggestions Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)done:(id)sender {
//    NSString *profileEmail = appDelegate.loggedInUser.email;
//    if ([Util clean:profileEmail].length == 0) {
//        [self performSegueWithIdentifier:@"goToProfile" sender:self];
//    } else {
//        [self performSegueWithIdentifier:@"goToMain" sender:self];
//    }
    
    [self performSegueWithIdentifier:@"goToProfile" sender:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friendSuggestions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SocialSignupCell";
    SocialSignupCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[SocialSignupCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    User *profile = self.friendSuggestions[indexPath.row];
    
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
    
    User *profile = self.friendSuggestions[indexPath.row];
    
    NSString *username = profile.username;
    
    if ([button.currentTitle isEqualToString:@"Follow"]) {
        [Util follow:username];
        [button setTitle:@"Unfollow" forState:UIControlStateNormal];
    } else {
        [Util unfollow:username];
        [button setTitle:@"Follow" forState:UIControlStateNormal];
    }
    [CustomStyler styleButton:button];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Go to profile
    if ([[segue identifier] isEqualToString:@"goToProfile"]) {
        MainTabBarController *tabBarController = segue.destinationViewController;
        UINavigationController *nvc = (UINavigationController *)[tabBarController getViewControllerAtTab:@"Profile"];
        ProfileViewController *profileVC = (ProfileViewController *)nvc.viewControllers[0];
        profileVC.editProfile = YES;
        tabBarController.requestedTabLabel = @"Profile";
    }
}

@end
