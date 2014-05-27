//
//  RewardSelectViewController.h
//  GroupSlots
//
//  Created by Joe Gallo on 5/6/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RewardFilterViewController.h"

@class RewardFilters;

@interface RewardSelectViewController : UIViewController <SocketIODelegate, UITableViewDataSource, UITableViewDelegate, RewardFilterViewDelegate>

@property (strong, nonatomic) RewardFilters *rewardFilters;

@end
