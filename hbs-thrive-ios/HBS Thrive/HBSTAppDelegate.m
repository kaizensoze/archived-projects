//
//  HBSTAppDelegate.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/4/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTAppDelegate.h"
#import <Instabug/Instabug.h>

@implementation HBSTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // reset device if specified
#ifdef LOCAL_RESET_DEVICE
    [self resetUserDefaults];
#endif
    
    // clear image cache if specified
#ifdef CLEAR_IMAGE_CACHE
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDisk];
#endif
    
    // cocoa lumberjack logging
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    self.fileLogger = [[DDFileLogger alloc] init];
    self.fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    self.fileLogger.logFileManager.maximumNumberOfLogFiles = 3;
    [DDLog addLogger:self.fileLogger];
    
    // crashlytics
#ifndef DEBUG
    [Crashlytics startWithAPIKey:@"bfc716ad5f0e74d5faf7912e4f5da76a963ee7ca"];
#endif
    
    // instabug
#if defined(DEBUG) && !defined(SQUELCH_INSTABUG)
    [Instabug startWithToken:@"7b7ac5ba1d6f866ba77bf8a0a9a5f898"
               captureSource:IBGCaptureSourceUIKit invocationEvent:IBGInvocationEventShake];
#endif
    
    // flurry
    [Flurry setCrashReportingEnabled:NO];
#if defined(LOCAL) || defined(STAGING)
    [Flurry startSession:@"9XC5N2WX55C5FGDMHGFK"];
#else
    [Flurry startSession:@"KPWYYT8TNJSYX6T7753D"];
#endif
#ifdef DEBUG_FLURRY
    [Flurry setDebugLogEnabled:YES];
#endif
    
    // device id
#ifdef LOCAL_DEVICE_ID_OVERRIDE
    self.deviceId = LOCAL_DEVICE_ID_OVERRIDE;
#else
    NSUUID *identifierForVendor = [[UIDevice currentDevice] identifierForVendor];
    self.deviceId = [identifierForVendor UUIDString];
#endif
    DDLogInfo(@"device id: %@", self.deviceId);
    
    // auth token
#ifdef LOCAL_AUTH_TOKEN_OVERRIDE
    [userDefaults setObject:LOCAL_AUTH_TOKEN_OVERRIDE forKey:@"authToken"];
    [userDefaults synchronize];
#endif
    NSString *authToken = [userDefaults objectForKey:@"authToken"];
    DDLogInfo(@"auth token: %@", authToken);
    
    // nonstudent
#ifdef NONSTUDENT_OVERRIDE
    [userDefaults setBool:NONSTUDENT_OVERRIDE forKey:@"isNonstudent"];
    [userDefaults synchronize];
#endif
    BOOL isNonstudent = [userDefaults boolForKey:@"isNonstudent"];
    DDLogInfo(@"nonstudent: %d", isNonstudent);
    
    // request manager
    NSURL *baseURL = [NSURL URLWithString:SITE_DOMAIN];
    self.requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    self.requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [self.requestManager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"dev" password:@"devpass"];
    if (authToken) {
        NSString *authTokenHeaderVal = [NSString stringWithFormat:@"Token token=\"%@\"", authToken];
        [self.requestManager.requestSerializer setValue:authTokenHeaderVal forHTTPHeaderField:@"Authorization"];
    }
    NSOperationQueue *operationQueue = self.requestManager.operationQueue;
    [self.requestManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [operationQueue setSuspended:NO];
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                [operationQueue setSuspended:YES];
                break;
        }
    }];
    [self.requestManager.reachabilityManager startMonitoring];
    
    BOOL firstLaunch = authToken == nil;
    [Flurry logEvent:@"Open" withParameters:@{ @"firstLaunch": [NSNumber numberWithBool:firstLaunch] }];
    
    // customize appearance
    [self customizeAppearance];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    // if verified, go to home, otherwise show login
    if (authToken) {
        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
    } else {
        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginNav"];
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)resetUserDefaults {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [userDefaults removePersistentDomainForName:appDomain];
}

- (void)customizeAppearance {
//    UIImage *clearImage = [UIImage imageNamed:@"clear.png"];
//    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundImage:clearImage
//                                                                                    forState:UIControlStateNormal
//                                                                                  barMetrics:UIBarMetricsDefault];
//    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitle:@""];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    [self.mailVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [Flurry logEvent:@"Close"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [Flurry logEvent:@"Open" withParameters:@{ @"firstLaunch": @NO }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
