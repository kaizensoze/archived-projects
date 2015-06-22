//
//  Globals.h
//  Taste Savant
//
//  Created by Joe Gallo on 10/26/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "Globals.h"

#ifdef LOCAL
NSString * const SITE_DOMAIN = @"http://localhost:8000";
NSString * const API_URL_PREFIX = @"http://localhost:8000/api/1";
#elif defined PLAYGROUND
NSString * const SITE_DOMAIN = @"http://playground.tastesavant.com";
NSString * const API_URL_PREFIX = @"http://playground.tastesavant.com/api/1";
#else
NSString * const SITE_DOMAIN = @"https://tastesavant.com";
NSString * const API_URL_PREFIX = @"https://tastesavant.com/api/1";
#endif

NSString * const API_URL_PREFIX_PARTIAL = @"api/1";

NSString * const TWITTER_CONSUMER_KEY = @"RzpkzuP35fRmfNzhgsUbwQ";
NSString * const TWITTER_CONSUMER_SECRET = @"UKsGw8dFKPiNwXPWsiTao3ynhCfSBe0D8E7muXedac";

NSString * const GOOGLE_ANALYTICS_ID = @"UA-21189669-5";

NSString * const TESTFLIGHT_KEY = @"9e8a09d1-ef37-4677-81ba-18d07bb8267a";
NSString * const CRASHLYTICS_KEY = @"0b6b9b13e4e6a5c3a31dc9eda3a5ab92ba21d29b";

NSString * const MAILCHIMP_KEY = @"dce8c76ef081c99157b4b9f1cff4bc69-us2";

const float METERS_PER_MILE = 1609.344;
const float LOAD_MORE_CELL_HEIGHT = 69;
const float TABLE_HEADER_HEIGHT = 30;