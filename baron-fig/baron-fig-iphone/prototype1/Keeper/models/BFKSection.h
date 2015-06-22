//
//  BFKSection.h
//  Keeper
//
//  Created by Joe Gallo on 11/18/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BFKNotebook, BFKPage;

@interface BFKSection : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) BFKNotebook *notebook;
@property (nonatomic, retain) NSOrderedSet *pages;
@end

@interface BFKSection (CoreDataGeneratedAccessors)

- (void)insertObject:(BFKPage *)value inPagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPagesAtIndex:(NSUInteger)idx;
- (void)insertPages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPagesAtIndex:(NSUInteger)idx withObject:(BFKPage *)value;
- (void)replacePagesAtIndexes:(NSIndexSet *)indexes withPages:(NSArray *)values;
- (void)addPagesObject:(BFKPage *)value;
- (void)removePagesObject:(BFKPage *)value;
- (void)addPages:(NSOrderedSet *)values;
- (void)removePages:(NSOrderedSet *)values;
@end
