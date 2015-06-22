//
//  BFKCapturedImage.h
//  Keeper
//
//  Created by Joe Gallo on 11/18/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BFKCapturedItem.h"


@interface BFKCapturedImage : BFKCapturedItem

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * imported;


@end
