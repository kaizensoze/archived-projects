//
//  BFKFeedback1TableViewCell.m
//  Keeper
//
//  Created by Joe Gallo on 10/24/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import "BFKFeedback1TableViewCell.h"
#import "BFKUtil.h"

@implementation BFKFeedback1TableViewCell

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
    
//    self.backgroundColor = [BFKUtil colorFromHex:@"E6EBF1"];
}

@end
