//
//  BFKAppDelegate.m
//  Mosaic
//
//  Created by Joe Gallo on 10/22/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import "BFKAppDelegate.h"
#import "BFKDao.h"
#import "NSManagedObjectModel+KCOrderedAccessorFix.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface BFKAppDelegate ()

@end

@implementation BFKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // cocoa lumberjack
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    self.fileLogger = [[DDFileLogger alloc] init];
    self.fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    self.fileLogger.logFileManager.maximumNumberOfLogFiles = 3;
    [DDLog addLogger:self.fileLogger];
    
    // status bar
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    // back button
    UIImage *backButtonImage = [UIImage imageNamed:@"back-button"];
    [UINavigationBar appearance].backIndicatorImage = backButtonImage;
    [UINavigationBar appearance].backIndicatorTransitionMaskImage = backButtonImage;
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    
    // crashlytics
//    [Fabric with:@[CrashlyticsKit]];
    
    // google analytics
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-57249968-1"];
    
    // view deck
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Mosaic" bundle:nil];
    UIViewController *noteListVC = [storyboard instantiateViewControllerWithIdentifier:@"NoteListNav"];
    UIViewController *sidebarVC = [storyboard instantiateViewControllerWithIdentifier:@"SidebarNav"];

    self.viewDeckController =  [[IIViewDeckController alloc] initWithCenterViewController:noteListVC
                                                                       leftViewController:sidebarVC];
    self.viewDeckController.panningMode = IIViewDeckNoPanning;
    self.viewDeckController.delegate = self;
    self.viewDeckController.leftSize = 0;

    // check whether or not to show getting started intro
    [self removeObjectForKey:@"skipIntro"]; // FIXME: REMOVE
    UIViewController *initialVC;
    if (![self objectForKey:@"skipIntro"]) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
        initialVC = [storyboard instantiateViewControllerWithIdentifier:@"Intro"];
        [self saveObject:@"YES" forKey:@"skipIntro"];
    } else {
        initialVC = self.viewDeckController;
    }
    self.window.rootViewController = initialVC;
    
//    [BFKDao reset];
    
    return YES;
}

#pragma mark - IIViewDeckControllerDelegate

- (void)viewDeckController:(IIViewDeckController *)viewDeckController
               applyShadow:(CALayer *)shadowLayer withBounds:(CGRect)rect {
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    if (viewDeckSide == IIViewDeckLeftSide) {
        viewDeckController.panningMode = IIViewDeckFullViewPanning;
    }
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    if (viewDeckSide == IIViewDeckLeftSide) {
        viewDeckController.panningMode = IIViewDeckNoPanning;
    }
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
//    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "baronfig.Mosaic" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Mosaic" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    [_managedObjectModel kc_generateOrderedSetAccessors];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Mosaic.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - User defaults stuff

- (NSObject *)objectForKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSData *encodedObject = [userDefaults objectForKey:key];
    NSObject *obj = nil;
    if (encodedObject) {
        obj = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    }
    return obj;
}

- (void)saveObject:(NSObject *)obj forKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:obj];
    [userDefaults setObject:encodedObject forKey:key];
    [userDefaults synchronize];
}

- (void)removeObjectForKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:key];
}

@end
