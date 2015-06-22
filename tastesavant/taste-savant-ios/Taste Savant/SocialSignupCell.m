//
//  NowFollowingTableViewCell.m
//  Taste Savant
//
//  Created by Joe Gallo on 3/2/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "SocialSignupCell.h"

@implementation SocialSignupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    // # reviews
    self.numReviewsLabel.textColor = [Util colorFromHex:@"999999"];
    [Util adjustText:self.numReviewsLabel width:142 height:21];
    
    // name
    self.nameLabel.textColor = [Util colorFromHex:@"333333"];
    [Util adjustText:self.nameLabel width:141 height:21];
    
//    [Util adjustText:self.reviewerTypeLabel width:141 height:21];
//    [Util adjustText:self.locationLabel width:141 height:21];
}

@end
