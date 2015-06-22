//
//  ILUBookmarkedItem.m
//  illuminex
//
//  Created by Joe Gallo on 11/11/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "ILUBookmarkedItem.h"

@implementation ILUBookmarkedItem

- (id)initWithItem:(ILUItem *)item {
    self = [super init];
    if (self) {
        _item = item;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.item = [decoder decodeObjectForKey:@"item"];
        self.collections = [decoder decodeObjectForKey:@"collections"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.item forKey:@"item"];
    [encoder encodeObject:self.collections forKey:@"collections"];
}

@end
