//
//  Globals.h
//  Taste Savant
//
//  Created by Joe Gallo on 10/26/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#ifndef Taste_Savant_Globals_h
#define Taste_Savant_Globals_h

#import <QuartzCore/QuartzCore.h>
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "UIImageView+AFNetworking.h"
#import "UIButton+AFNetworking.h"
#import "MBProgressHUD.h"
#import "EGORefreshTableHeaderView.h"
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import <Crashlytics/Crashlytics.h>

#import "NSDictionary+Utility.h"
#import "NSMutableDictionary+Utility.h"
#import "Util.h"
#import "CustomStyler.h"
#import "CachedData.h"
#import "AppDelegate.h"


#define IS_IPHONE_5 ([[UIScreen mainScreen]bounds].size.height == 568)
#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))

#define appDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define storyboard [UIStoryboard storyboardWithName:@"TasteSavant" bundle: nil]

#ifdef DEBUG
    static const int ddLogLevel = LOG_LEVEL_INFO;
#else
    static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

FOUNDATION_EXPORT NSString * const SITE_DOMAIN;

FOUNDATION_EXPORT NSString * const API_URL_PREFIX;
FOUNDATION_EXPORT NSString * const API_URL_PREFIX_PARTIAL;

FOUNDATION_EXPORT NSString * const TWITTER_CONSUMER_KEY;
FOUNDATION_EXPORT NSString * const TWITTER_CONSUMER_SECRET;

FOUNDATION_EXPORT NSString * const GOOGLE_ANALYTICS_ID;

FOUNDATION_EXPORT NSString * const TESTFLIGHT_KEY;
FOUNDATION_EXPORT NSString * const CRASHLYTICS_KEY;

FOUNDATION_EXPORT NSString * const MAILCHIMP_KEY;

FOUNDATION_EXPORT const float METERS_PER_MILE;
FOUNDATION_EXPORT const float LOAD_MORE_CELL_HEIGHT;
FOUNDATION_EXPORT const float TABLE_HEADER_HEIGHT;

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
    Stuff; \
    _Pragma("clang diagnostic pop") \
} while (0)

#endif
