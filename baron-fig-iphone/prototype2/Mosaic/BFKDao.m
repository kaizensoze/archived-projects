//
//  BFKDao.m
//  Mosaic
//
//  Created by Joe Gallo on 11/18/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import "BFKDao.h"
#import "BFKAppDelegate.h"

@implementation BFKDao

#pragma mark - Note

+ (NSArray *)notes {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
//    NSPredicate *predicate = nil;
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
//    request.predicate = predicate;
//    request.sortDescriptors = @[sortDescriptor];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (error) {
        DDLogInfo(@"%@", error);
    }
    
    return objects;
}

+ (NSArray *)noteNames {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
//    request.sortDescriptors = @[sortDescriptor];
    request.resultType = NSDictionaryResultType;
    request.returnsDistinctResults = YES;
    request.propertiesToFetch = @[@"name"];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (error) {
        DDLogInfo(@"%@", error);
    }
    if (objects) {
        objects = [objects valueForKey:@"name"];
    }
    
    return objects;
}

+ (BFKNote *)noteWithName:(NSString *)name {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name = %@)", name];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = predicate;
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (error) {
        DDLogInfo(@"%@", error);
    }
    
    return objects.firstObject;
}

+ (BFKNote *)findOrCreateNoteWithName:(NSString *)name {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name = %@)", name];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = predicate;
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (error) {
        DDLogInfo(@"%@", error);
    }
    
    BFKNote *note;
    
    // if notebook doesn't exist, create it
    if (objects.count == 0) {
        note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
        note.name = name;
        
        NSError *error;
        [context save:&error];
        
        if (error) {
            DDLogInfo(@"%@", error);
        }
    } else {
        note = (BFKNote *)objects.firstObject;
    }
    
    return note;
}

+ (BFKNote *)createNoteWithName:(NSString *)name save:(BOOL)save {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    BFKNote *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
    note.name = name;
    
    if (save) {
        NSError *error;
        [context save:&error];
        
        if (error) {
            DDLogInfo(@"%@", error);
        }
    }
    
    return note;
}

+ (void)deleteNote:(BFKNote *)note {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    [context deleteObject:note];
    
    NSError *error;
    [context save:&error];
    if (error) {
        DDLogInfo(@"%@", error);
    }
}

#pragma mark - NotePart

+ (BFKNotePart *)createNotePartWithText:(NSString *)text {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    BFKNotePart *notePart = [NSEntityDescription insertNewObjectForEntityForName:@"NotePart"
                                                          inManagedObjectContext:context];
    notePart.date = [NSDate date];
    notePart.text = text;
    
    NSError *error;
    [context save:&error];
    
    if (error) {
        DDLogInfo(@"%@", error);
    }
    
    return notePart;
}

+ (BFKNotePart *)createNotePartWithImage:(UIImage *)image {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    BFKNotePart *notePart = [NSEntityDescription insertNewObjectForEntityForName:@"NotePart"
                                                          inManagedObjectContext:context];
    notePart.date = [NSDate date];
    notePart.image = UIImagePNGRepresentation(image);
    
    NSError *error;
    [context save:&error];
    
    if (error) {
        DDLogInfo(@"%@", error);
    }
    
    return notePart;
}

+ (void)deleteNotePart:(BFKNotePart *)notePart {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    [context deleteObject:notePart];
    
    NSError *error;
    [context save:&error];
    if (error) {
        DDLogInfo(@"%@", error);
    }
}

#pragma mark - Save

+ (void)saveContext {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSError *error;
    [context save:&error];
    
    if (error) {
        DDLogInfo(@"%@", error);
    }
}

+ (void)saveManagedObjects:(NSArray *)managedObjects {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    for (NSManagedObject *managedObject in managedObjects) {
        [context insertObject:managedObject];
    }
    
    NSError *error;
    [context save:&error];
    
    if (error) {
        DDLogInfo(@"%@", error);
    }
}

#pragma mark - Reset

+ (void)reset {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.parentContext = appDelegate.managedObjectContext;
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    
    __block NSPersistentStore *store = context.persistentStoreCoordinator.persistentStores.lastObject;
    __block NSURL *storeURL = [context.persistentStoreCoordinator URLForPersistentStore:store];
    
    __block NSError *error;
    
    [context performBlockAndWait:^{
        [context reset];
        
        BOOL success = [context.persistentStoreCoordinator removePersistentStore:store error:&error];
        if (success) {
            [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
            [context.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                             configuration:nil URL:storeURL options:nil error:&error];
        }
    }];
}

#pragma mark - Describe data

+ (void)describeData {
    NSArray *notes = [self notes];
    for (BFKNote *note in notes) {
        DDLogInfo(@"%@", note.name);
    }
}

@end
