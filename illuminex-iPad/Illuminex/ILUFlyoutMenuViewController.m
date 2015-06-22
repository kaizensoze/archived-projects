//
//  ILUFlyoutMenuTableViewController.m
//  Illuminex
//
//  Created by Joe Gallo on 9/23/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "ILUFlyoutMenuViewController.h"
#import "ILUFlyoutMenuTableViewCell.h"

@interface ILUFlyoutMenuViewController ()
    @property (weak, nonatomic) IBOutlet UIView *topBar;
    @property (weak, nonatomic) IBOutlet UITableView *tableView1;
    @property (weak, nonatomic) IBOutlet UITableView *tableView2;
    @property (weak, nonatomic) IBOutlet UILabel *copyrightLabel;

    @property (strong, nonatomic) NSArray *group1;
    @property (strong, nonatomic) NSArray *group2;
@end

@implementation ILUFlyoutMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topBar.backgroundColor = [ILUUtil colorFromHex:@"f0f0ee"];
    
    self.view.backgroundColor = [ILUUtil colorFromHex:@"312948" alpha:0.95];
    
    self.tableView1.backgroundColor = [UIColor clearColor];
    self.tableView2.backgroundColor = [UIColor clearColor];
    
    self.tableView1.separatorColor = [ILUUtil colorFromHex:@"4f4861"];
    self.tableView2.separatorColor = [ILUUtil colorFromHex:@"4f4861"];
    
    self.copyrightLabel.text = @"© 2014 Illuminex, All Rights Reserved";
    self.copyrightLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:10];
    self.copyrightLabel.textColor = [ILUUtil colorFromHex:@"7d7d7d"];
    
    self.group1 = @[
                    @{@"label": @"Home", @"icon": @"home", @"icon-frame": [NSValue valueWithCGRect:CGRectMake(40, 17, 16, 15)]},
                    @{@"label": @"Search", @"icon": @"search", @"icon-frame": [NSValue valueWithCGRect:CGRectMake(40, 17, 15, 15)]},
                    @{@"label": @"Saved Searches", @"icon": @"saved-searches", @"icon-frame": [NSValue valueWithCGRect:CGRectMake(43, 19, 12, 12)]},
                    @{@"label": @"Collections / Compare", @"icon": @"collections", @"icon-frame": [NSValue valueWithCGRect:CGRectMake(40, 20, 16, 12)]},
                    @{@"label": @"Settings", @"icon": @"settings", @"icon-frame": [NSValue valueWithCGRect:CGRectMake(40, 17, 15, 15)]},
                    @{@"label": @"Signout", @"icon": @"signout", @"icon-frame": [NSValue valueWithCGRect:CGRectMake(40, 17, 15, 16)]},
                    ];
    self.group2 = @[
                    @{@"label": @"Help", @"icon": @"help", @"icon-frame": [NSValue valueWithCGRect:CGRectMake(40, 18, 15, 15)]},
                    @{@"label": @"Contact Us", @"icon": @"contact", @"icon-frame": [NSValue valueWithCGRect:CGRectMake(40, 20, 15, 10)]},
                    @{@"label": @"Share", @"icon": @"share", @"icon-frame": [NSValue valueWithCGRect:CGRectMake(40, 17, 15, 15)]},
                    ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView1) {
        return self.group1.count;
    } else if (tableView == self.tableView2) {
        return self.group2.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ILUFlyoutMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FlyoutMenuCell" forIndexPath:indexPath];
    
    NSDictionary *menuItem;
    if (tableView == self.tableView1) {
        menuItem = self.group1[indexPath.row];
    } else {
        menuItem = self.group2[indexPath.row];
    }
    
    cell.iconImageView.frame = [menuItem[@"icon-frame"] CGRectValue];
    cell.iconImageView.image = [UIImage imageNamed:menuItem[@"icon"]];
    
    cell.titleLabel.text = menuItem[@"label"];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView1) {
        return 64;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView1) {
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 64)];
        view.image = [UIImage imageNamed:@"flyout-menu-header-background"];
        
        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(55, 25, 85, 15)];
        logoImageView.image = [UIImage imageNamed:@"logo"];
        [view addSubview:logoImageView];
        
        UIImageView *verticalBarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(170, 22, 1, 21)];
        verticalBarImageView.image = [UIImage imageNamed:@"vertical-bar"];
        [view addSubview:verticalBarImageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(190, 21, 72, 21)];
        label.text = @"V.dB";
        label.font = [UIFont fontWithName:@"PlayfairDisplay-BlackItalic" size:20];
        label.textColor = [ILUUtil colorFromHex:@"2a2243"];
        [view addSubview:label];
        
        return view;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            UIViewController *landingPageVC = [storyboard instantiateViewControllerWithIdentifier:@"LandingPage"];
            appDelegate.viewDeckController.centerController = landingPageVC;
            break;
        }
        case 1: {
            UIViewController *searchVC = [storyboard instantiateViewControllerWithIdentifier:@"Search"];
            appDelegate.viewDeckController.centerController = searchVC;
            break;
        }
        case 2: {
            UIViewController *savedSearchesVC = [storyboard instantiateViewControllerWithIdentifier:@"SavedSearches"];
            appDelegate.viewDeckController.centerController = savedSearchesVC;
            break;
        }
        case 3: {
            UIViewController *collectionsVC = [storyboard instantiateViewControllerWithIdentifier:@"Collections"];
            appDelegate.viewDeckController.centerController = collectionsVC;
            break;
        }
    }
    
    [appDelegate.viewDeckController closeLeftView];
}

@end
