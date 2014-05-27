//
//  RewardPointsViewController.h
//  GroupSlots
//
//  Created by Joe Gallo on 5/9/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RewardPointsRange;

@protocol RewardPointsRangeSelectDelegate
- (void)rewardPointsRangeSelected:(RewardPointsRange *)rewardPointsRange;
@end

@interface RewardPointsRangeSelectViewController : UITableViewController <SocketIODelegate, UITableViewDelegate, UITableViewDataSource>

@property id<RewardPointsRangeSelectDelegate> delegate;

@end
