//
//  BFKGlobals.h
//  Keeper
//
//  Created by Joe Gallo on 10/23/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#ifndef Keeper_BFKGlobals_h
#define Keeper_BFKGlobals_h

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelInfo;
#else
static const DDLogLevel ddLogLevel = DDLogLevelOff;
#endif

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

#endif
