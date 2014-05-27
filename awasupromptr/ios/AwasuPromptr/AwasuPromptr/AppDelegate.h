//
//  AppDelegate.h
//  AwasuPromptr
//
//  Created by Joe Gallo on 7/1/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IIViewDeckController;
@class User;
@class CachedData;
@class DDFileLogger;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) IIViewDeckController *viewDeckController;
@property (strong, nonatomic) User *loggedInUser;
@property (strong, nonatomic) CachedData *cachedData;
@property (strong, nonatomic) DDFileLogger *fileLogger;

- (void)saveCustomObject:(NSObject *)obj as:(NSString *)key;
- (NSObject *)loadCustomObject:(NSString *)key;

@end
