//
//  ILUFlyoutMenuTableViewCell.m
//  Illuminex
//
//  Created by Joe Gallo on 9/24/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "ILUFlyoutMenuTableViewCell.h"

@implementation ILUFlyoutMenuTableViewCell

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
    
    self.backgroundColor = [UIColor clearColor];
    
    self.titleLabel.font = [UIFont fontWithName:@"PlayfairDisplay-BoldItalic" size:16];
    self.titleLabel.textColor = [ILUUtil colorFromHex:@"ebebeb"];
}

@end
