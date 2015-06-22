//
//  Globals.h
//  GroupSlots
//
//  Created by Joe Gallo on 4/9/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#ifndef GroupSlots_Globals_h
#define GroupSlots_Globals_h

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "SocketIO.h"
#import "SocketIOPacket.h"
#import "IIViewDeckController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"

#import "Util.h"
#import "CachedData.h"
#import "NavigationBarTitleViewController.h"
#import "UIBarButtonItem+Utility.h"
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
    INVITE_PENDING,
    INVITE_IGNORED,
    INVITE_ACCEPTED
} GroupInviteStatus;

FOUNDATION_EXPORT NSString * const SITE_DOMAIN;
FOUNDATION_EXPORT NSInteger const PORT;

#endif
