//
//  BFKNotebook.h
//  Keeper
//
//  Created by Joe Gallo on 11/18/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BFKSection;

@interface BFKNotebook : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSOrderedSet *sections;
@end

@interface BFKNotebook (CoreDataGeneratedAccessors)

- (void)insertObject:(BFKSection *)value inSectionsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSectionsAtIndex:(NSUInteger)idx;
- (void)insertSections:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSectionsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSectionsAtIndex:(NSUInteger)idx withObject:(BFKSection *)value;
- (void)replaceSectionsAtIndexes:(NSIndexSet *)indexes withSections:(NSArray *)values;
- (void)addSectionsObject:(BFKSection *)value;
- (void)removeSectionsObject:(BFKSection *)value;
- (void)addSections:(NSOrderedSet *)values;
- (void)removeSections:(NSOrderedSet *)values;

- (int)numPages;

@end
