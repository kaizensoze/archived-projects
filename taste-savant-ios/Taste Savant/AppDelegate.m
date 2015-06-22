//
//  AppDelegate.m
//  Taste Savant
//
//  Created by Joe Gallo on 10/24/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "LoginViewController.h"
#import "NotLoggedInViewController.h"
#import "LoadingViewController.h"
#import "User.h"
#import "CachedData.h"

@interface AppDelegate ()
    @property (strong, nonatomic) NotLoggedInViewController *notLoggedInVC;
    @property (strong, nonatomic) LoadingViewController *loadingVC;

    @property (strong, nonatomic) UIImageView *splashImageView;
//    @property (nonatomic) BOOL doNotShowResumeSplash;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifdef RESET_DEVICE
    [self resetUserDefaults];
#endif
    
    // logging
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    self.fileLogger = [[DDFileLogger alloc] init];
    self.fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    self.fileLogger.logFileManager.maximumNumberOfLogFiles = 3;
    [DDLog addLogger:self.fileLogger];
    
    // make note of environment
#ifdef LOCAL
    DDLogInfo(@"LOCALHOST");
#elif defined PLAYGROUND
    DDLogInfo(@"PLAYGROUND");
#else
    DDLogInfo(@"PRODUCTION");
#endif
    
    // location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.distanceFilter = 20; // In meters.
    
    self.lastLocation = nil;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    // http client
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", SITE_DOMAIN]];
    self.httpClient = [AFHTTPClient clientWithBaseURL:baseURL];
    
    // have AFNetworking take care of the network activity indicator
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    // initialize cached data object
    self.cachedData = [[CachedData alloc] init];
    [self.cachedData loadSupportedCities];
    [self.cachedData setNearestCity:@"New York"];
    
    // show status bar if not already shown
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    // google analytics
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:GOOGLE_ANALYTICS_ID];
    
    // crashlytics
#ifndef DEBUG
    [Crashlytics startWithAPIKey:CRASHLYTICS_KEY];
#endif
    
    // social
    self.accountStore = [[ACAccountStore alloc] init];
    self.facebookLoginManager = [[FBSDKLoginManager alloc] init];
    self.twitterManager = [[TWAPIManager alloc] init];
    
    // appearance
    [self customizeAppearance];
    
    // get logged in user from device
    self.loggedInUser = (User *)[appDelegate loadCustomObject:@"loggedInUser"];
    
    self.loginSignupAsModal = NO;
    
    // determine which inital vc to load (landing page if first time)
    NSString *initialVCLabel;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:@"doNotShowFirstTimeUsersPage"] == YES) {
        initialVCLabel = @"Main";
    } else {
        [userDefaults setBool:YES forKey:@"doNotShowFirstTimeUsersPage"];
        [userDefaults synchronize];
        
        initialVCLabel = @"FirstTimeUsers";
    }
    
    // delay hiding of splash image
    sleep(1);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // load initial vc
    UIViewController *initialVC = [storyboard instantiateViewControllerWithIdentifier:initialVCLabel];
    self.window.rootViewController = initialVC;
    
    self.notLoggedInVC = (NotLoggedInViewController *)[storyboard instantiateViewControllerWithIdentifier:@"NotLoggedIn"];
    self.loadingVC = (LoadingViewController *)[storyboard instantiateViewControllerWithIdentifier:@"Loading"];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)setRootViewController:(UIViewController *)vc {
    self.window.rootViewController = vc;
}

#pragma mark - Http client

- (AFHTTPClient *)httpClient {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *authToken = [userDefaults objectForKey:@"authToken"];
    NSString *authTokenString = [NSString stringWithFormat:@"Token %@", authToken];
    
    // NOTE: comment this out when testing as a given user
    if (authToken != nil) {
        [_httpClient setDefaultHeader:@"Authorization" value:authTokenString];
    } else {
        [_httpClient setDefaultHeader:@"Authorization" value:nil];
    }
    
    return _httpClient;
}

#pragma mark - User defaults stuff

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

- (void)resetUserDefaults {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

- (void)saveLoggedInUserToDevice {
    [appDelegate saveCustomObject:self.loggedInUser as:@"loggedInUser"];
}

#pragma mark - Location services

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to get location"
                                                    message:@"\nCheck Settings -> Privacy -> Location Services -> TasteSavant to make sure the app is allowed access."
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    DDLogInfo(@"locationManagerDidPauseLocationUpdates");
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    DDLogInfo(@"locationManagerDidResumeLocationUpdates");
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    if (self.cityOverride) {
        return;
    }
    
    // if custom location specified, use that
    if (self.customLocation) {
        self.lastLocation = self.customLocation;
    } else {
        self.lastLocation = newLocation;
    }
    
    // if the list of supported cities hasn't been loaded yet, load them (which will then call findNearestCity on completion)
    if (!self.cachedData.supportedCities) {
        [self.cachedData loadSupportedCities];
    } else {
        [self findNearestCity:self.lastLocation];
    }
    
//    DDLogInfo(@"%@", self.lastLocation);
}

- (void)findNearestCity:(CLLocation *)currentLocation {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSString *nearestCity;
        
        CLPlacemark *place = [placemarks objectAtIndex:0];
        NSString *zipcode = place.addressDictionary[@"ZIP"];
        
        if ([self.cachedData.brooklynNeighborhoods containsObject:zipcode]
            && [self.cachedData.supportedCities objectForKey:@"Brooklyn"]) {
            nearestCity = @"Brooklyn";
        } else {
            CLLocation *cityLocation;
            CLLocationDistance distance;
            CLLocationDistance minDistance = (CLLocationDistance)DBL_MAX;
            
            for (NSString *cityName in self.cachedData.supportedCities) {
                if ([cityName isEqualToString:@"Brooklyn"]) {
                    continue;
                }
                
                cityLocation = self.cachedData.supportedCities[cityName][@"location"];
                distance = [cityLocation distanceFromLocation:self.lastLocation];
                if (distance < minDistance) {
                    minDistance = distance;
                    nearestCity = cityName;
                }
            }
        }
        
        [self.cachedData setNearestCity:nearestCity];
        self.lastCurrentLocationCity = nearestCity;
    }];
}

- (void)overrideCity:(NSString *)cityName {
    if (!cityName || [cityName isEqualToString:self.lastCurrentLocationCity]) {
        self.cityOverride = nil;
        [self.cachedData setNearestCity:self.lastCurrentLocationCity];
        return;
    }
    
    // set city override variable
    self.cityOverride = cityName;
    
    [self.cachedData setNearestCity:cityName];
}

#pragma mark - Login

- (void)showLogin:(UIViewController *)vc {
    UIViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginNav"];
    [vc presentViewController:loginVC animated:YES completion:nil];
    self.loginSignupAsModal = YES;
}

- (void)login:(NSDictionary *)params {
    NSMutableDictionary *alteredParams = [[params copy] mutableCopy];
    // add city field to params if not already there
    if (!params[@"city"]) {
        [alteredParams setValue:appDelegate.cachedData.nearestCity forKey:@"city"];
    }
    
    // hide keyboard
    [((UIViewController *)self.loginDelegate).view endEditing:YES];
    
    NSString *url = [NSString stringWithFormat: @"%@/login/", API_URL_PREFIX];
    
    DDLogInfo(@"%@ %@", url, alteredParams);
    
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"POST" path:url parameters:alteredParams];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [Util showHUDWithTitle:nil];
        
        DDLogInfo(@"%@", JSON);
        
        // Get auth token.
        NSString *authToken = [JSON objectForKeyNotNull:@"token"];
        if (authToken == nil) {
            [self logoutFacebook];
            [self.loginDelegate loginFailed];
            return;
        }
        
        // Store auth token.
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:authToken forKey:@"authToken"];
        [userDefaults synchronize];
        
        // check to see if new user was created since login is doubly used as register for social auth
        self.newUserCreatedViaSocialAuth = [[JSON objectForKeyNotNull:@"new"] intValue];
        
        NSString *username = [JSON objectForKeyNotNull:@"username"];
        
        DDLogInfo(@"username: %@, auth_token: %@", username, authToken);
        
        // Get profile info.
        User *profile = [[User alloc] init];
        profile.delegate = self;
        profile.includeReviews = NO;
        if ([params objectForKey:@"access_token"]) {
            profile.viaSocialAuth = YES;
        }
        [profile loadFromUsername:username];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

- (void)profileDoneLoading:(User *)profile {
    [Util hideHUD];
    
    self.loggedInUser = profile;
    [appDelegate saveLoggedInUserToDevice];
    
    [self.loginDelegate loginSucceeded];
}

#pragma mark - Logout

- (void)logout {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"loggedInUser"];
    [userDefaults removeObjectForKey:@"authToken"];
    [userDefaults synchronize];
    
    self.loggedInUser = nil;
    
    [self logoutFacebook];
}

- (void)logoutFacebook {
    [self.facebookLoginManager logOut];
    self.facebookData = nil;
}

#pragma mark - Logged in screen

- (void)showNotLoggedInScreen:(UIViewController *)vc loginButtonDetail:(NSString *)detail {
    self.notLoggedInVC.loginButtonDetail = detail;
    [vc addChildViewController:self.notLoggedInVC];
    [vc.view addSubview:self.notLoggedInVC.view];
    [self.notLoggedInVC.view setFrame:CGRectMake(0, 0, vc.view.frame.size.width, 9999)];
}

- (void)removeNotLoggedInScreen {
    [self.notLoggedInVC removeFromParentViewController];
    [self.notLoggedInVC.view removeFromSuperview];
}

#pragma mark - Loading screen

- (void)showLoadingScreen:(UIView *)view {
    [view addSubview:self.loadingVC.view];
    [self.loadingVC.view setFrame:CGRectMake(0, 0, view.frame.size.width, 9999)];
}

- (void)removeLoadingScreen:(UIViewController *)vc {
    if (vc == nil || [self.loadingVC.view isDescendantOfView:vc.view]) {
        [self.loadingVC.view removeFromSuperview];
    }
}

#pragma mark - Facebook

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)openSession {
    [self.facebookLoginManager logInWithReadPermissions:@[@"email", @"user_friends"]
                                                handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            DDLogError(@"%@", error);
            
            NSString *message = @"Unable to login to Facebook.\n\nCheck in device settings that your Facebook info is correct and that the app has access to Facebook.";
            [Util showErrorAlert:message delegate:nil];
            
            // avoid getting stuck in error state
            [self logoutFacebook];
        } else if (result.isCancelled) {
            DDLogInfo(@"facebook login cancelled");
        } else {
            // check if any required permissions missing
            if (![result.grantedPermissions containsObject:@"email"]) {
                DDLogInfo(@"email permission required");
            }
            if (![result.grantedPermissions containsObject:@"user_friends"]) {
                DDLogInfo(@"user_friends permission required");
            }
            
            // Get user's facebook info.
            FBSDKAccessToken *currentAccessToken = [FBSDKAccessToken currentAccessToken];
            if (currentAccessToken) {
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
                 startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                     if (!error) {
                         [Util showHUDWithTitle:nil];
                         
                         self.facebookData = result;
                         
                         DDLogInfo(@"%@", self.facebookData);
                         
                         NSString *facebookId = self.facebookData[@"id"];
                         NSString *username = self.facebookData[@"username"];
                         NSString *firstName = self.facebookData[@"first_name"];
                         NSString *lastName = self.facebookData[@"last_name"];
                         NSString *email = self.facebookData[@"email"];

                         // if no username, set it to (first + '.' + last).lower()
                         if ([Util isEmpty:username]) {
                             username = [[NSString stringWithFormat:@"%@.%@", firstName, lastName] lowercaseString];
                         }

                         NSMutableDictionary *params = [NSMutableDictionary dictionary];
                         [params setValue:@"facebook" forKey:@"provider"];
                         [params setValue:currentAccessToken.tokenString forKey:@"access_token"];
                         [params setValue:facebookId forKey:@"id"];
                         [params setValue:username forKey:@"username"];
                         [params setValue:firstName forKey:@"first_name"];
                         [params setValue:lastName forKey:@"last_name"];
                         [params setValue:email forKey:@"email"];
                         
                         DDLogInfo(@"%@", params);
                         
                         [self login:params];
                     }
                 }];
            }
        }
    }];
}

#pragma mark - Twitter

- (void)refreshTwitterAccounts {
    //  Get access to the user's Twitter account(s)
    [self obtainAccessToAccountsWithBlock:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
            }
            else {
                DDLogError(@"You were not granted access to the Twitter accounts.");
            }
        });
    }];
}

- (void)obtainAccessToAccountsWithBlock:(void (^)(BOOL))block {
    ACAccountType *twitterType = [appDelegate.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        if (granted) {
            appDelegate.twitterAccounts = [appDelegate.accountStore accountsWithAccountType:twitterType];
        }
        block(granted);
    };
    
    [appDelegate.accountStore requestAccessToAccountsWithType:twitterType options:nil completion:handler];
}

- (void)twitterLogin:(ACAccount *)twitterAccount loginDelegate:(id<LoginDelegate>)loginDelegate {
    [appDelegate.twitterManager performReverseAuthForAccount:twitterAccount withHandler:^(NSData *responseData, NSError *error) {
        if (responseData) {
            NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            
            if ([responseStr rangeOfString:@"error code"].location != NSNotFound) {
                [Util hideHUD];
                [Util showErrorAlert:@"Unable to authenticate Twitter account. Double-check Twitter account info in device settings." delegate:nil];
                return;
            }
            
            NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
            
            NSString *accessToken = [NSString stringWithFormat:@"%@&%@", parts[0], parts[1]];
            NSString *twitterId = [parts[2] componentsSeparatedByString:@"="][1];
            NSString *username = [parts[3] componentsSeparatedByString:@"="][1];
            
            NSDictionary *twitterAccountProperties = [twitterAccount valueForKey:@"properties"];
            NSString *fullName = twitterAccountProperties[@"fullName"];
            if (!fullName) {
                fullName = @"";
            }
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setValue:@"twitter" forKey:@"provider"];
            [params setValue:accessToken forKey:@"access_token"];
            [params setValue:twitterId forKey:@"id"];
            [params setValue:username forKey:@"username"];
            [params setValue:username forKey:@"screen_name"];
            [params setValue:fullName forKey:@"name"];
            
            DDLogInfo(@"%@", params);
            
            appDelegate.loginDelegate = loginDelegate;
            [appDelegate login:params];
        }
        else {
            DDLogError(@"%@", error);
            
            NSString *message = @"Unable to login to Twitter.\n\nPlease verify your Twitter account settings in device settings.";
            [Util showErrorAlert:message delegate:nil];
        }
    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
}

#pragma mark - Customize appearance

- (void)customizeAppearance {
    // status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // navigation bar
    NSDictionary *titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIColor whiteColor], NSForegroundColorAttributeName,
                                         nil];
    
    [[UINavigationBar appearance] setBarTintColor:[Util colorFromHex:@"362f2d"]];
    [[UINavigationBar appearance] setTintColor:[Util colorFromHex:@"f26c4f"]];
    [[UINavigationBar appearance] setTitleTextAttributes:titleTextAttributes];
    
    // table view
    [[UITableView appearance] setSeparatorColor:[Util colorFromHex:@"cdcdcd"]];
    [[UITableView appearance] setSeparatorInset:UIEdgeInsetsZero];
    if ([[UITableView appearance] respondsToSelector:@selector(setLayoutMargins:)]) {
         [[UITableView appearance] setLayoutMargins:UIEdgeInsetsZero];
         [[UITableViewCell appearance] setLayoutMargins:UIEdgeInsetsZero];
    }
    
    // search bar
    [[UISearchBar appearance] setBarTintColor:[Util colorFromHex:@"362f2d"]];
    
    // tab bar
    [[UITabBar appearance] setBarTintColor:[Util colorFromHex:@"362f2d"]];
    [[UITabBar appearance] setTintColor:[Util colorFromHex:@"f26c4f"]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:10],
                                                        NSForegroundColorAttributeName : [UIColor whiteColor]
                                                        } forState:UIControlStateSelected];
}

#pragma mark - Basic actions

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
//        if (self.doNotShowResumeSplash) {
//        } else {
            self.splashImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:splashImageName]];
            self.splashImageView.frame = self.window.frame;
            [[UIApplication sharedApplication].windows.lastObject addSubview:self.splashImageView];
//        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
//    if (self.doNotShowResumeSplash && [[self.window subviews] count] > 1) {
//        [[[self.window subviews] lastObject] removeFromSuperview];
//    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([self.splashImageView isDescendantOfView:[UIApplication sharedApplication].windows.lastObject]) {
        sleep(1);
        [self.splashImageView removeFromSuperview];
//        self.doNotShowResumeSplash = NO;
    }
    
    [FBSDKAppEvents activateApp];
//    [self refreshTwitterAccounts];
    
    UIViewController *root = self.window.rootViewController;
    if ([root isKindOfClass:[UITabBarController class]]) {
        root = [(UITabBarController *)root selectedViewController];
    }
    [root viewWillAppear:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // save logged in user to persistent storage on device
    [appDelegate saveLoggedInUserToDevice];
}

@end
