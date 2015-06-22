//
//  BFKAppDelegate.h
//  Mosaic
//
//  Created by Joe Gallo on 10/22/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "IIViewDeckController.h"

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

@property (strong, nonatomic) UIViewController *reviewRedirectVC;

@property (strong, nonatomic) id<GAITracker> tracker;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (NSObject *)objectForKey:(NSString *)key;
- (void)saveObject:(NSObject *)obj forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;

@end
