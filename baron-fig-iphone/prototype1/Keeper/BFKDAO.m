//
//  BFKDao.m
//  Keeper
//
//  Created by Joe Gallo on 11/18/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import "BFKDao.h"
#import "BFKAppDelegate.h"

@implementation BFKDao

#pragma mark - Notebooks

+ (NSArray *)notebooks {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notebook" inManagedObjectContext:context];
    NSPredicate *predicate = nil;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = predicate;
    request.sortDescriptors = @[sortDescriptor];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (error) {
        DDLogInfo(@"%@", error);
    }
    
    return objects;
}

#pragma mark - Notebook names

+ (NSArray *)notebookNames {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notebook" inManagedObjectContext:context];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.sortDescriptors = @[sortDescriptor];
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

#pragma mark - Notebook with name

+ (BFKNotebook *)notebookWithName:(NSString *)name {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notebook" inManagedObjectContext:context];
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

#pragma mark - Find/create notebook

+ (BFKNotebook *)findOrCreateNotebookWithName:(NSString *)name {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notebook" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name = %@)", name];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = predicate;
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (error) {
        DDLogInfo(@"%@", error);
    }
    
    BFKNotebook *notebook;
    
    // if notebook doesn't exist, create it
    if (objects.count == 0) {
        notebook = [NSEntityDescription insertNewObjectForEntityForName:@"Notebook" inManagedObjectContext:context];
        notebook.name = name;
        
        NSError *error;
        [context save:&error];
        
        if (error) {
            DDLogInfo(@"%@", error);
        }
    } else {
        notebook = (BFKNotebook *)objects.firstObject;
    }
    
    return notebook;
}

#pragma mark - Create notebook

+ (BFKNotebook *)createNotebookWithName:(NSString *)name {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    BFKNotebook *notebook = [NSEntityDescription insertNewObjectForEntityForName:@"Notebook" inManagedObjectContext:context];
    notebook.name = name;
    
    NSError *error;
    [context save:&error];
    
    if (error) {
        DDLogInfo(@"%@", error);
    }
    
    return notebook;
}


#pragma mark - Delete notebook

+ (void)deleteNotebook:(BFKNotebook *)notebook {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    [context deleteObject:notebook];
    
    NSError *error;
    [context save:&error];
    if (error) {
        DDLogInfo(@"%@", error);
    }
}

#pragma mark - Sections

+ (NSArray *)sections {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Section" inManagedObjectContext:context];
    NSPredicate *predicate = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = predicate;
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (error) {
        DDLogInfo(@"%@", error);
    }
    
    return objects;
}

#pragma mark - Section names

+ (NSArray *)sectionNames {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Section" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
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

#pragma mark - Number of sections

+ (int)numSections {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Section"];
    NSUInteger count = [context countForFetchRequest:request error:nil];
    
    return count;
}

#pragma mark - Find/create section

+ (BFKSection *)findOrCreateSectionWithName:(NSString *)name notebook:(BFKNotebook *)notebook {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Section" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"notebook = %@ AND name = %@", notebook, name];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entity;
    request.predicate = predicate;
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (error) {
        DDLogInfo(@"%@", error);
    }
    
    BFKSection *section;
    
    // if section doesn't exist, create it
    if (objects.count == 0) {
        section = [NSEntityDescription insertNewObjectForEntityForName:@"Section" inManagedObjectContext:context];
        section.name = name;
        
        NSError *error;
        [context save:&error];
        
        if (error) {
            DDLogInfo(@"%@", error);
        }
    } else {
        section = (BFKSection *)objects.firstObject;
    }
    
    return section;
}

#pragma mark - Delete section

+ (void)deleteSection:(BFKSection *)section {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    [context deleteObject:section];
    
    NSError *error;
    [context save:&error];
    if (error) {
        DDLogInfo(@"%@", error);
    }
}

#pragma mark - Create page

+ (BFKPage *)createPageWithItem:(BFKCapturedItem *)item {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    BFKPage *page = [NSEntityDescription insertNewObjectForEntityForName:@"Page" inManagedObjectContext:context];
    page.item = item;
    
    NSError *error;
    [context save:&error];
    
    if (error) {
        DDLogInfo(@"%@", error);
    }
    
    return page;
}

#pragma mark - Delete page

+ (void)deletePage:(BFKPage *)page {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    [context deleteObject:page];
    
    NSError *error;
    [context save:&error];
    if (error) {
        DDLogInfo(@"%@", error);
    }
}

#pragma mark - Create captured image

+ (BFKCapturedImage *)createCapturedImage:(UIImage *)image {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CapturedImage" inManagedObjectContext:context];
    BFKCapturedImage *capturedImage = [[BFKCapturedImage alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    capturedImage.image = UIImagePNGRepresentation(image);
    
    return capturedImage;
}

+ (BFKCapturedImage *)createCapturedImage:(UIImage *)image note:(NSString *)note {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CapturedImage" inManagedObjectContext:context];
    BFKCapturedImage *capturedImage = [[BFKCapturedImage alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    capturedImage.image = UIImagePNGRepresentation(image);
    capturedImage.note = note;
    
    return capturedImage;
}

#pragma mark - Create captured note

+ (BFKCapturedNote *)createCapturedNote:(NSString *)note {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    BFKCapturedNote *capturedNote = [NSEntityDescription insertNewObjectForEntityForName:@"CapturedNote"
                                                                   inManagedObjectContext:context];
    capturedNote.note = note;
    
    NSError *error;
    [context save:&error];
    
    if (error) {
        DDLogInfo(@"%@", error);
    }
    
    return capturedNote;
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

#pragma mark - Save managed objects

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

+ (void)describeData {
    NSArray *notebooks = [self notebooks];
    
    for (BFKNotebook *notebook in notebooks) {
        DDLogInfo(@"%@", notebook.name);
        for (BFKSection *section in notebook.sections) {
            DDLogInfo(@"  %@", section.name);
            for (BFKPage *page in section.pages) {
                BFKCapturedItem *item = page.item;
                if ([item isKindOfClass:[BFKCapturedNote class]]) {
                    DDLogInfo(@"    %@", ((BFKCapturedNote *)item).note);
                }
            }
        }
    }
}

#pragma mark - Save sample data

+ (void)saveSampleData {
    [self reset];
    
    BFKNotebook *notebook = [self findOrCreateNotebookWithName:@"N1"];
    [notebook addSectionsObject:[self findOrCreateSectionWithName:@"A" notebook:notebook]];
    [notebook addSectionsObject:[self findOrCreateSectionWithName:@"B" notebook:notebook]];
    [notebook addSectionsObject:[self findOrCreateSectionWithName:@"C" notebook:notebook]];
    [notebook addSectionsObject:[self findOrCreateSectionWithName:@"D" notebook:notebook]];
    [notebook addSectionsObject:[self findOrCreateSectionWithName:@"E" notebook:notebook]];
    [notebook addSectionsObject:[self findOrCreateSectionWithName:@"F" notebook:notebook]];
    [notebook addSectionsObject:[self findOrCreateSectionWithName:@"G" notebook:notebook]];
    [notebook addSectionsObject:[self findOrCreateSectionWithName:@"H" notebook:notebook]];
    
//    BFKCapturedImage *item = [self createCapturedImage:nil note:@"test"];
//    BFKPage *page = [self createPageWithItem:item];
//    
//    [notebook.sections.firstObject addPagesObject:page];
    
    [BFKDao saveContext];
}

@end
