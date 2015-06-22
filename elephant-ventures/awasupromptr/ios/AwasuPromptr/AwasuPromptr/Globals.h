//
//  Globals.h
//  AwasuPromptr
//
//  Created by Joe Gallo on 7/1/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#ifndef AwasuPromptr_Globals_h
#define AwasuPromptr_Globals_h

#import "IIViewDeckController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"

#import "Util.h"
#import "CachedData.h"
#import "AppDelegate.h"

#define IS_IPHONE_5 ([[UIScreen mainScreen]bounds].size.height == 568)

#define appDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define storyboard [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil]

#ifdef DEBUG
    static const int ddLogLevel = LOG_LEVEL_INFO;
#else
    static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

typedef enum {
    SUBMISSION_DUE,
    PRICE_INCREASE,
    HOUSING_AVAILABILITY
} PromptType;

FOUNDATION_EXPORT NSString * const SITE_DOMAIN;

#endif