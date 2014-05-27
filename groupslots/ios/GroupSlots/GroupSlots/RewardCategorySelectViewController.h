//
//  RewardCategoryViewController.h
//  GroupSlots
//
//  Created by Joe Gallo on 5/9/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RewardCategorySelectDelegate
- (void)rewardCategorySelected:(NSString *)rewardCategory;
@end

@interface RewardCategorySelectViewController : UITableViewController <SocketIODelegate, UITableViewDelegate, UITableViewDataSource>

@property id<RewardCategorySelectDelegate> delegate;

@end
