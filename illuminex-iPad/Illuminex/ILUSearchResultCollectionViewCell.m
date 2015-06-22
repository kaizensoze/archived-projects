//
//  ILUSearchResultCollectionViewCell.m
//  Illuminex
//
//  Created by Joe Gallo on 10/21/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "ILUSearchResultCollectionViewCell.h"

@implementation ILUSearchResultCollectionViewCell

- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.infoOverlayView.backgroundColor = [ILUUtil colorFromHex:@"2a2243"];
    self.infoOverlayView.alpha = 0.8;
    
    self.itemLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:16];
    self.itemLabel.textColor = [UIColor whiteColor];
    
    self.priceLabel.font = [UIFont fontWithName:@"RobotoCondensed-Italic" size:14];
    self.priceLabel.textColor = [ILUUtil colorFromHex:@"c2c2c2"];
}

@end
