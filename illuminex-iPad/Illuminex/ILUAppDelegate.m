//
//  AppDelegate.m
//  Illuminex
//
//  Created by Joe Gallo on 9/23/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "ILUAppDelegate.h"

@implementation ILUAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // reset device if specified
#ifdef LOCAL_RESET_DEVICE
    [self resetUserDefaults];
#endif
    
    // cocoa lumberjack logging
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    self.fileLogger = [[DDFileLogger alloc] init];
    self.fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    self.fileLogger.logFileManager.maximumNumberOfLogFiles = 3;
    [DDLog addLogger:self.fileLogger];
    
    // setup request manager
    [self setupRequestManager];
    
    // auto-sign-in
    [self autoSignIn];
    
    // customize appearance
    [self customizeAppearance];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    // viewdeck controller
    UIViewController *flyoutMenuVC = [storyboard instantiateViewControllerWithIdentifier:@"FlyoutMenu"];
    UIViewController *landingPageVC = [storyboard instantiateViewControllerWithIdentifier:@"LandingPage"];
    
    self.viewDeckController =  [[IIViewDeckController alloc] initWithCenterViewController:landingPageVC
                                                                       leftViewController:flyoutMenuVC];
    self.viewDeckController.delegate = self;
    float windowWidth = MAX(self.window.frame.size.width, self.window.frame.size.height);
    self.viewDeckController.leftSize = windowWidth - 262;
//    self.viewDeckController.openSlideAnimationDuration = 0.15f;
//    self.viewDeckController.closeSlideAnimationDuration = 0.15f;
    self.viewDeckController.elastic = NO;
    
    self.window.rootViewController = self.viewDeckController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - Setup request manager

- (void)setupRequestManager {
    NSURL *baseURL = [NSURL URLWithString:SITE_DOMAIN];
    self.requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    self.requestManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestManager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    [self.requestManager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"dev" password:@"devpass"];
    
    NSString *authToken = [userDefaults objectForKey:@"authToken"];
    NSString *installationIdentifier = @"x";
    
    DDLogInfo(@"Token token=\"%@\", installation_identifier=\"%@\"", authToken, installationIdentifier);
    
    if (authToken) {
        NSString *authTokenHeaderVal = [NSString stringWithFormat:@"Token token=\"%@\", installation_identifier=\"%@\"",
                                        authToken, installationIdentifier];
        [self.requestManager.requestSerializer setValue:authTokenHeaderVal forHTTPHeaderField:@"Authorization"];
    }
}

#pragma mark - Auto sign in

- (void)autoSignIn {
    NSString *url = [NSString stringWithFormat:@"%@/%@/users/sign_in", SITE_DOMAIN, API_PATH];
    NSDictionary *parameters = @{
                                 @"session[email]": @"jgallo@happyfuncorp.com", // pavan@happyfuncorp.com
                                 @"session[password]": @"12345678",
                                 @"session[installation_identifier]": @"x"
                                 };
    [appDelegate.requestManager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSString *authToken = JSON[@"user"][@"token"];
        [userDefaults setObject:authToken forKey:@"authToken"];
        [userDefaults synchronize];
        
        [self setupRequestManager];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"%@", error);
    }];
}

#pragma mark - Sign out

- (void)signOut {
    [userDefaults removeObjectForKey:@"authToken"];
    [userDefaults synchronize];
    
    [self.requestManager.requestSerializer setValue:nil forHTTPHeaderField:@"Authorization"];
}

#pragma mark - IIViewDeckControllerDelegate

- (void)viewDeckController:(IIViewDeckController *)viewDeckController applyShadow:(CALayer *)shadowLayer withBounds:(CGRect)rect {
}

#pragma mark - Customize appearance

- (void)customizeAppearance {
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

#pragma mark - User defaults stuff

- (void)saveObject:(NSObject *)obj forKey:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:obj];
    [userDefaults setObject:encodedObject forKey:key];
    [userDefaults synchronize];
}

- (NSObject *)objectForKey:(NSString *)key {
    NSData *encodedObject = [userDefaults objectForKey:key];
    NSObject *obj = nil;
    if (encodedObject) {
        obj = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    }
    return obj;
}

- (void)resetUserDefaults {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

@end
