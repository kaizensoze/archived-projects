//
//  Util.m
//  AwasuPromptr
//
//  Created by Joe Gallo on 4/9/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (NSString *)clean:(NSString *)str {
    NSRange range = [str rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
    NSString *result = [str stringByReplacingCharactersInRange:range withString:@""];
    return result;
}

+ (BOOL)isEmpty:(UITextField *)textField {
    return [self clean:textField.text].length == 0;
}

+ (BOOL)isValidEmail:(NSString *)emailStr {
    NSString *emailRegex =
        @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
        @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
        @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
        @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
        @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
        @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
        @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [regExPredicate evaluateWithObject:emailStr];
    
    return isValid;
}

+ (UIColor *)colorFromHex:(NSString *)hexCode {  // Ex: "#FFFFFF"
    NSScanner *scanner = [NSScanner scannerWithString:[hexCode substringFromIndex:1]];
    unsigned int hexCodeValue = 0;
    [scanner scanHexInt:&hexCodeValue];
    
    return [UIColor colorWithRed:((float)((hexCodeValue & 0xFF0000) >> 16))/255.0 green:((float)((hexCodeValue & 0xFF00) >> 8))/255.0 blue:((float)(hexCodeValue & 0xFF))/255.0 alpha:1.0];
}

+ (void)showAlert:(NSString *)title message:(NSString *)message delegate:(id<UIAlertViewDelegate>)delegate {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:title
                              message:message
                              delegate:delegate
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

+ (void)showErrorAlert:(NSString *)message delegate:(id<UIAlertViewDelegate>)delegate {
    [Util showAlert:@"Error" message:message delegate:delegate];
}

+ (void)showSuccessAlert:(NSString *)message delegate:(id<UIAlertViewDelegate>)delegate {
    [Util showAlert:@"Success" message:message delegate:delegate];
}

+ (void)showConfirm:(NSString *)title message:(NSString *)message otherButtonTitles:(NSString *)otherButtonTitles delegate:(id<UIAlertViewDelegate>)delegate {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:title
                              message:message
                              delegate:delegate
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:otherButtonTitles, nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

+ (void)showConfirmCustomCancel:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles delegate:(id<UIAlertViewDelegate>)delegate {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:title
                              message:message
                              delegate:delegate
                              cancelButtonTitle:cancelButtonTitle
                              otherButtonTitles:otherButtonTitles, nil];
    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

+ (NSURL *)makeURL:(NSString *)urlString {
    if (!urlString) {
        return nil;
    }
    return [[NSURL alloc] initWithString:urlString];
}

+ (NSString *)rangeString:(NSRange)range {
    return [NSString stringWithFormat:@"%d-%d", range.location, NSMaxRange(range)];
}

+ (void)styleAsHelpLink:(UILabel *)label {
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName : [Util colorFromHex:@"#003366"],
                                 NSBackgroundColorAttributeName : [UIColor clearColor],
                                 NSUnderlineStyleAttributeName : @1
                                 };
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:label.text attributes:attributes];
    label.attributedText = attributedString;
}

+ (NSString *)dateToString:(NSDate *)date dateFormat:(NSString *)dateFormatPattern {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormatPattern];
    NSString *dateStr = [formatter stringFromDate:date];
    return dateStr;
}

+ (NSDate *)stringToDate:(NSString *)str dateFormat:(NSString *)dateFormatPattern {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormatPattern];
    NSDate *date = [formatter dateFromString:str];
    return date;
}

+ (void)disableButton:(UIButton *)button {
    button.enabled = NO;
    button.alpha = 0.5;
}

+ (void)enableButton:(UIButton *)button {
    button.enabled = YES;
    button.alpha = 1;
}

+ (NSString *)enumToString:(int)enumVariable {
    NSString *result;
    
    switch (enumVariable) {
        case SUBMISSION_DUE:
            result = @"SUBMISSION_DUE";
            break;
        case PRICE_INCREASE:
            result = @"PRICE_INCREASE";
            break;
        case HOUSING_AVAILABILITY:
            result = @"HOUSING_AVAILABILITY";
            break;
        default:
            result = @"";
            break;
    }
    
    return result;
}

+ (NSString *)secondsToTimeString:(int)timeInSeconds {
    int minutes = (int)ceil( (float)timeInSeconds / 60 ) % 60;
    int hours = timeInSeconds / (60*60);
    
    return [NSString stringWithFormat:@"%02d:%02d", hours, minutes];
}

+ (void)addBorder:(UIView *)view {
    view.layer.borderColor = [UIColor blackColor].CGColor;
    view.layer.borderWidth = 1.0f;
}

@end
