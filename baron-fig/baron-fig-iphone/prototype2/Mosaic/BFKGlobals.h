//
//  BFKGlobals.h
//  Mosaic
//
//  Created by Joe Gallo on 10/23/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#ifndef Mosaic_BFKGlobals_h
#define Mosaic_BFKGlobals_h

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelInfo;
#else
static const DDLogLevel ddLogLevel = DDLogLevelOff;
#endif

#endif
