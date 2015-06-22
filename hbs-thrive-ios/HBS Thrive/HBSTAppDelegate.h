//
//  HBSTAppDelegate.h
//  HBS Thrive
//
//  Created by Joe Gallo on 8/4/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageUI/MessageUI.h"

@interface HBSTAppDelegate : UIResponder <UIApplicationDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DDFileLogger *fileLogger;
@property (strong, nonatomic) AFHTTPRequestOperationManager *requestManager;
@property (strong, nonatomic) NSString *deviceId;
@property (strong, nonatomic) MFMailComposeViewController *mailVC;

@end
