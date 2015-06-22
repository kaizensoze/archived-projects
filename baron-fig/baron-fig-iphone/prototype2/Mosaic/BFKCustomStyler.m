//
//  BFKCustomStyler.m
//  Mosaic
//
//  Created by Joe Gallo on 10/22/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import "BFKCustomStyler.h"
#import "BFKUtil.h"

@implementation BFKCustomStyler

#pragma mark - Style buttons

+ (void)styleButton:(UIButton *)button {
    button.titleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Bold" size:12];
    [button setTitleColor:[BFKUtil colorFromHex:@"693148"] forState:UIControlStateNormal];
    button.tintColor = [UIColor clearColor];
    
    // background image
    UIEdgeInsets insets = UIEdgeInsetsMake(6, 6, 6, 6);
    UIImage *backgroundImage = [[UIImage imageNamed:@"button"] resizableImageWithCapInsets:insets];
    UIImage *activeBackgroundImage = [[UIImage imageNamed:@"button-active"] resizableImageWithCapInsets:insets];
    
    // default
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    // highlighted
    [button setBackgroundImage:activeBackgroundImage forState:UIControlStateHighlighted];
    
    // selected
    [button setBackgroundImage:activeBackgroundImage forState:UIControlStateSelected];
    
    // highlighted + selected
    [button setBackgroundImage:backgroundImage forState:UIControlStateHighlighted|UIControlStateSelected];
}

+ (void)adjustButton:(UIButton *)button {
    // image
    if (button.currentImage) {
        [button setImage:button.currentImage forState:UIControlStateHighlighted|UIControlStateSelected];
    } else if (button.currentBackgroundImage) {
        [button setImage:button.currentBackgroundImage forState:UIControlStateHighlighted|UIControlStateSelected];
    }
}

#pragma mark - Style text fields

+ (void)setTextFieldHeight:(UITextField *)textField height:(float)height {
    CGRect frame = textField.frame;
    frame.size.height = height;
    textField.frame = frame;
}

@end
