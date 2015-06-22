//
//  NSMutableDictionary+Utility.m
//  Taste Savant
//
//  Created by Joe Gallo on 1/22/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
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
