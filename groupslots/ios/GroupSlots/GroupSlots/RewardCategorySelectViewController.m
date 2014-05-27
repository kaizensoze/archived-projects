//
//  RewardCategoryViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/9/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "RewardCategorySelectViewController.h"

@interface RewardCategorySelectViewController ()
    @property (strong, nonatomic) NSArray *rewardCategoryData;
@end

@implementation RewardCategorySelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CachedData *cachedData = appDelegate.cachedData;
    if (!cachedData.rewardCategories) {
        [self loadCategories];
    } else {
        self.rewardCategoryData = cachedData.rewardCategories;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
}

- (void)loadCategories {
    [self addTestRewardCategories];
}

- (void)addTestRewardCategories {
    self.rewardCategoryData = [[NSArray alloc] initWithObjects:
                                  @"Electronics",
                                  @"Entertainment",
                                  @"Food",
                                  @"Lifestyle",
                                  @"Travel",
                                  nil];
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rewardCategoryData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *rewardCategory = [self.rewardCategoryData objectAtIndex:indexPath.row];
    
    static NSString *cellIdentifier = @"RewardCategoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = rewardCategory;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *rewardCategory = self.rewardCategoryData[indexPath.row];
    [self.delegate rewardCategorySelected:rewardCategory];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
