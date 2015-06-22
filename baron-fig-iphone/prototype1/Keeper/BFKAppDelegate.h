//
//  BFKAppDelegate.h
//  Keeper
//
//  Created by Joe Gallo on 10/22/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "IIViewDeckController.h"
#import "BFKCaptureViewController.h"

@interface BFKAppDelegate : UIResponder <
    UIApplicationDelegate,
    IIViewDeckControllerDelegate
>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) DDFileLogger *fileLogger;
@property (strong, nonatomic) IIViewDeckController *viewDeckController;

@property (strong, nonatomic) NSString *suggestedNotebook;
@property (strong, nonatomic) NSString *suggestedSection;

@property (strong, nonatomic) BFKCaptureViewController *captureVC;
@property (strong, nonatomic) UIViewController *reviewRedirectVC;

@property (strong, nonatomic) id<GAITracker> tracker;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)saveObject:(NSObject *)obj forKey:(NSString *)key;
- (NSObject *)objectForKey:(NSString *)key;

@end
