//
//  RewardFilterViewController.h
//  GroupSlots
//
//  Created by Joe Gallo on 5/7/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RewardCategorySelectViewController.h"
#import "RewardPointsRangeSelectViewController.h"

@class RewardFilters;

@protocol RewardFilterViewDelegate
- (void)rewardFiltersSelected:(RewardFilters *)rewardFilters;
@end

@interface RewardFilterViewController : UIViewController <SocketIODelegate, UITableViewDelegate, UITableViewDataSource, RewardPointsRangeSelectDelegate, RewardCategorySelectDelegate>

@property (strong, nonatomic) RewardFilters *rewardFilters;
@property id<RewardFilterViewDelegate> delegate;

@end
