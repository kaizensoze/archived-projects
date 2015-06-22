//
//  ILUUtil.h
//  Illuminex
//
//  Created by Joe Gallo on 9/23/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#ifndef Illuminex_ILUUtil_h
#define Illuminex_ILUUtil_h

#import <Foundation/Foundation.h>

@interface ILUUtil : NSObject

+ (UIColor *)colorFromHex:(NSString *)hexCode;
+ (UIColor *)colorFromHex:(NSString *)hexCode alpha:(float)alpha;

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

@end

#endif
