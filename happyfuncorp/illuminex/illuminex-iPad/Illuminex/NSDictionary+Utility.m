//
//  NSDictionary+Utility.m
//  Illuminex
//
//  Created by Joe Gallo on 9/23/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "NSDictionary+Utility.h"

@implementation NSDictionary (Utility)

- (id)objectForKeyNotNull:(id)key {
    id object = [self objectForKey:key];
    if (object == [NSNull null]) {
        return nil;
    }
    return object;
}

@end
