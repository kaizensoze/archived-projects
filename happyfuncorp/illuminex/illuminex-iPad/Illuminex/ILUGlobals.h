//
//  ILUGlobals.h
//  Illuminex
//
//  Created by Joe Gallo on 9/23/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#ifndef Illuminex_ILUGlobals_h
#define Illuminex_ILUGlobals_h

#import <QuartzCore/QuartzCore.h>

// categories
#import "NSDictionary+Utility.h"
#import "NSMutableDictionary+Utility.h"
//#import "UIImage+Utility.h"

// cocoa lumberjack
#import <CocoaLumberjack/CocoaLumberjack.h>

// afnetworking
#import "AFHTTPRequestOperationManager.h"
#import "UIImageView+AFNetworking.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import "IIViewDeckController.h"
//#import <Crashlytics/Crashlytics.h>
//#import <SDWebImage/SDImageCache.h>
//#import "Flurry.h"

#import "ILUUtil.h"
#import "ILUCustomStyler.h"

#import "ILUAppDelegate.h"

#define IS_3_5_SCREEN ([[UIScreen mainScreen]bounds].size.height < 568)
#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#define appDelegate ((ILUAppDelegate *)[[UIApplication sharedApplication] delegate])
#define storyboard [UIStoryboard storyboardWithName:@"Illuminex" bundle: nil]
#define userDefaults [NSUserDefaults standardUserDefaults]

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

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
