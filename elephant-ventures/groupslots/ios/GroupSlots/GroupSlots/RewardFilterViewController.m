//
//  RewardFilterViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/7/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "RewardFilterViewController.h"
#import "RewardFilters.h"
#import "RewardPointsRange.h"

@interface RewardFilterViewController ()
    @property (weak, nonatomic) IBOutlet UITableView *tableView;
    @property (weak, nonatomic) IBOutlet UIButton *applyButton;
    @property (weak, nonatomic) IBOutlet UIButton *resetButton;
//    @property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@end

@implementation RewardFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [Util colorFromHex:@"585757"];
    
//    self.navigationItem.hidesBackButton = YES;
    
    [Util styleButton2:self.applyButton];
    [Util styleButton2:self.resetButton];
//    [Util styleButton2:self.cancelButton];
    
    if (self.rewardFilters == nil) {
        self.rewardFilters = [[RewardFilters alloc] init];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
}

- (IBAction)applyFilters:(id)sender {
    [self.delegate rewardFiltersSelected:self.rewardFilters];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)resetFilters:(id)sender {
    self.rewardFilters.pointsRange = nil;
    self.rewardFilters.category = nil;
    [self.tableView reloadData];
}

- (IBAction)close:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rewardPointsRangeSelected:(RewardPointsRange *)rewardPointsRange {
    self.rewardFilters.pointsRange = rewardPointsRange;
    [self.tableView reloadData];
}

- (void)rewardCategorySelected:(NSString *)rewardCategory {
    self.rewardFilters.category = rewardCategory;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"RewardFilterCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Points";
            if (self.rewardFilters.pointsRange == nil) {
                cell.detailTextLabel.text = @"<no selection>";
            } else {
                cell.detailTextLabel.text = [self.rewardFilters.pointsRange description];
            }
            break;
        case 1:
            cell.textLabel.text = @"Category";
            if (!self.rewardFilters.category) {
                cell.detailTextLabel.text = @"<no selection>";
            } else {
                cell.detailTextLabel.text = self.rewardFilters.category;
            }
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:@"goToRewardPointsRangeSelect" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"goToRewardCategorySelect" sender:self];
            break;
        default:
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"goToRewardPointsRangeSelect"]) {
        RewardPointsRangeSelectViewController *vc = (RewardPointsRangeSelectViewController *)segue.destinationViewController;
        vc.delegate = self;
    }
    
    if ([[segue identifier] isEqualToString:@"goToRewardCategorySelect"]) {
        RewardCategorySelectViewController *vc = (RewardCategorySelectViewController *)segue.destinationViewController;
        vc.delegate = self;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
