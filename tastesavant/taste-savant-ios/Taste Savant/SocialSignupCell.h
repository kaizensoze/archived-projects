//
//  NowFollowingTableViewCell.h
//  Taste Savant
//
//  Created by Joe Gallo on 3/2/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SocialSignupCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewerTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *numReviewsLabel;
@property (weak, nonatomic) IBOutlet UIButton *followUnfollowButton;

@end
