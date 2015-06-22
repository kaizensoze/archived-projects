//
//  ILUCustomStyler.h
//  Illuminex
//
//  Created by Joe Gallo on 9/23/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#ifndef Illuminex_ILUCustomStyler_h
#define Illuminex_ILUCustomStyler_h

@interface ILUCustomStyler : NSObject

+ (void)styleButton:(UIButton *)button;
+ (void)styleSmallButton:(UIButton *)button;
+ (void)styleSearchTypeButton:(UIButton *)button;
+ (void)styleToggleButton:(UIButton *)button side:(NSString *)side fontSize:(CGFloat)fontSize;
+ (void)styleSmallToggleButton:(UIButton *)button side:(NSString *)side fontSize:(CGFloat)fontSize;
+ (void)styleCustomToggleButton:(UIButton *)button side:(NSString *)side subtitleText:(NSString *)subtitleText;
+ (void)adjustButton:(UIButton *)button;

+ (void)styleTextField:(UITextField *)textField height:(float)height;
+ (void)setTextFieldHeight:(UITextField *)textField height:(float)height;

+ (void)roundCorners:(UIView *)view radius:(float)radius;

@end

#endif
