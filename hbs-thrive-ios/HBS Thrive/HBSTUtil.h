//
//  HBSTUtil.h
//  HBS Thrive
//
//  Created by Joe Gallo on 8/13/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBSTUtil : NSObject

+ (UIColor *)colorFromHex:(NSString *)hexCode;

+ (BOOL)isToday:(NSDate *)date;

+ (void)removeTextViewPadding:(UITextView *)textView;

+ (void)showAlert:(NSString *)title message:(NSString *)message delegate:(id)delegate;
+ (void)showErrorAlert:(NSString *)message delegate:(id)delegate;

+ (BOOL)isEmpty:(NSString *)str;
+ (NSString *)trim:(NSString *)str;

+ (NSString *)getShortName:(NSString *)firstName lastName:(NSString *)lastName;

+ (CGSize)textSize:(NSString *)text font:(UIFont *)font width:(float)width height:(float)height;
+ (void)adjustText:(UIView *)view width:(float)width height:(float)height;

+ (void)rotateLayerInfinite:(CALayer *)layer;

+ (UIView *)loadingOverlayView:(UIView *)view;

+ (void)setBorder:(UIView *)view;
+ (void)setBorder:(UIView *)view width:(float)width color:(UIColor *)color;

+ (void)makeLink:(UILabel *)label;
+ (void)makePhoneNumberLink:(UILabel *)label;
+ (void)makeEmailLink:(UILabel *)label;

@end
