//
//  Util.m
//  Taste Savant
//
//  Created by Joe Gallo on 11/26/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "Util.h"
#import "User.h"
#import "Review.h"
#import "UserReview.h"
#import "CriticReview.h"
#import "MainTabBarController.h"
#import "tgmath.h"

@implementation Util

static BOOL networkErrorAlertShown = NO;

#pragma mark - Date string conversions

+ (NSString *)dateToString:(NSDate *)date dateFormat:(NSString *)dateFormatPattern {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormatPattern];
    NSString *dateStr = [formatter stringFromDate:date];
    return dateStr;
}

+ (NSDate *)stringToDate:(NSString *)str dateFormat:(NSString *)dateFormatPattern {
    if (str == nil || [Util clean:str].length == 0) {
        return nil;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormatPattern];
    
    NSDate *date = nil;
    NSError *error = nil;
    [formatter getObjectValue:&date forString:str range:nil error:&error];
    return date;
}

#pragma mark - Email validation

+ (BOOL)emailValid:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark - Short to long label mapping translations

+ (NSString *)genderLabelForValue:(NSString *)val {
    if ([val isEqualToString:@"M"]) {
        return @"Male";
    } else if ([val isEqualToString:@"F"]) {
        return @"Female";
    } else {
        return nil;
    }
}

+ (NSString *)genderValueForLabel:(NSString *)label {
    if ([label isEqualToString:@"Male"]) {
        return @"M";
    } else if ([label isEqualToString:@"Female"]) {
        return @"F";
    } else {
        return nil;
    }
}

+ (NSString *)reviewerTypeLabelForValue:(NSString *)val {
    if ([val isEqualToString:@"easily_pleased"]) {
        return @"Easily Pleased";
    } else if ([val isEqualToString:@"discerning_diner"]) {
        return @"Discerning Diner";
    } else if ([val isEqualToString:@"middle_of_the_road"]) {
        return @"Middle of the Road";
    } else {
        return nil;
    }
}

+ (NSString *)reviewerTypeValueForLabel:(NSString *)label {
    if ([label isEqualToString:@"Easily Pleased"]) {
        return @"easily_pleased";
    } else if ([label isEqualToString:@"Discerning Diner"]) {
        return @"discerning_diner";
    } else if ([label isEqualToString:@"Middle of the Road"]) {
        return @"middle_of_the_road";
    } else {
        return nil;
    }
}

+ (NSString *)getShortName:(NSString *)firstName lastName:(NSString *)lastName {
    if ([Util isEmpty:firstName] && [Util isEmpty:lastName]) {
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

#pragma mark - Review

+ (Review *)getReview:(NSDictionary *)reviewDict {
    Review *review;
    
    if ([reviewDict objectForKeyNotNull:@"user"]) {
        review = [[UserReview alloc] init];
    } else if ([reviewDict objectForKeyNotNull:@"author"]) {
        review = [[CriticReview alloc] init];
    } else {
        review = [[Review alloc] init];
    }
    
    return review;
}

#pragma mark - Review score

+ (NSString *)formattedScore:(NSNumber *)score {
    NSString *scoreString;
    if (fmod([score floatValue], 1) != 0) {
        scoreString = [NSString stringWithFormat:@"%.1f/10", [score floatValue]];
    } else {
        scoreString = [NSString stringWithFormat:@"%d/10", [score intValue]];
    }
    return scoreString;
}

+ (void)hideShowScoreLabel:(UILabel *)scoreLabel score:(NSNumber *)score {
    if ([score intValue] == 0) {
        scoreLabel.hidden = YES;
    } else {
        scoreLabel.hidden = NO;
    }
}

#pragma mark - RunWalkDitch score

+ (NSNumber *)runWalkDitch:(NSNumber *)score {
    if (!score) {
        return [NSNumber numberWithInt:0];
    }
    
    int scoreVal;
    
    float scoreFloat = [score floatValue];
    if (scoreFloat > 7.0) {
        scoreVal = 1;
    } else if (scoreFloat >= 5.0) {
        scoreVal = 2;
    } else {
        scoreVal = 3;
    }
    return [NSNumber numberWithInt:scoreVal];
}

+ (UIImage *)runWalkDitchImage:(NSNumber *)score {
    NSDictionary *rwdMapping = @{@1:@"love", @2:@"like", @3:@"skip"};
    NSNumber *rwd = [self runWalkDitch:score];
    NSString *rwdName;
    if (!rwdMapping[rwd]) {
        rwdName = @"not-rated";
    } else {
        rwdName = rwdMapping[rwd];
    }
    
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", rwdName]];
}

+ (UIColor *)runWalkDitchColor:(NSNumber *)score {
    NSDictionary *rwdColorMapping = @{
                                      @1:[Util colorFromHex:@"43811b"],
                                      @2:[Util colorFromHex:@"f2a12a"],
                                      @3:[Util colorFromHex:@"b24c47"]
                                      };
    NSNumber *rwd = [Util runWalkDitch:score];
    return rwdColorMapping[rwd];
}

#pragma mark - Color from hex

+ (UIColor *)colorFromHex:(NSString *)hexCode {  // Ex: "FFFFFF"
    NSScanner *scanner = [NSScanner scannerWithString:[hexCode substringFromIndex:0]];
    unsigned int hexCodeValue = 0;
    [scanner scanHexInt:&hexCodeValue];
    
    return [UIColor colorWithRed:((float)((hexCodeValue & 0xFF0000) >> 16))/255.0 green:((float)((hexCodeValue & 0xFF00) >> 8))/255.0 blue:((float)(hexCodeValue & 0xFF))/255.0 alpha:1.0];
}

#pragma mark - Follow/unfollow

+ (void)follow:(NSString *)username {
    NSString *url = [NSString stringWithFormat: @"%@/users/%@/follow/", API_URL_PREFIX, username];
    
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"POST" path:url parameters:nil];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        User *profile = [[User alloc] init];
        profile.username = username;
        
        // if not already following given user then follow them
        if (![appDelegate.loggedInUser.following containsObject:profile]) {
            [appDelegate.loggedInUser.following addObject:profile];
        }
        [appDelegate saveLoggedInUserToDevice];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Util showNetworkingErrorAlert:operation.response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

+ (void)unfollow:(NSString *)username {
    NSString *url = [NSString stringWithFormat: @"%@/users/%@/unfollow/", API_URL_PREFIX, username];
    
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"POST" path:url parameters:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        User *profile = [[User alloc] init];
        profile.username = username;
        
        [appDelegate.loggedInUser.following removeObject:profile];
        [appDelegate saveLoggedInUserToDevice];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Util showNetworkingErrorAlert:operation.response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
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
    
    // clear any temporary screens currently shown
    [Util clearTemporaryScreens];
}

+ (void)showErrorAlert:(NSString *)message delegate:(id)delegate {
    if (!networkErrorAlertShown) {
        [self showAlert:@"Error" message:message delegate:delegate];
    }
}

+ (void)showNetworkingErrorAlert:(NSInteger)statusCode
                           error:(NSError *)error
                     srcFunction:(const char *)srcFunction {
    // check if we're getting an error because the user was deleted via admin interface
    NSString *errorStr = [error description];
    NSUInteger matchLocation = [errorStr rangeOfString:@"Invalid token" options:NSCaseInsensitiveSearch].location;
    BOOL userDeletedViaAdmin = (matchLocation != NSNotFound);
    
    if (userDeletedViaAdmin) {
        [Util handleDeletedUserException];
    } else {
        if (!networkErrorAlertShown) {
            [Util showAlert:@"" message:@"Unable to connect to the network." delegate:self];
            networkErrorAlertShown = YES;
        }
    }
    
    DDLogError(@"%s: Api fail: %@", srcFunction, error);
}

+ (void)handleDeletedUserException {
    [appDelegate logout];
    
    NSString *message = @"The username you were logged in as no longer exists. You have been logged out.";
    [Util showErrorAlert:message delegate:self];
}

#pragma mark - UIAlertViewDelegate

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (![appDelegate.window.rootViewController isKindOfClass:[MainTabBarController class]]) {
        return;
    }
    
    // refresh current tab
    MainTabBarController *tabBarVC = (MainTabBarController *)appDelegate.window.rootViewController;
    [tabBarVC goToTab:nil];
    
    // remove any modal views
    [tabBarVC.selectedViewController dismissViewControllerAnimated:NO completion:nil];
}

+ (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    networkErrorAlertShown = NO;
}

#pragma mark - Clear temporary screens

+ (void)clearTemporaryScreens {
    [appDelegate removeLoadingScreen:nil];
    [Util hideHUD];
}

#pragma mark - Show/hide HUD

+ (void)showHUDWithTitle:(NSString *)title {
    [self hideHUD];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    hud.labelText = title;
}

+ (void)hideHUD {
    [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
}

#pragma mark - String functions

+ (NSString *)clean:(NSString *)str {
    if (!str) {
        return nil;
    }
    NSRange range = [str rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
    NSString *result = [str stringByReplacingCharactersInRange:range withString:@""];
    return result;
}

+ (BOOL)isEmpty:(NSString *)str {
    BOOL isEmpty = (str == nil || [self clean:str].length == 0);
    return isEmpty;
}

+ (BOOL)isEmptyTextField:(UITextField *)textField {
    BOOL isEmpty = [self clean:textField.text].length == 0;
    return isEmpty;
}

#pragma mark - Log

+ (NSMutableArray *)logData {
    NSMutableArray *logData = [[NSMutableArray alloc] init];
    NSArray *sortedLogFileInfos = [appDelegate.fileLogger.logFileManager sortedLogFileInfos];
    for (DDLogFileInfo *logFileInfo in sortedLogFileInfos) {
        NSData *logFileData = [NSData dataWithContentsOfFile:logFileInfo.filePath];
        [logData addObject:logFileData];
    }
    return logData;
}

#pragma mark - Param string

+ (NSString *)generateParamString:(NSMutableDictionary *)params {
    if ([params count] == 0) {
        return @"";
    }
    
    NSString *paramString = @"";
    NSString *paramPrefix = @"?";
    
    for (NSString *key in [params allKeys]) {
        if ([params[key] isKindOfClass:[NSMutableArray class]]) {
            for (NSString *val in params[key]) {
                paramString = [paramString stringByAppendingFormat:@"%@%@=%@", paramPrefix, key, val];
                paramPrefix = @"&";
            }
        } else {
            if ([key isEqualToString:@"q"]) {
                params[key] = [Util encodeString:params[key]];
            }
            paramString = [paramString stringByAppendingFormat:@"%@%@=%@", paramPrefix, key, params[key]];
            paramPrefix = @"&";
        }
    }
    
    return paramString;
}

+ (NSString *)encodeString:(NSString *)str {
    NSString *new = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                          NULL,
                                                                                          (CFStringRef)str,
                                                                                          NULL,
                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                          kCFStringEncodingUTF8 ));
    return new;
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
        text = ((UILabel *)view).text;
        font = ((UILabel *)view).font;
//        DDLogInfo(@"UILabel: %@ %@ %f %f", text, font, width, height);
    } else if ([view isKindOfClass:[UITextView class]]) {
        text = ((UITextView *)view).text;
        font = ((UITextView *)view).font;
//        DDLogInfo(@"TextView: %@ %@ %f %f", text, font, width, height);
    } else {
        return;
    }
    
    CGSize newSize = [Util textSize:text font:font width:width height:height];
    CGRect newFrame = CGRectMake(view.frame.origin.x,
                                 view.frame.origin.y,
                                 newSize.width,
                                 newSize.height);
    view.frame = newFrame;
}

+ (void)adjustTextView:(UITextView *)textView {
    // remove padding
    textView.textContainer.lineFragmentPadding = 0;
    textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - iOS 7 adjustments

+ (void)adjustForIOS7:(UIViewController *)vc {
    vc.edgesForExtendedLayout = UIRectEdgeNone;
    vc.extendedLayoutIncludesOpaqueBars = NO;
    vc.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark - iOS 6 adjustments

+ (void)adjustForIOS6:(UIViewController *)vc {
    float yAdjustmentAmount = 0;
    
    // status bar
    if (![UIApplication sharedApplication].statusBarHidden) {
        yAdjustmentAmount += 20;
    }
    
    // navigation bar
    if (vc.navigationController) {
        yAdjustmentAmount += vc.navigationController.navigationBar.frame.size.height;
    }
    
    for (UIView *subview in vc.view.subviews) {
        //        if (![subview isKindOfClass:[UIScrollView class]]) {
        CGRect frame = subview.frame;
        frame.origin.y -= yAdjustmentAmount;
        subview.frame = frame;
        //        }
    }
}

+ (void)debugView:(UIView *)view {
    for (UIView *subview in view.subviews) {
        [CustomStyler setBorder:subview];
    }
}

@end
