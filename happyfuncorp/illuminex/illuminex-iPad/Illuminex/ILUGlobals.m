//
//  ILUGlobals.m
//  Illuminex
//
//  Created by Joe Gallo on 9/23/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#ifndef Illuminex_ILUGlobals_m
#define Illuminex_ILUGlobals_m

#import "ILUGlobals.h"

#ifdef LOCAL
    NSString * const SITE_DOMAIN = @"http://localhost";
#elif defined STAGING
    NSString * const SITE_DOMAIN = @"http://illuminex.herokuapp.com";
#else
    NSString * const SITE_DOMAIN = @"http://illuminex.herokuapp.com";
#endif

NSString * const API_PATH = @"v1";

#endif
