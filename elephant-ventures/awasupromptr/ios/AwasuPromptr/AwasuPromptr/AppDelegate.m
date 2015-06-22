//
//  AppDelegate.m
//  AwasuPromptr
//
//  Created by Joe Gallo on 7/1/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "User.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // logging
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    self.fileLogger = [[DDFileLogger alloc] init];
    self.fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    self.fileLogger.logFileManager.maximumNumberOfLogFiles = 3;
    [DDLog addLogger:self.fileLogger];
    
    #warning TODO: remove
//    [self resetUserDefaults];
    
    // cached data object
    self.cachedData = [[CachedData alloc] init];
    
    self.loggedInUser = (User *)[appDelegate loadCustomObject:@"loggedInUser"];
    if (!self.loggedInUser) {
        [self createUser];
    }
    
    // delay hiding of splash image
    sleep(1);
    
    // specify initial view controller
    UIViewController *conferenceListVC = [storyboard instantiateViewControllerWithIdentifier:@"ConferenceListNav"];
    UIViewController *promptListVC = [storyboard instantiateViewControllerWithIdentifier:@"PromptList"];
    
    // initialize and configure view deck
    self.viewDeckController =  [[IIViewDeckController alloc] initWithCenterViewController:conferenceListVC
                                                                      rightViewController:promptListVC];
    [self configureViewDeckController];
    
    self.window.rootViewController = self.viewDeckController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)createUser {
    #warning TODO: eventually setup push notification code to get device token, once client sets up apple dev account
    self.loggedInUser = [[User alloc] initWithId:@"1"];
    [appDelegate saveCustomObject:self.loggedInUser as:@"loggedInUser"];
}

- (void)configureViewDeckController {
    self.viewDeckController.panningMode = IIViewDeckNoPanning;
    self.viewDeckController.openSlideAnimationDuration = 0.15f;
    self.viewDeckController.closeSlideAnimationDuration = 0.15f;
}

- (void)saveCustomObject:(NSObject *)obj as:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:obj];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:encodedObject forKey:key];
    [userDefaults synchronize];
}

- (NSObject *)loadCustomObject:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [userDefaults objectForKey:key];
    NSObject *obj = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return obj;
}

- (void)resetUserDefaults {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // user hit home button to leave app
    if (application.applicationState == UIApplicationStateBackground) {
        NSString *splashImageName;
        if (IS_IPHONE_5) {
            splashImageName = @"Default-568h@2x.png";
        } else {
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
                && [[UIScreen mainScreen] scale] == 2.0) {
                splashImageName = @"Default@2x.png";
            } else {
                splashImageName = @"Default.png";
            }
        }
        
        UIImageView *splash = [[UIImageView alloc] initWithImage:[UIImage imageNamed:splashImageName]];
        splash.frame = self.window.frame;
        [self.window addSubview:splash];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([[self.window subviews] count] > 1) {
        sleep(1);
        [[[self.window subviews] lastObject] removeFromSuperview];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // save logged in user to persistent storage on device
    [appDelegate saveCustomObject:self.loggedInUser as:@"loggedInUser"];
}

@end
