//
//  BFKNote.h
//  Mosaic
//
//  Created by Joe Gallo on 1/27/15.
//  Copyright (c) 2015 Baron Fig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BFKNotePart;

@interface BFKNote : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSOrderedSet *noteParts;
@end

@interface BFKNote (CoreDataGeneratedAccessors)

- (void)insertObject:(BFKNotePart *)value inNotePartsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromNotePartsAtIndex:(NSUInteger)idx;
- (void)insertNoteParts:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeNotePartsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInNotePartsAtIndex:(NSUInteger)idx withObject:(BFKNotePart *)value;
- (void)replaceNotePartsAtIndexes:(NSIndexSet *)indexes withNoteParts:(NSArray *)values;
- (void)addNotePartsObject:(BFKNotePart *)value;
- (void)removeNotePartsObject:(BFKNotePart *)value;
- (void)addNoteParts:(NSOrderedSet *)values;
- (void)removeNoteParts:(NSOrderedSet *)values;
@end
