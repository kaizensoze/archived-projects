//
//  ReviewDetailCell.h
//  Taste Savant
//
//  Created by Joe Gallo on 5/20/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *restaurantNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *scoreImageView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewBodyTextLabel;

@property (weak, nonatomic) IBOutlet UIView *userReviewInfoView;
@property (weak, nonatomic) IBOutlet UILabel *foodLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *ambienceLabel;
@property (weak, nonatomic) IBOutlet UILabel *ambienceScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceScoreLabel;

@property (weak, nonatomic) IBOutlet UILabel *goodDishesLabel;

@property (weak, nonatomic) IBOutlet UIButton *editReviewButton;

@end
