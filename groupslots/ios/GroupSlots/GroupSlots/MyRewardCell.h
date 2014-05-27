//
//  MyRewardCell.h
//  GroupSlots
//
//  Created by Joe Gallo on 5/22/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyRewardCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *rewardImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *redeemButton;

@end
