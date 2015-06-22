//
//  AppDelegate.h
//  GroupSlots
//
//  Created by Joe Gallo on 4/5/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IIViewDeckController;
@class CachedData;
@class User;
@class NavigationBarTitleViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, SocketIODelegate, IIViewDeckControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SocketIO *socketIO;
@property (strong, nonatomic) NSString *casinoId;
@property (strong, nonatomic) IIViewDeckController *viewDeckController;
@property (strong, nonatomic) CachedData *cachedData;
@property (strong, nonatomic) User *loggedInUser;
@property (strong, nonatomic) NSDictionary *testUsers;
@property (strong, nonatomic) NSDictionary *testRewards;
@property (strong, nonatomic) NavigationBarTitleViewController *navbarTitleVC;
@property (strong, nonatomic) DDFileLogger *fileLogger;
@property (nonatomic) CGRect keyboardFrame;

- (void)useMainNav:(UIViewController *)vc;
- (void)clearFacebookSession;
- (void)logout;

- (void)saveCustomObject:(NSObject *)obj as:(NSString *)key;
- (NSObject *)loadCustomObject:(NSString *)key;

- (void)saveLoggedInUserToDevice;

@end
