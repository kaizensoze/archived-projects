//
//  BFKNotePart.h
//  Mosaic
//
//  Created by Joe Gallo on 1/27/15.
//  Copyright (c) 2015 Baron Fig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BFKNote;

@interface BFKNotePart : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) BFKNote *note;

@end
