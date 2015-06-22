//
//  NSDictionary+Utility.m
//  Taste Savant
//
//  Created by Joe Gallo on 11/21/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "NSDictionary+Utility.h"

@implementation NSDictionary (Utility)


// If value is NSNull, return nil.
- (id)objectForKeyNotNull:(id)key {
    id object = [self objectForKey:key];
    if (object == [NSNull null]) {
        return nil;
    }
    return object;
}

@end
