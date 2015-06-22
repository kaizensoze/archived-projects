//
//  RewardPointsViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/9/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "RewardPointsRangeSelectViewController.h"
#import "RewardPointsRange.h"

@interface RewardPointsRangeSelectViewController ()
    @property (strong, nonatomic) NSArray *rewardPointsRangeData;
@end

@implementation RewardPointsRangeSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CachedData *cachedData = appDelegate.cachedData;
    if (!cachedData.rewardPointsRanges) {
        [self loadRewardPoints];
    } else {
        self.rewardPointsRangeData = cachedData.rewardPointsRanges;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
}

- (void)loadRewardPoints {
    [self addTestRewardPointRanges];
}

- (void)addTestRewardPointRanges {
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    RewardPointsRange *pointsRange;
    
    pointsRange = [[RewardPointsRange alloc] initWithMin:@50 max:@200];
    [temp addObject:pointsRange];
    
    pointsRange = [[RewardPointsRange alloc] initWithMin:@200 max:@500];
    [temp addObject:pointsRange];
    
    pointsRange = [[RewardPointsRange alloc] initWithMin:@500 max:@2000];
    [temp addObject:pointsRange];
    
    pointsRange = [[RewardPointsRange alloc] initWithMin:@2000 max:@10000];
    [temp addObject:pointsRange];
    
    pointsRange = [[RewardPointsRange alloc] initWithMin:@10000 max:@15000];
    [temp addObject:pointsRange];
    
    self.rewardPointsRangeData = [temp copy];
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rewardPointsRangeData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RewardPointsRange *pointsRange = [self.rewardPointsRangeData objectAtIndex:indexPath.row];
    
    static NSString *cellIdentifier = @"RewardPointsRangeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [pointsRange description];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RewardPointsRange *rewardPointsRange = self.rewardPointsRangeData[indexPath.row];
    [self.delegate rewardPointsRangeSelected:rewardPointsRange];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
