//
//  NSMutableDictionary+Utility.h
//  Taste Savant
//
//  Created by Joe Gallo on 1/22/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Utility)

- (void)setObjectNilToNull:(id)anObject forKey:(id<NSCopying>)aKey;

@end
