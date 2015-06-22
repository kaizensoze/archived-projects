//
//  HBSTEnvironment.h
//  HBS Thrive
//
//  Created by Joe Gallo on 8/4/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#ifndef HBS_Thrive_HBSTGlobals_h
#define HBS_Thrive_HBSTGlobals_h

#import <QuartzCore/QuartzCore.h>

// categories
#import "NSDictionary+Utility.h"
#import "NSMutableDictionary+Utility.h"
#import "UIImage+Utility.h"

#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"

// afnetworking
#import "AFHTTPRequestOperationManager.h"
#import "UIImageView+AFNetworking.h"

#import <Crashlytics/Crashlytics.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <SDWebImage/SDImageCache.h>
#import "Flurry.h"

#import "HBSTUtil.h"
#import "HBSTCustomStyler.h"

#import "HBSTAppDelegate.h"

#define IS_3_5_SCREEN ([[UIScreen mainScreen]bounds].size.height < 568)
#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))

#define appDelegate ((HBSTAppDelegate *)[[UIApplication sharedApplication] delegate])
#define storyboard [UIStoryboard storyboardWithName:@"HBS Thrive" bundle: nil]
#define userDefaults [NSUserDefaults standardUserDefaults]

#ifdef DEBUG
    static const int ddLogLevel = LOG_LEVEL_INFO;
#else
    static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

FOUNDATION_EXPORT NSString * const SITE_DOMAIN;

FOUNDATION_EXPORT NSString * const API_PATH;

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#endif