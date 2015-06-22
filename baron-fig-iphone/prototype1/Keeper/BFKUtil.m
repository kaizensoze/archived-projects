//
//  BFKUtil.m
//  Keeper
//
//  Created by Joe Gallo on 10/22/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import "BFKUtil.h"

@implementation BFKUtil

#pragma mark - Color from hex

+ (UIColor *)colorFromHex:(NSString *)hexCode {  // Ex: "FFFFFF"
    NSScanner *scanner = [NSScanner scannerWithString:[hexCode substringFromIndex:0]];
    unsigned int hexCodeValue = 0;
    [scanner scanHexInt:&hexCodeValue];
    
    return [UIColor colorWithRed:((float)((hexCodeValue & 0xFF0000) >> 16))/255.0 green:((float)((hexCodeValue & 0xFF00) >> 8))/255.0 blue:((float)(hexCodeValue & 0xFF))/255.0 alpha:1.0];
}

+ (UIColor *)colorFromHex:(NSString *)hexCode alpha:(float)alpha {  // Ex: "FFFFFF"
    NSScanner *scanner = [NSScanner scannerWithString:[hexCode substringFromIndex:0]];
    unsigned int hexCodeValue = 0;
    [scanner scanHexInt:&hexCodeValue];
    
    return [UIColor colorWithRed:((float)((hexCodeValue & 0xFF0000) >> 16))/255.0 green:((float)((hexCodeValue & 0xFF00) >> 8))/255.0 blue:((float)(hexCodeValue & 0xFF))/255.0 alpha:alpha];
}


+ (void)removeTextViewPadding:(UITextView *)textView {
    // remove padding
    textView.textContainer.lineFragmentPadding = 0;
    textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - UIAlertView

+ (void)showAlert:(NSString *)title message:(NSString *)message delegate:(id)delegate {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:delegate
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK",
                          nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

+ (void)showErrorAlert:(NSString *)message delegate:(id)delegate {
    [self showAlert:@"Error" message:message delegate:delegate];
}

#pragma mark - String functions

+ (NSString *)trim:(NSString *)str {
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

+ (BOOL)isEmpty:(NSString *)str {
    BOOL isEmpty = (str == nil || [self trim:str].length == 0);
    return isEmpty;
}

+ (NSString *)getShortName:(NSString *)firstName lastName:(NSString *)lastName {
    if ([BFKUtil isEmpty:firstName] && [BFKUtil isEmpty:lastName]) {
        return @"";
    }
    
    NSString *lastNameAbbrev;
    if (lastName.length > 0) {
        lastNameAbbrev = [lastName substringToIndex:1];
    } else {
        lastNameAbbrev = lastName;
    }
    return [NSString stringWithFormat:@"%@ %@.", firstName, lastNameAbbrev];
}

+ (NSString *)singlePluralize:(NSString *)string amount:(int)amount {
    if (amount == 1) {
        return string;
    } else {
        return [string stringByAppendingString:@"s"];
    }
}

#pragma mark - Text size

+ (CGSize)textSize:(NSString *)text font:(UIFont *)font width:(float)width height:(float)height {
    CGRect textRect = [text boundingRectWithSize:CGSizeMake(width, height)
                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                      attributes:@{NSFontAttributeName:font}
                                         context:nil];
    CGSize newSize = textRect.size;
    
    // text with low hanging letters (g, j, q) for certain fonts get cut off so round the height up
    newSize.height = ceil(newSize.height);
    
    return newSize;
}

#pragma mark - Adjust text

+ (void)adjustText:(UIView *)view width:(float)width height:(float)height {
    NSString *text;
    UIFont *font;
    if ([view isKindOfClass:[UILabel class]]) {
        UILabel *label = ((UILabel *)view);
        if (label.attributedText) {
            text = label.attributedText.string;
        } else {
            text = label.text;
        }
        font = ((UILabel *)view).font;
        //        DDLogInfo(@"adjustText: %@ %@ %f %f (UILabel)", text, font, width, height);
    } else if ([view isKindOfClass:[UITextView class]]) {
        UITextView *textView = ((UITextView *)view);
        if (textView.attributedText) {
            text = textView.attributedText.string;
        } else {
            text = textView.text;
        }
        font = ((UITextView *)view).font;
        //        DDLogInfo(@"adjustText: %@ %@ %f %f (TextView)", text, font, width, height);
    } else {
        return;
    }
    
    CGSize newSize = [BFKUtil textSize:text font:font width:width height:height];
    CGRect newFrame = CGRectMake(view.frame.origin.x,
                                 view.frame.origin.y,
                                 newSize.width,
                                 newSize.height);
    view.frame = newFrame;
}

#pragma mark - Rotate Layer Infinite

+ (void)rotateLayerInfinite:(CALayer *)layer {
    CABasicAnimation *rotation;
    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = [NSNumber numberWithFloat:0];
    rotation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
    rotation.duration = 0.7f; // speed
    rotation.repeatCount = HUGE_VALF; // repeat forever
    [layer removeAllAnimations];
    [layer addAnimation:rotation forKey:@"Spin"];
}

#pragma mark - Wobble

+ (void)wobble:(UIView *)view {
    CGAffineTransform leftWobble = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-0.5));
    CGAffineTransform rightWobble = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(0.5));
    
    view.transform = leftWobble;
    
    [UIView beginAnimations:@"wobble" context:nil];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:INT_MAX];
    [UIView setAnimationDuration:0.1];
    [UIView setAnimationDelegate:self];
    view.transform = rightWobble;
    [UIView commitAnimations];
}

#pragma mark - Set border

+ (void)setBorder:(UIView *)view {
    [self setBorder:view width:1.0 color:[UIColor blackColor]];
}

+ (void)setBorder:(UIView *)view color:(UIColor *)color {
    [self setBorder:view width:1.0 color:color];
}

+ (void)setBorder:(UIView *)view width:(float)width color:(UIColor *)color {
    view.layer.borderWidth = width;
    view.layer.borderColor = color.CGColor;
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