//
//  HBSTEnvironment.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/4/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#ifndef HBS_Thrive_HBSTGlobals_m
#define HBS_Thrive_HBSTGlobals_m

#import "HBSTGlobals.h"

#ifdef LOCAL
    #ifdef USING_MOBILE_HOTSPOT
        NSString * const SITE_DOMAIN = @"http://172.20.10.3:3000";
    #else
        NSString * const SITE_DOMAIN = @"http://192.168.0.101:3000";
    #endif
    NSString * const API_PATH = @"api/v1";
#elif defined STAGING
    NSString * const SITE_DOMAIN = @"https://hbs-stage.herokuapp.com";
    NSString * const API_PATH = @"api/v1";
#else
    NSString * const SITE_DOMAIN = @"https://hbs-prod.herokuapp.com";
    NSString * const API_PATH = @"api/v1";
#endif

#endif