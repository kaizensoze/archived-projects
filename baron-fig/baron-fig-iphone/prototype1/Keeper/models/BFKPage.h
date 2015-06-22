//
//  BFKPage.h
//  Keeper
//
//  Created by Joe Gallo on 11/18/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BFKCapturedItem, BFKSection;

@interface BFKPage : NSManagedObject

@property (nonatomic, retain) BFKSection *section;
@property (nonatomic, retain) BFKCapturedItem *item;

@end
