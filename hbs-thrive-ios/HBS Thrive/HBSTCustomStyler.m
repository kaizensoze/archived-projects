//
//  HBSTCustomStyler.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/21/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTCustomStyler.h"

@implementation HBSTCustomStyler

#pragma mark - Style buttons

+ (void)styleButton:(UIButton *)button {
    // background image
    NSString *filename = @"button.png";
    
    UIImage *backgroundImage = [[UIImage imageNamed:filename]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
//    // active background image
//    UIImage *activeBackgroundImage = [[UIImage imageNamed:@"button.png"]
//                                      resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
//
//    [button setBackgroundImage:activeBackgroundImage forState:UIControlStateHighlighted];
//    [button setBackgroundImage:activeBackgroundImage forState:UIControlStateSelected];
    
    button.adjustsImageWhenHighlighted = NO;
    
    // font
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    
    // font color
    [button setTitleColor:[HBSTUtil colorFromHex:@"64964b"] forState:UIControlStateNormal];
}

#pragma mark - Style text fields

+ (void)styleTextField:(UITextField *)textField {
    // change height
    CGRect frameRect = textField.frame;
    frameRect.size.height = 46;
    textField.frame = frameRect;
    
    // font
    textField.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    
    // font color
    textField.textColor = [UIColor whiteColor];
    
    // placeholder color
    [textField setValue:[HBSTUtil colorFromHex:@"bccfb4"] forKeyPath:@"_placeholderLabel.textColor"];
    
    // cursor color
    textField.tintColor = [HBSTUtil colorFromHex:@"bccfb4"];
    
    // border style
    textField.borderStyle = UITextBorderStyleNone;
    
    // add top/bottom border
    CALayer *topBorder = [CALayer layer];
    topBorder.borderColor = [HBSTUtil colorFromHex:@"b2cba5"].CGColor;
    topBorder.borderWidth = 1;
    topBorder.frame = CGRectMake(0, 0, textField.frame.size.width, 1);
    [textField.layer addSublayer:topBorder];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [HBSTUtil colorFromHex:@"b2cba5"].CGColor;
    bottomBorder.borderWidth = 1;
    bottomBorder.frame = CGRectMake(0, textField.frame.size.height-1, textField.frame.size.width, 1);
    [textField.layer addSublayer:bottomBorder];
    
    // left/right padding
    UIView *leftPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 0)];
    textField.leftView = leftPaddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    
//    UIView *rightPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 0)];
//    textField.rightView = rightPaddingView;
//    textField.rightViewMode = UITextFieldViewModeAlways;
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
