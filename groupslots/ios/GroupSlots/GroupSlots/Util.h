//
//  Util.h
//  GroupSlots
//
//  Created by Joe Gallo on 4/9/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+ (NSString *)shortName:(NSString *)firstName lastName:(NSString *)lastName;

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

+ (NSDate *)timeMinusMinutes:(NSDate *)date minutes:(int)minutes;

+ (void)disableButton:(UIButton *)button;
+ (void)enableButton:(UIButton *)button;
+ (void)toggleSelected:(UIButton *)button;

+ (NSString *)enumToString:(int)enumVariable;

+ (NSString *)secondsToTimeString:(int)timeInSeconds;

+ (void)checkForBackButton:(UIViewController *)vc;

+ (UIViewController *)determineActiveOrInactiveGroupVC;
+ (void)loadMainViewControllers;

+ (void)addChatTab:(UIViewController *)vc;
+ (void)disableChat;

+ (void)styleButton:(UIButton *)button;
+ (void)styleButton2:(UIButton *)button;
+ (void)styleDisclosureButton:(UIButton *)button;

+ (void)styleTextField:(UITextField *)textField;
+ (void)styleDisclosureTextField:(UITextField *)textField;
+ (void)styleFormTextField:(UITextField *)textField;

+ (void)setFormTableCellBackground:(UITableViewCell *)cell row:(int)row numRows:(int)numRows;

+ (void)setBorder:(UIView *)view width:(float)width color:(UIColor *)color;
+ (void)roundCorners:(UIView *)imageView radius:(float)radius;

+ (void)addSeparator:(UITableViewCell *)cell;
+ (void)addTopSeparator:(UITableViewCell *)cell;

+ (void)setCenterViewController:(UIViewController *)vc;

+ (void)adjustText:(UILabel *)label width:(float)width height:(float)height;

+ (void)triggerIncomingMessage;

@end
