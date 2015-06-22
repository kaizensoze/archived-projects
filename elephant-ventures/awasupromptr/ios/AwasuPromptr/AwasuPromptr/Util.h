//
//  Util.h
//  AwasuPromptr
//
//  Created by Joe Gallo on 4/9/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+ (NSString *)clean:(NSString *)str;
+ (BOOL)isEmpty:(UITextField *)textField;
+ (BOOL)isValidEmail:(NSString *)emailStr;

+ (UIColor *)colorFromHex:(NSString *)hexCode;

+ (void)showAlert:(NSString *)title message:(NSString *)message delegate:(id<UIAlertViewDelegate>)delegate;
+ (void)showErrorAlert:(NSString *)message delegate:(id<UIAlertViewDelegate>)delegate;
+ (void)showSuccessAlert:(NSString *)message delegate:(id<UIAlertViewDelegate>)delegate;
+ (void)showConfirm:(NSString *)title message:(NSString *)message otherButtonTitles:(NSString *)otherButtonTitles delegate:(id<UIAlertViewDelegate>)delegate;
+ (void)showConfirmCustomCancel:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles delegate:(id<UIAlertViewDelegate>)delegate;

+ (NSURL *)makeURL:(NSString *)urlString;

+ (NSString *)rangeString:(NSRange)range;

+ (void)styleAsHelpLink:(UILabel *)label;

+ (NSString *)dateToString:(NSDate *)date dateFormat:(NSString *)dateFormatPattern;
+ (NSDate *)stringToDate:(NSString *)str dateFormat:(NSString *)dateFormatPattern;

+ (void)disableButton:(UIButton *)button;
+ (void)enableButton:(UIButton *)button;

+ (NSString *)enumToString:(int)enumVariable;

+ (NSString *)secondsToTimeString:(int)timeInSeconds;

+ (void)addBorder:(UIView *)view;

@end
