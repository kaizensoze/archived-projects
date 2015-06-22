//
//  BFKDao.h
//  Mosaic
//
//  Created by Joe Gallo on 11/18/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BFKNote.h"
#import "BFKNotePart.h"

@interface BFKDao : NSObject

// Note
+ (NSArray *)notes;
+ (NSArray *)noteNames;
+ (BFKNote *)noteWithName:(NSString *)name;
+ (BFKNote *)findOrCreateNoteWithName:(NSString *)name;
+ (BFKNote *)createNoteWithName:(NSString *)name save:(BOOL)save;
+ (void)deleteNote:(BFKNote *)note;

// NotePart
+ (BFKNotePart *)createNotePartWithText:(NSString *)text;
+ (BFKNotePart *)createNotePartWithImage:(UIImage *)image;
+ (void)deleteNotePart:(BFKNotePart *)notePart;

+ (void)saveContext;
+ (void)saveManagedObjects:(NSArray *)managedObjects;
+ (void)reset;

+ (void)describeData;

@end
