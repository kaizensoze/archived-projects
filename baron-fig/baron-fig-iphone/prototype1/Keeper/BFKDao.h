//
//  BFKDao.h
//  Keeper
//
//  Created by Joe Gallo on 11/18/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BFKNotebook.h"
#import "BFKSection.h"
#import "BFKPage.h"
#import "BFKCapturedImage.h"
#import "BFKCapturedNote.h"

@interface BFKDao : NSObject

+ (NSArray *)notebooks;
+ (NSArray *)notebookNames;
+ (BFKNotebook *)notebookWithName:(NSString *)name;
+ (BFKNotebook *)findOrCreateNotebookWithName:(NSString *)name;
+ (BFKNotebook *)createNotebookWithName:(NSString *)name;
+ (void)deleteNotebook:(BFKNotebook *)notebook;

+ (NSArray *)sections;
+ (NSArray *)sectionNames;
+ (int)numSections;
+ (BFKSection *)findOrCreateSectionWithName:(NSString *)name notebook:(BFKNotebook *)notebook;
+ (void)deleteSection:(BFKSection *)section;

+ (BFKPage *)createPageWithItem:(BFKCapturedItem *)item;
+ (void)deletePage:(BFKPage *)page;

// NOTE: These do not save the context.
+ (BFKCapturedImage *)createCapturedImage:(UIImage *)image;
+ (BFKCapturedImage *)createCapturedImage:(UIImage *)image note:(NSString *)note;

+ (BFKCapturedNote *)createCapturedNote:(NSString *)note;

+ (void)saveContext;
+ (void)saveManagedObjects:(NSArray *)managedObjects;
+ (void)reset;

+ (void)describeData;

+ (void)saveSampleData;

@end
