//
//  ILUCustomStyler.m
//  Illuminex
//
//  Created by Joe Gallo on 9/23/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "ILUCustomStyler.h"

@implementation ILUCustomStyler

#pragma mark - Style buttons

+ (void)styleButton:(UIButton *)button {
    button.titleLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:15];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.tintColor = [UIColor clearColor];
    
    // background image
    UIEdgeInsets insets = UIEdgeInsetsMake(6, 7, 6, 7);
    UIImage *backgroundImage = [[UIImage imageNamed:@"button"] resizableImageWithCapInsets:insets];
    
    UIEdgeInsets activeInsets = UIEdgeInsetsMake(6, 7, 6, 7);
    UIImage *activeBackgroundImage = [[UIImage imageNamed:@"button-active"] resizableImageWithCapInsets:activeInsets];
    
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    // highlighted
    [button setTitleColor:[ILUUtil colorFromHex:@"7e69cd"] forState:UIControlStateHighlighted];
    [button setBackgroundImage:activeBackgroundImage forState:UIControlStateHighlighted];
    
    // selected
    [button setTitleColor:[ILUUtil colorFromHex:@"7e69cd"] forState:UIControlStateSelected];
    [button setBackgroundImage:activeBackgroundImage forState:UIControlStateSelected];
    
    // highlighted + selected
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted|UIControlStateSelected];
    [button setBackgroundImage:backgroundImage forState:UIControlStateHighlighted|UIControlStateSelected];
}

+ (void)styleSmallButton:(UIButton *)button {
    button.titleLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:15];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.tintColor = [UIColor clearColor];
    
    // background image
    UIEdgeInsets insets = UIEdgeInsetsMake(3, 3, 3, 3);
    UIImage *backgroundImage = [[UIImage imageNamed:@"button-small"] resizableImageWithCapInsets:insets];
    
    UIEdgeInsets activeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
    UIImage *activeBackgroundImage = [[UIImage imageNamed:@"button-small-active"] resizableImageWithCapInsets:activeInsets];
    
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    // highlighted
    [button setTitleColor:[ILUUtil colorFromHex:@"7e69cd"] forState:UIControlStateHighlighted];
    [button setBackgroundImage:activeBackgroundImage forState:UIControlStateHighlighted];
    
    // selected
    [button setTitleColor:[ILUUtil colorFromHex:@"7e69cd"] forState:UIControlStateSelected];
    [button setBackgroundImage:activeBackgroundImage forState:UIControlStateSelected];
    
    // highlighted + selected
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted|UIControlStateSelected];
    [button setBackgroundImage:backgroundImage forState:UIControlStateHighlighted|UIControlStateSelected];
}

+ (void)styleSearchTypeButton:(UIButton *)button {
    button.titleLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:16];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.tintColor = [UIColor clearColor];
    
    // highlighted
    [button setTitleColor:[ILUUtil colorFromHex:@"7e69cd"] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[UIImage imageNamed:@"search-type-button-active"] forState:UIControlStateHighlighted];
    
    // selected
    [button setTitleColor:[ILUUtil colorFromHex:@"7e69cd"] forState:UIControlStateSelected];
    [button setBackgroundImage:[UIImage imageNamed:@"search-type-button-active"] forState:UIControlStateSelected];
    
    // highlighted + selected
    [button setTitleColor:[ILUUtil colorFromHex:@"7e69cd"] forState:UIControlStateHighlighted|UIControlStateSelected];
    [button setBackgroundImage:[UIImage imageNamed:@"search-type-button-active"]
                      forState:UIControlStateHighlighted|UIControlStateSelected];
}

+ (void)styleToggleButton:(UIButton *)button side:(NSString *)side fontSize:(CGFloat)fontSize {
    button.titleLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:fontSize];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.tintColor = [UIColor clearColor];
    
    // background image
    UIEdgeInsets insets;
    UIImage *backgroundImage;
    UIImage *activeBackgroundImage;
    if (side && [side isEqualToString:@"left"]) {
        insets = UIEdgeInsetsMake(5, 5, 5, 2);
        backgroundImage = [[UIImage imageNamed:@"toggle-button-left"] resizableImageWithCapInsets:insets];
        activeBackgroundImage = [[UIImage imageNamed:@"toggle-button-left-active"] resizableImageWithCapInsets:insets];
    } else if (side && [side isEqualToString:@"right"]) {
        insets = UIEdgeInsetsMake(5, 2, 5, 5);
        backgroundImage = [[UIImage imageNamed:@"toggle-button-right"] resizableImageWithCapInsets:insets];
        activeBackgroundImage = [[UIImage imageNamed:@"toggle-button-right-active"] resizableImageWithCapInsets:insets];
    } else {
        insets = UIEdgeInsetsMake(5, 2, 5, 2);
        backgroundImage = [[UIImage imageNamed:@"toggle-button"] resizableImageWithCapInsets:insets];
        activeBackgroundImage = [[UIImage imageNamed:@"toggle-button-active"] resizableImageWithCapInsets:insets];
    }
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    // highlighted
    [button setTitleColor:[ILUUtil colorFromHex:@"7e69cd"] forState:UIControlStateHighlighted];
    [button setBackgroundImage:activeBackgroundImage forState:UIControlStateHighlighted];
    
    // selected
    [button setTitleColor:[ILUUtil colorFromHex:@"7e69cd"] forState:UIControlStateSelected];
    [button setBackgroundImage:activeBackgroundImage forState:UIControlStateSelected];
    
    // highlighted + selected
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted|UIControlStateSelected];
    [button setBackgroundImage:backgroundImage forState:UIControlStateHighlighted|UIControlStateSelected];
}

+ (void)styleSmallToggleButton:(UIButton *)button side:(NSString *)side fontSize:(CGFloat)fontSize {
    button.titleLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:fontSize];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.tintColor = [UIColor clearColor];
    
    // background image
    UIEdgeInsets insets;
    UIImage *backgroundImage;
    UIImage *activeBackgroundImage;
    if (side && [side isEqualToString:@"left"]) {
        insets = UIEdgeInsetsMake(3, 3, 3, 3);
        backgroundImage = [[UIImage imageNamed:@"toggle-button-small-left"] resizableImageWithCapInsets:insets];
        activeBackgroundImage = [[UIImage imageNamed:@"toggle-button-small-left-active"] resizableImageWithCapInsets:insets];
    } else if (side && [side isEqualToString:@"right"]) {
        insets = UIEdgeInsetsMake(3, 3, 3, 3);
        backgroundImage = [[UIImage imageNamed:@"toggle-button-small-right"] resizableImageWithCapInsets:insets];
        activeBackgroundImage = [[UIImage imageNamed:@"toggle-button-small-right-active"] resizableImageWithCapInsets:insets];
    } else {
        insets = UIEdgeInsetsMake(3, 3, 3, 3);
        backgroundImage = [[UIImage imageNamed:@"toggle-button-small"] resizableImageWithCapInsets:insets];
        activeBackgroundImage = [[UIImage imageNamed:@"toggle-button-small-active"] resizableImageWithCapInsets:insets];
    }
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    // highlighted
    [button setTitleColor:[ILUUtil colorFromHex:@"7e69cd"] forState:UIControlStateHighlighted];
    [button setBackgroundImage:activeBackgroundImage forState:UIControlStateHighlighted];
    
    // selected
    [button setTitleColor:[ILUUtil colorFromHex:@"7e69cd"] forState:UIControlStateSelected];
    [button setBackgroundImage:activeBackgroundImage forState:UIControlStateSelected];
    
    // highlighted + selected
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted|UIControlStateSelected];
    [button setBackgroundImage:backgroundImage forState:UIControlStateHighlighted|UIControlStateSelected];
}

+ (void)styleCustomToggleButton:(UIButton *)button side:(NSString *)side subtitleText:(NSString *)subtitleText {
    // make title text clear
    button.titleLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:30];
    [button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    button.tintColor = [UIColor clearColor];
    
    // add custom labels
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 29, button.frame.size.width, 25)];
    label1.text = button.titleLabel.text;
    label1.font = button.titleLabel.font;
    label1.textColor = [UIColor whiteColor];
    label1.textAlignment = NSTextAlignmentCenter;
    [button addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, button.frame.size.width, 45)];
    label2.text = subtitleText;
    label2.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:10];
    label2.textColor = [UIColor whiteColor];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.numberOfLines = 0;
    [button addSubview:label2];
    
    // background image
    UIEdgeInsets insets;
    UIImage *backgroundImage;
    UIImage *activeBackgroundImage;
    if (side && [side isEqualToString:@"left"]) {
        insets = UIEdgeInsetsMake(5, 5, 5, 2);
        backgroundImage = [[UIImage imageNamed:@"toggle-button-left"] resizableImageWithCapInsets:insets];
        activeBackgroundImage = [[UIImage imageNamed:@"toggle-button-left-active"] resizableImageWithCapInsets:insets];
    } else if (side && [side isEqualToString:@"right"]) {
        insets = UIEdgeInsetsMake(5, 2, 5, 5);
        backgroundImage = [[UIImage imageNamed:@"toggle-button-right"] resizableImageWithCapInsets:insets];
        activeBackgroundImage = [[UIImage imageNamed:@"toggle-button-right-active"] resizableImageWithCapInsets:insets];
    } else {
        insets = UIEdgeInsetsMake(5, 2, 5, 2);
        backgroundImage = [[UIImage imageNamed:@"toggle-button"] resizableImageWithCapInsets:insets];
        activeBackgroundImage = [[UIImage imageNamed:@"toggle-button-active"] resizableImageWithCapInsets:insets];
    }
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

+ (void)styleTextField:(UITextField *)textField height:(float)height {
    textField.backgroundColor = [UIColor clearColor];
    textField.borderStyle = UITextBorderStyleNone;
    
    textField.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:50];
    textField.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    textField.tintColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    textField.textAlignment = NSTextAlignmentCenter;
    
    [self setTextFieldHeight:textField height:height];
}

+ (void)setTextFieldHeight:(UITextField *)textField height:(float)height {
    CGRect frame = textField.frame;
    frame.size.height = height;
    textField.frame = frame;
}

#pragma mark - Round corners

+ (void)roundCorners:(UIView *)view radius:(float)radius {
    view.layer.cornerRadius = radius;
    view.layer.masksToBounds = YES;
}

+ (void)roundSelectCorners:(UIView *)view corners:(UIRectCorner)corners radius:(float)radius {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    
    view.layer.mask = maskLayer;
}

@end
