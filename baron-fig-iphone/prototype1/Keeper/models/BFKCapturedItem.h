//
//  BFKCapturedItem.h
//  Keeper
//
//  Created by Joe Gallo on 11/18/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BFKPage;

@interface BFKCapturedItem : NSManagedObject

@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) BFKPage * page;

@end
