//
//  Util.m
//  GroupSlots
//
//  Created by Joe Gallo on 4/9/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "Util.h"
#import "User.h"
#import "Challenge.h"
#import "ChatMessage.h"
#import "ChatViewController.h"

@implementation Util

+ (NSString *)shortName:(NSString *)firstName lastName:(NSString *)lastName {
    NSString *lastNameAbbrev;
    if (lastName.length > 0) {
        lastNameAbbrev = [lastName substringToIndex:1];
    } else {
        lastNameAbbrev = lastName;
    }
    return [NSString stringWithFormat:@"%@ %@.", firstName, lastNameAbbrev];
}

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

+ (UIColor *)colorFromHex:(NSString *)hexCode {  // Ex: "FFFFFF"
    NSScanner *scanner = [NSScanner scannerWithString:[hexCode substringFromIndex:0]];
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
                                 NSForegroundColorAttributeName : [Util colorFromHex:@"003366"],
                                 NSBackgroundColorAttributeName : [UIColor clearColor],
                                 NSUnderlineStyleAttributeName : @1
                                 };
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:label.text attributes:attributes];
    label.attributedText = attributedString;
}

#pragma mark - Time/date functions

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

+ (NSString *)secondsToTimeString:(int)timeInSeconds {
    int minutes = (int)ceil( (float)timeInSeconds / 60 ) % 60;
    int hours = timeInSeconds / (60*60);
    
    return [NSString stringWithFormat:@"%02d:%02d", hours, minutes];
}

+ (NSDate *)timeMinusMinutes:(NSDate *)date minutes:(int)minutes {
    return [date dateByAddingTimeInterval:-60 * minutes];
}

+ (void)disableButton:(UIButton *)button {
    button.enabled = NO;
    button.alpha = 0.5;
}

+ (void)enableButton:(UIButton *)button {
    button.enabled = YES;
    button.alpha = 1;
}

+ (void)toggleSelected:(UIButton *)button {
    button.selected = !button.selected;
}

+ (NSString *)enumToString:(int)enumVariable {
    NSString *result;
    
    switch (enumVariable) {
        case INVITE_PENDING:
            result = @"INVITE_PENDING";
            break;
        case INVITE_ACCEPTED:
            result = @"INVITE_ACCEPTED";
            break;
        case INVITE_IGNORED:
            result = @"INVITE_IGNORED";
            break;
        default:
            result = @"";
            break;
    }
    
    return result;
}

+ (void)checkForBackButton:(UIViewController *)vc {
    if (vc.navigationController) {
        if (vc.navigationController.viewControllers.count > 1) {
            UIImage *backgroundImage = [UIImage imageNamed:@"navigationbar.png"];
            [vc.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
        }
    }
}

+ (UIViewController *)determineActiveOrInactiveGroupVC {
    if (appDelegate.loggedInUser.challenge) {
        return [storyboard instantiateViewControllerWithIdentifier:@"GroupPageActiveNav"];
    } else {
        return [storyboard instantiateViewControllerWithIdentifier:@"GroupPageInactiveNav"];
    }
}

+ (void)loadMainViewControllers {
    UIViewController *menuVC = [storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    if (!appDelegate.viewDeckController.leftController) {
        appDelegate.viewDeckController.leftController = menuVC;
    }
    
    UIViewController *inviteVC = [storyboard instantiateViewControllerWithIdentifier:@"GroupMembersNav"];
    if (!appDelegate.viewDeckController.rightController) {
        appDelegate.viewDeckController.rightController = inviteVC;
    }
    
    UIViewController *chatVC = [storyboard instantiateViewControllerWithIdentifier:@"Chat"];
    if (!appDelegate.viewDeckController.bottomController) {
        appDelegate.viewDeckController.bottomController = chatVC;
    }
}

+ (void)addChatTab:(UIViewController *)vc {
    UIImage *image = [UIImage imageNamed:@"chat-tab.png"];
    
    CGFloat navHeight = vc.navigationController.navigationBarHidden ?
        0 : vc.navigationController.navigationBar.frame.size.height;
    
    float xPos = (vc.view.frame.size.width / 2) - (image.size.width / 2);
    float yPos = vc.view.frame.size.height - navHeight - image.size.height;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xPos, yPos, image.size.width, image.size.height)];
    imageView.image = image;
    [vc.view addSubview:imageView];
    [vc.view bringSubviewToFront:imageView];
}

+ (void)disableChat {
    appDelegate.viewDeckController.bottomController = nil;
}

#pragma mark - Style buttons

+ (void)styleButton:(UIButton *)button {
    // background image
    UIImage *backgroundImage = [[UIImage imageNamed:@"button.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(18, 4, 18, 4)];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    // font
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    
    // font color
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

+ (void)styleButton2:(UIButton *)button {
    // background image
    UIImage *backgroundImage = [[UIImage imageNamed:@"button.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(18, 4, 18, 4)];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    // font
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    
    // font color
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

+ (void)styleDisclosureButton:(UIButton *)button {
    // background image
    UIImage *backgroundImage = [[UIImage imageNamed:@"disclosure-button.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(19, 132, 19, 132)];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    // font
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    
    // font color
    [button setTitleColor:[Util colorFromHex:@"6f7278"] forState:UIControlStateNormal];
    
    // text alignment
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    // insets
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0);
}

#pragma mark - Style text fields

+ (void)styleTextField:(UITextField *)textField {
    // change height
    CGRect frameRect = textField.frame;
    frameRect.size.height = 48;
    textField.frame = frameRect;
    
    // background image
    UIImage *backgroundImage = [[UIImage imageNamed:@"textfield.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(24, 8, 24, 8)];
    textField.background = backgroundImage;
    
    // font
    textField.font = [UIFont fontWithName:@"Helvetica" size:16];
    
    // text color
    textField.textColor = [Util colorFromHex:@"6f7278"];
}

+ (void)styleDisclosureTextField:(UITextField *)textField {
    // change height
    CGRect frameRect = textField.frame;
    frameRect.size.height = 40;
    textField.frame = frameRect;
    
    // background image
    UIImage *backgroundImage = [[UIImage imageNamed:@"disclosure-button.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(19, 132, 19, 132)];
    textField.background = backgroundImage;
    
    // font
    textField.font = [UIFont fontWithName:@"Helvetica" size:16];
    
    // text color
    textField.textColor = [Util colorFromHex:@"6f7278"];
}

+ (void)styleFormTextField:(UITextField *)textField {
    // remove background
    textField.borderStyle = UITextBorderStyleNone;
    
    // font
    textField.font = [UIFont fontWithName:@"Helvetica" size:13];
    
    // placeholder color
    [textField setValue:[Util colorFromHex:@"6f7278"] forKeyPath:@"_placeholderLabel.textColor"];
}

+ (void)setFormTableCellBackground:(UITableViewCell *)cell row:(int)row numRows:(int)numRows {
    UIImage *backgroundImage;
    if (row == 0) {
        backgroundImage = [[UIImage imageNamed:@"form-cell-top.png"]
                           resizableImageWithCapInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    } else if (row == numRows - 1) {
        backgroundImage = [[UIImage imageNamed:@"form-cell-bottom.png"]
                           resizableImageWithCapInsets:UIEdgeInsetsMake(22, 2, 22, 2)];
    } else {
        backgroundImage = [[UIImage imageNamed:@"form-cell-middle.png"]
                           resizableImageWithCapInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    }
    cell.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
}

#pragma mark - Set border

+ (void)setBorder:(UIView *)view width:(float)width color:(UIColor *)color {
    view.layer.borderWidth = width;
    view.layer.borderColor = color.CGColor;
}

#pragma mark - Round corners

+ (void)roundCorners:(UIView *)imageView radius:(float)radius {
    imageView.layer.cornerRadius = radius;
    imageView.layer.masksToBounds = YES;
}

#pragma mark - UITableViewCell separator

+ (void)addSeparator:(UITableViewCell *)cell {
    UIImage *image = [[UIImage imageNamed:@"table-separator"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImageView *separatorView = [[UIImageView alloc] initWithImage:image];
    
    float imageHeight = image.size.height;
    float cellWidth = cell.contentView.frame.size.width;
    float cellHeight = cell.contentView.frame.size.height;
    separatorView.frame = CGRectMake(0, cellHeight - imageHeight, cellWidth, imageHeight);
    [cell.contentView addSubview:separatorView];
}

+ (void)addTopSeparator:(UITableViewCell *)cell {
    UIImage *image = [[UIImage imageNamed:@"table-separator"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImageView *separatorView = [[UIImageView alloc] initWithImage:image];
    
    float imageHeight = image.size.height;
    float cellWidth = cell.contentView.frame.size.width;
    separatorView.frame = CGRectMake(0, 0, cellWidth, imageHeight);
    [cell.contentView addSubview:separatorView];
}

#pragma mark - Set center view controller

+ (void)setCenterViewController:(UIViewController *)vc {
    appDelegate.viewDeckController.centerController = vc;
}

#pragma mark - Adjust text

+ (void)adjustText:(UILabel *)label width:(float)width height:(float)height {
    CGSize newSize = [label.text sizeWithFont:label.font
                            constrainedToSize:CGSizeMake(width, height)
                                lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect newFrame = CGRectMake(label.frame.origin.x,
                                 label.frame.origin.y,
                                 newSize.width,
                                 newSize.height);
    label.frame = newFrame;
}

+ (void)triggerIncomingMessage {
    ChatMessage *testMessage = [[ChatMessage alloc] initWithUser:appDelegate.testUsers[@"jim"]
                                                         message:@"Alright, found some more people. Let's go!"];
    
    ChatViewController *chatVC = (ChatViewController *)appDelegate.viewDeckController.bottomController;
    if (![chatVC.chatMessages containsObject:testMessage]) {
        [chatVC.chatMessages addObject:testMessage];
        [chatVC updateMessagesTable];
    }
    
    CGRect chatViewFrame = appDelegate.viewDeckController.bottomController.view.frame;
    appDelegate.viewDeckController.bottomController.view.frame = CGRectMake(0, 44,
                                                                            chatViewFrame.size.width,
                                                                            chatViewFrame.size.height);
    
    // adjust size before opening
    appDelegate.viewDeckController.bottomSize = 450;
    [appDelegate.viewDeckController openBottomView];
}

@end
