//
//  MenuViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/2/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "MenuViewController.h"
#import "User.h"
#import "Reward.h"
#import "UserInfoCell.h"
#import "SettingCell.h"

@interface MenuViewController ()
    @property (strong, nonatomic) NSArray *settings;
    @property (strong, nonatomic) NSArray *settingsIcons;
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settings = @[@"My Challenge",
                      @"Profile",
                      @"Friends",
                      @"My Activity Log",
                      @"FAQ",
                      @"Terms and Services",
                      @"Log-Out"];
    
    self.settingsIcons = @[@"friends-icon.png",
                           @"profile-icon.png",
                           @"friends-icon.png",
                           @"my-activity-log-icon.png",
                           @"faq-icon.png",
                           @"terms-icon.png",
                           @"logout-icon.png"];
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int numRows = 0;
    switch (section) {
        case 0:
            numRows = 1;
            break;
        case 1:
            numRows = appDelegate.loggedInUser.rewards.count;
            break;
        case 2:
            numRows = self.settings.count;
            break;
    }
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier;
    UITableViewCell *thisCell;
    
    switch (indexPath.section) {
        case 0: {
            cellIdentifier = @"UserInfoCell";
            UserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            User *user = appDelegate.loggedInUser;
            
            // image
            [cell.userImageView setImageWithURL:user.imageURL
                               placeholderImage:[UIImage imageNamed:@"john.png"]];
            
            // name
            cell.nameLabel.text = user.shortName;
            cell.nameLabel.textColor = [UIColor whiteColor];
            
            // status
            NSString *part1 = @"Status: ";
            NSString *part2 = user.status;
            
            NSRange part1Range = NSMakeRange(0, part1.length);
            NSRange part2Range = NSMakeRange(part1.length, part2.length);
            
            UIFont *font1 = [UIFont fontWithName:@"Helvetica" size:13.0];
            UIFont *font2 = [UIFont fontWithName:@"Helvetica-Bold" size:13.0];
            
            UIColor *textColor = [UIColor whiteColor];
            
            NSString *str = [NSString stringWithFormat:@"%@%@", part1, part2];
            
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
            
            [attrStr addAttribute:NSFontAttributeName value:font1 range:part1Range];
            [attrStr addAttribute:NSForegroundColorAttributeName value:textColor range:part1Range];
            
            [attrStr addAttribute:NSFontAttributeName value:font2 range:part2Range];
            [attrStr addAttribute:NSForegroundColorAttributeName value:textColor range:part2Range];
            
            cell.statusLabel.attributedText = [attrStr copy];
            
            // rating
            [cell.ratingImageView setImageWithURL:nil
                                 placeholderImage:[UIImage imageNamed:@"rating.png"]];
            
            thisCell = cell;
            break;
        }
        case 1: {
            cellIdentifier = @"MyRewardCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            Reward *reward = (Reward *)appDelegate.loggedInUser.rewards[indexPath.row];
            
            // label
            cell.textLabel.text = reward.name;
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
            cell.textLabel.textColor = [UIColor whiteColor];
            
            thisCell = cell;
            break;
        }
        case 2: {
            cellIdentifier = @"SettingCell";
            SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[SettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
            // icon
            UIImage *iconImage = [UIImage imageNamed:self.settingsIcons[indexPath.row]];
            cell.iconImageView.image = iconImage;
            
            // label
            cell.label.text = self.settings[indexPath.row];
            cell.label.font = [UIFont fontWithName:@"Helvetica" size:13];
            cell.label.textColor = [UIColor whiteColor];
            
            thisCell = cell;
            break;
        }
    }
    
    return thisCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 0;
    switch (indexPath.section) {
        case 0:
            height = 97;
            break;
        case 1:
            height = 40;
            break;
        case 2:
            height = 40;
            break;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // bottom separator
    [Util addSeparator:cell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 42;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title;
    switch (section) {
        case 0:
            title = @"My profile";
            break;
        case 1:
            title = @"My rewards";
            break;
        case 2:
            title = @"Setting";
            break;
    }
    title = [title uppercaseString];
    
    // view
    UIImage *image = [[UIImage imageNamed:@"table-header.png"]
                      resizableImageWithCapInsets:UIEdgeInsetsMake(21, 129, 21, 129)];
    UIView *view = [[UIImageView alloc] initWithImage:image];
    
    // label
    float labelX = 14;
    float labelWidth = view.frame.size.width - labelX;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 0, labelWidth, view.frame.size.height)];
    label.text = title;
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    
    [view addSubview:label];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 2) {
        return;
    }
    
    UIViewController *vc;
    switch (indexPath.row) {
        case 0:
            vc = [Util determineActiveOrInactiveGroupVC];
            break;
        case 1:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"AccountSettingsNav"];
            break;
        case 2:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"FriendsNav"];
            break;
        case 3:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"ActivityLogNav"];
            break;
        case 4:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"FAQNav"];
            break;
        case 5:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"TermsAndServicesNav"];
            break;
        case 6:
            [self logout];
            break;
//        case 7:
//            vc = [storyboard instantiateViewControllerWithIdentifier:@"MyRewardsNav"];
//            break;
        default:
            break;
    }
    
    if (vc != nil) {
        [Util setCenterViewController:vc];
        [appDelegate.viewDeckController closeLeftView];
    }
}

- (void)logout {
    [appDelegate logout];
}

@end
