//
//  MyRewardsViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/21/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "MyRewardsViewController.h"
#import "Reward.h"
#import "MyRewardCell.h"
#import "User.h"
#import "MBProgressHUD.h"

@interface MyRewardsViewController ()
    @property (strong, nonatomic) MBProgressHUD *HUD;
@end

@implementation MyRewardsViewController

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
    return appDelegate.loggedInUser.rewards.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Reward *reward = [appDelegate.loggedInUser.rewards objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"MyRewardCell";
    MyRewardCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MyRewardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell.rewardImageView setImageWithURL:[Util makeURL:reward.imageURL]
                         placeholderImage:[UIImage imageNamed:@"reward-default.png"]];
    cell.nameLabel.text = reward.name;
    
    return cell;
}

- (IBAction)showRedemptionCode:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    Reward *reward = [appDelegate.loggedInUser.rewards objectAtIndex:indexPath.row];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.HUD.mode = MBProgressHUDModeText;
    self.HUD.labelText = @"Redemption Code";
    self.HUD.detailsLabelText = [NSString stringWithFormat:@"\n%@", reward.redemptionCode];
    self.HUD.yOffset = -100;
    [self.HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideRedemptionCode:)]];
}

- (IBAction)hideRedemptionCode:(id)sender {
    [self.HUD hide:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
