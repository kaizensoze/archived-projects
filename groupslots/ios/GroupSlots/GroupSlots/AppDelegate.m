//
//  AppDelegate.m
//  GroupSlots
//
//  Created by Joe Gallo on 4/5/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "AppDelegate.h"
#import "User.h"
#import "Reward.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // logging
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    self.fileLogger = [[DDFileLogger alloc] init];
    self.fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    self.fileLogger.logFileManager.maximumNumberOfLogFiles = 3;
    [DDLog addLogger:self.fileLogger];
    
//    [self resetUserDefaults];
    
    // keyboard frame
    self.keyboardFrame = CGRectNull;
    
    // web sockets
//    self.socketIO = [[SocketIO alloc] initWithDelegate:self];
//    [self.socketIO connectToHost:SITE_DOMAIN onPort:PORT];
    
    // cached data object
    self.cachedData = [[CachedData alloc] init];
    
    // store the custom title bar
    self.navbarTitleVC = [storyboard instantiateViewControllerWithIdentifier:@"Navbar"];
    
    // create test users
    [self createTestUsers];
    
    // create test rewards
    [self createTestRewards];
    
    // appearance
    [self customizeAppearance];
    
    // casino id
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *casinoId = infoDict[@"CasinoID"];
    self.casinoId = casinoId;
    
    // delay hiding of splash image
    sleep(1);
    
    UIViewController *initialVC;
    self.loggedInUser = (User *)[appDelegate loadCustomObject:@"loggedInUser"];
    if (!self.loggedInUser) {
        initialVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginNav"];
    } else {
        initialVC = [Util determineActiveOrInactiveGroupVC];
    }
    
    // initialize and configure view deck
    self.viewDeckController =  [[IIViewDeckController alloc] initWithCenterViewController:initialVC];
    self.viewDeckController.delegate = self;
    [self configureViewDeckController];
    
    self.window.rootViewController = self.viewDeckController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    #warning TODO: remove
    self.navbarTitleVC.inboxBadgeCount = 6;
    self.navbarTitleVC.chatBadgeCount = 5;
    self.navbarTitleVC.invitesBadgeCount = 2;
    
    return YES;
}

- (void)configureViewDeckController {
    self.viewDeckController.leftSize = 65;
    self.viewDeckController.rightSize = 68;
    
    self.viewDeckController.openSlideAnimationDuration = 0.15f;
    self.viewDeckController.closeSlideAnimationDuration = 0.15f;
}

#pragma mark - IIViewDeckControllerDelegate

- (void)viewDeckController:(IIViewDeckController *)viewDeckController
          didOpenViewSide:(IIViewDeckSide)viewDeckSide
                  animated:(BOOL)animated {
    
    // logic to handle incoming message on center view controller
    
    if (viewDeckSide == IIViewDeckBottomSide) {
        CGRect bottomViewFrame = appDelegate.viewDeckController.bottomController.view.frame;
        
        if (appDelegate.viewDeckController.bottomSize == 450) {
            appDelegate.viewDeckController.bottomSize = 44;
        } else if (appDelegate.viewDeckController.bottomSize == 44 && bottomViewFrame.origin.y  > 0) {
            appDelegate.viewDeckController.bottomController.view.frame = CGRectMake(0, 0,
                                                                                    bottomViewFrame.size.width,
                                                                                    bottomViewFrame.size.height);
        }
    }
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController
          didCloseViewSide:(IIViewDeckSide)viewDeckSide
                  animated:(BOOL)animated {
    
    // logic to handle incoming message on center view controller
    
    if (viewDeckSide == IIViewDeckBottomSide) {
        CGRect bottomViewFrame = appDelegate.viewDeckController.bottomController.view.frame;
        appDelegate.viewDeckController.bottomController.view.frame = CGRectMake(0, 0,
                                                                                bottomViewFrame.size.width,
                                                                                bottomViewFrame.size.height);
    }
}

#pragma mark - Logout

- (void)logout {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"loggedInUser"];
    [userDefaults synchronize];
    
    self.loggedInUser = nil;
    
    [self.viewDeckController closeLeftViewAnimated:NO];
    self.viewDeckController.centerController = [storyboard instantiateViewControllerWithIdentifier:@"LoginNav"];
    self.viewDeckController.leftController = nil;
    self.viewDeckController.rightController = nil;
    self.viewDeckController.bottomController = nil;
}

#pragma mark - Create test users

- (void)createTestUsers {
    User *jim = [[User alloc] initWithUsername:@"jim.stark" firstName:@"Jim" lastName:@"Stark"];
    User *sam = [[User alloc] initWithUsername:@"sam.white" firstName:@"Sam" lastName:@"White"];
    User *mike = [[User alloc] initWithUsername:@"mike.davis" firstName:@"Mike" lastName:@"Davis"];
    User *kate = [[User alloc] initWithUsername:@"kate.martin" firstName:@"Kate" lastName:@"Martin"];
    
    self.testUsers = @{@"jim" : jim,
                       @"sam" : sam,
                       @"mike" : mike,
                       @"kate" : kate};
}

#pragma mark - Create test rewards

- (void)createTestRewards {
    Reward *buffet = [[Reward alloc] initWithName:@"Seafood Buffet" category:@"Food" points:200];
    buffet.testImagePath = @"reward-buffet.png";
    
    Reward *cabaret = [[Reward alloc] initWithName:@"Cabaret VIP Tickets" category:@"Entertainment" points:900];
    cabaret.testImagePath = @"reward-cabaret.png";
    
    Reward *satchel = [[Reward alloc] initWithName:@"Coach Haley Satchel" category:@"Lifestyle" points:500];
    satchel.testImagePath = @"reward-coach.png";
    
    Reward *fiesta = [[Reward alloc] initWithName:@"Ford Fiesta" category:@"Lifestyle" points:12000];
    fiesta.testImagePath = @"reward-fiesta.png";
    
    Reward *cancun = [[Reward alloc] initWithName:@"Cancun Vacation" category:@"Travel" points:10000];
    cancun.testImagePath = @"reward-cancun.png";
    
    self.testRewards = @{@"buffet" : buffet,
                         @"cabaret" : cabaret,
                         @"satchel" : satchel,
                         @"fiesta" : fiesta,
                         @"cancun" : cancun};
}

#pragma mark - Main nav

- (void)useMainNav:(UIViewController *)vc {
    // background image
    UIImage *backgroundImage = [UIImage imageNamed:@"navbar-background.png"];
    [vc.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    // spacer for left/right buttons
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                            target:nil action:nil];
    spacer.width = 5;
    
    // left menu button
    UIImage *leftMenuButtonImage = [UIImage imageNamed:@"bar-button-left.png"];
    UIBarButtonItem *leftButtonItem = [UIBarButtonItem barItemWithImage:leftMenuButtonImage
                                                                 target:self action:@selector(toggleMenu:)];
    if (!vc.navigationItem.leftBarButtonItems) {
        vc.navigationItem.leftBarButtonItems = @[spacer, leftButtonItem];
    }
    
    // title view
    if (!vc.navigationItem.titleView) {
        vc.navigationItem.titleView = appDelegate.navbarTitleVC.view;
    }
    
    // right menu button
    UIImage *rightMenuButtonImage = [UIImage imageNamed:@"bar-button-right.png"];
    UIBarButtonItem *rightButtonItem = [UIBarButtonItem barItemWithImage:rightMenuButtonImage
                                                                 target:self action:@selector(toggleInvite:)];
    if (!vc.navigationItem.rightBarButtonItems) {
        vc.navigationItem.rightBarButtonItems = @[spacer, rightButtonItem];
    }
}

- (IBAction)toggleMenu:(id)sender {
    [appDelegate.viewDeckController toggleLeftViewAnimated:YES];
}

- (IBAction)toggleInvite:(id)sender {
    [appDelegate.viewDeckController toggleRightViewAnimated:YES];
}

#pragma mark - User defaults

- (void)saveCustomObject:(NSObject *)obj as:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:obj];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:encodedObject forKey:key];
    [userDefaults synchronize];
}

- (NSObject *)loadCustomObject:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [userDefaults objectForKey:key];
    NSObject *obj = nil;
    if (encodedObject) {
        obj = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    }
    return obj;
}

- (void)saveLoggedInUserToDevice {
    [appDelegate saveCustomObject:self.loggedInUser as:@"loggedInUser"];
}

- (void)resetUserDefaults {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

#pragma mark - Facebook

- (void)clearFacebookSession {
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBSession.activeSession handleOpenURL:url];
}

#pragma mark - Customize appearance

- (void)customizeAppearance {
    // navigation bar
    UIImage *navigationBarImage = [[UIImage imageNamed:@"navigationbar.png"]
                                   resizableImageWithCapInsets:UIEdgeInsetsMake(21, 131, 21, 131)];
    [[UINavigationBar appearance] setBackgroundImage:navigationBarImage
                                       forBarMetrics:UIBarMetricsDefault];
    
    // back button
    UIImage *backButtonImage = [[UIImage imageNamed:@"back-button.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(17, 15, 17, 7)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    
    // toolbar
    UIImage *toolbarImage = [[UIImage imageNamed:@"toolbar.png"]
                             resizableImageWithCapInsets:UIEdgeInsetsMake(22, 0, 22, 0)];
    [[UIToolbar appearance] setBackgroundImage:toolbarImage
                            forToolbarPosition:UIToolbarPositionAny
                                    barMetrics:UIBarMetricsDefault];
    
    // bar button
    UIImage *barButtonImage = [[UIImage imageNamed:@"bar-button.png"]
                               resizableImageWithCapInsets:UIEdgeInsetsMake(14, 6, 14, 6)];
    [[UIBarButtonItem appearance] setBackgroundImage:barButtonImage
                                            forState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // User hit home button to leave app.
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
    
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // save logged in user to persistent storage on device
    [appDelegate saveCustomObject:self.loggedInUser as:@"loggedInUser"];
    
    // close facebook session
    [self clearFacebookSession];
}

@end
