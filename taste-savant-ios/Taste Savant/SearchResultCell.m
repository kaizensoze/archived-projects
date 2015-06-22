//
//  SearchResultCell.m
//  Taste Savant
//
//  Created by Joe Gallo on 6/9/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "SearchResultCell.h"

@implementation SearchResultCell

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
    
    // name
    self.nameLabel.textColor = [Util colorFromHex:@"f26522"];
    [Util adjustText:self.nameLabel width:180 height:16];
    
    // price and cuisine
    self.priceAndCuisineLabel.textColor = [Util colorFromHex:@"333333"];
    [Util adjustText:self.priceAndCuisineLabel width:180 height:16];
    
    // address
    self.addressLabel.textColor = [Util colorFromHex:@"333333"];
    [Util adjustText:self.addressLabel width:180 height:16];
    
    // distance
    self.distanceLabel.textColor = [Util colorFromHex:@"999999"];
    if (appDelegate.cityOverride) {
        self.distanceLabel.hidden = YES;
    } else {
        self.distanceLabel.hidden = NO;
    }
}

@end
