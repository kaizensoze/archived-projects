//
//  NSMutableDictionary+Utility.m
//  Illuminex
//
//  Created by Joe Gallo on 9/23/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "NSMutableDictionary+Utility.h"

@implementation NSMutableDictionary (Utility)

- (void)setObjectNilToNull:(id)anObject forKey:(id<NSCopying>)aKey {
    id objectToUse;
    if (anObject == nil) {
        objectToUse = [NSNull null];
    }
    [self setObject:objectToUse forKey:aKey];
}

@end
