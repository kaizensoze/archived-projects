//
//  AppDelegate.h
//  Taste Savant
//
//  Created by Joe Gallo on 10/24/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TWAPIManager.h"
#import "ProfileDelegate.h"
#import "LoginDelegate.h"
#import "GAI.h"

@class FBSDKLoginManager;
@class ACAccountStore;
@class DDFileLogger;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, ProfileDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *lastLocation;
@property (nonatomic) NSString *cityOverride;
@property (nonatomic) NSString *lastCurrentLocationCity;
@property (strong, nonatomic) CLLocation *customLocation;

@property (strong, nonatomic) AFHTTPClient *httpClient;

@property (strong, nonatomic) id<GAITracker> tracker;

@property (strong, nonatomic) CachedData *cachedData;

@property (strong, nonatomic) User *loggedInUser;

@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) FBSDKLoginManager *facebookLoginManager;
@property (strong, nonatomic) NSDictionary *facebookData;
@property (strong, nonatomic) NSArray *twitterAccounts;
@property (strong, nonatomic) TWAPIManager *twitterManager;

@property BOOL newUserCreatedViaSocialAuth;

@property (nonatomic) BOOL loginSignupAsModal;
@property id<LoginDelegate> loginDelegate;

@property (strong, nonatomic) DDFileLogger *fileLogger;

- (void)setRootViewController:(UIViewController *)vc;

- (void)showLogin:(UIViewController *)vc;
- (void)login:(NSDictionary *)params;
- (void)logout;

- (void)showNotLoggedInScreen:(UIViewController *)vc loginButtonDetail:(NSString *)detail;
- (void)removeNotLoggedInScreen;

- (void)showLoadingScreen:(UIView *)view;
- (void)removeLoadingScreen:(UIViewController *)vc;

- (void)saveCustomObject:(NSObject *)obj as:(NSString *)key;
- (NSObject *)loadCustomObject:(NSString *)key;

- (void)saveLoggedInUserToDevice;

- (void)findNearestCity:(CLLocation *)currentLocation;
- (void)overrideCity:(NSString *)cityShortName;

- (void)openSession;
- (void)refreshTwitterAccounts;
- (void)twitterLogin:(ACAccount *)twitterAccount loginDelegate:(id<LoginDelegate>)loginDelegate;

@end
