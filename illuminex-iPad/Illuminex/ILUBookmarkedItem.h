//
//  ILUBookmarkedItem.h
//  illuminex
//
//  Created by Joe Gallo on 11/11/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ILUItem.h"

@interface ILUBookmarkedItem : NSObject <NSCoding>

@property (strong, nonatomic) ILUItem *item;
@property (strong, nonatomic) NSMutableArray *collections;

- (id)initWithItem:(ILUItem *)item;

@end
