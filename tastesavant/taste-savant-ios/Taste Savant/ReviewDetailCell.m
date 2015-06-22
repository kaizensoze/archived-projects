//
//  ReviewDetailCell.m
//  Taste Savant
//
//  Created by Joe Gallo on 5/20/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "ReviewDetailCell.h"

@implementation ReviewDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    self.backgroundColor = [UIColor clearColor];
    [super setSelected:selected animated:animated];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    // restaurant name
    self.restaurantNameLabel.textColor = [Util colorFromHex:@"f26c4f"];

    // review body text
    self.reviewBodyTextLabel.textColor = [Util colorFromHex:@"333333"];
    [Util adjustText:self.reviewBodyTextLabel width:217 height:MAXFLOAT];
    
    self.foodLabel.textColor = [Util colorFromHex:@"999999"];
    self.ambienceLabel.textColor = [Util colorFromHex:@"999999"];
    self.serviceLabel.textColor = [Util colorFromHex:@"999999"];
    
    // edit review button
    [self.editReviewButton setTitleColor:[Util colorFromHex:@"f26c4f"] forState:UIControlStateNormal];
//    [CustomStyler setBorder:self.editReviewButton];
}

@end
