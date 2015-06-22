//
//  MenuItemCell.m
//  Taste Savant
//
//  Created by Joe Gallo on 5/19/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "MenuItemCell.h"

@implementation MenuItemCell

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
    
    // title
    self.titleLabel.textColor = [Util colorFromHex:@"362f2d"];
    [Util adjustText:self.titleLabel width:232 height:21];
    
    // description
    self.descriptionLabel.textColor = [Util colorFromHex:@"362f2d"];
    [Util adjustText:self.descriptionLabel width:232 height:MAXFLOAT];
    
    // price
    self.priceLabel.textColor = [Util colorFromHex:@"999999"];
    [Util adjustText:self.priceLabel width:40 height:21];
}

@end
