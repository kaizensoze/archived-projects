//
//  RewardCell.h
//  GroupSlots
//
//  Created by Joe Gallo on 5/6/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RewardCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *rewardImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@end
