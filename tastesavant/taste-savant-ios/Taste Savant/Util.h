//
//  Util.h
//  Taste Savant
//
//  Created by Joe Gallo on 11/26/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestaurantInfoDelegate.h"

@class Restaurant;
@class Review;

@interface Util : NSObject <UIAlertViewDelegate>

+ (NSString *)dateToString:(NSDate *)date dateFormat:(NSString *)dateFormatPattern;
+ (NSDate *)stringToDate:(NSString *)str dateFormat:(NSString *)dateFormatPattern;

+ (BOOL)emailValid:(NSString *)email;

+ (NSString *)genderLabelForValue:(NSString *)val;
+ (NSString *)genderValueForLabel:(NSString *)label;

+ (NSString *)reviewerTypeLabelForValue:(NSString *)val;
+ (NSString *)reviewerTypeValueForLabel:(NSString *)label;

+ (NSString *)getShortName:(NSString *)firstName lastName:(NSString *)lastName;

+ (Review *)getReview:(NSDictionary *)reviewDict;

+ (NSString *)formattedScore:(NSNumber *)score;
+ (void)hideShowScoreLabel:(UILabel *)scoreLabel score:(NSNumber *)score;

+ (NSNumber *)runWalkDitch:(NSNumber *)score;
+ (UIImage *)runWalkDitchImage:(NSNumber *)score;
+ (UIColor *)runWalkDitchColor:(NSNumber *)score;

+ (UIColor *)colorFromHex:(NSString *)hexCode;

+ (void)follow:(NSString *)username;
+ (void)unfollow:(NSString *)username;

+ (void)showAlert:(NSString *)title message:(NSString *)message delegate:(id)delegate;
+ (void)showErrorAlert:(NSString *)message delegate:(id)delegate;
+ (void)showNetworkingErrorAlert:(NSInteger)statusCode error:(NSError *)error srcFunction:(const char *)srcFunction;

+ (void)showHUDWithTitle:(NSString *)title;
+ (void)hideHUD;

+ (NSString *)clean:(NSString *)str;
+ (BOOL)isEmpty:(NSString *)str;
+ (BOOL)isEmptyTextField:(UITextField *)textField;

+ (NSMutableArray *)logData;

+ (NSString *)encodeString:(NSString *)str;
+ (NSString *)generateParamString:(NSMutableDictionary *)params;

+ (CGSize)textSize:(NSString *)text font:(UIFont *)font width:(float)width height:(float)height;
+ (void)adjustText:(UIView *)view width:(float)width height:(float)height;
+ (void)adjustTextView:(UITextView *)textView;

+ (void)adjustForIOS7:(UIViewController *)vc;
+ (void)adjustForIOS6:(UIViewController *)vc;

+ (void)debugView:(UIView *)view;

@end
