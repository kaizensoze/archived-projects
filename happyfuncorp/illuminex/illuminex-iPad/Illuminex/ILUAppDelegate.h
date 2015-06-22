//
//  AppDelegate.h
//  Illuminex
//
//  Created by Joe Gallo on 9/23/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ILUAppDelegate : UIResponder <UIApplicationDelegate, IIViewDeckControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DDFileLogger *fileLogger;
@property (strong, nonatomic) AFHTTPRequestOperationManager *requestManager;
@property (strong, nonatomic) IIViewDeckController *viewDeckController;
@property (strong, nonatomic) NSString *authToken;
@property (strong, nonatomic) NSString *installationIdentifier;

- (void)saveObject:(NSObject *)obj forKey:(NSString *)key;
- (NSObject *)objectForKey:(NSString *)key;

@end
