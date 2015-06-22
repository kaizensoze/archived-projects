//
//  BFKUtil.h
//  Mosaic
//
//  Created by Joe Gallo on 10/22/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#ifndef Mosaic_BFKUtil_h
#define Mosaic_BFKUtil_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface BFKUtil : NSObject

+ (UIColor *)colorFromHex:(NSString *)hexCode;
+ (UIColor *)colorFromHex:(NSString *)hexCode alpha:(float)alpha;

+ (void)removeTextViewPadding:(UITextView *)textView;

+ (void)showAlert:(NSString *)title message:(NSString *)message delegate:(id)delegate;
+ (void)showErrorAlert:(NSString *)message delegate:(id)delegate;

+ (BOOL)isEmpty:(NSString *)str;
+ (NSString *)trim:(NSString *)str;

+ (NSString *)getShortName:(NSString *)firstName lastName:(NSString *)lastName;
+ (NSString *)singlePluralize:(NSString *)string amount:(int)amount;

+ (CGSize)textSize:(NSString *)text attributes:(NSDictionary *)attributes width:(float)width height:(float)height;
+ (void)adjustText:(UIView *)view width:(float)width height:(float)height;

+ (void)rotateLayerInfinite:(CALayer *)layer;
+ (void)wobble:(UIView *)view;

+ (void)setBorder:(UIView *)view;
+ (void)setBorder:(UIView *)view color:(UIColor *)color;
+ (void)setBorder:(UIView *)view width:(float)width color:(UIColor *)color;

+ (void)roundCorners:(UIView *)view radius:(float)radius;
+ (void)roundSelectCorners:(UIView *)view corners:(UIRectCorner)corners radius:(float)radius;

@end

#endif
