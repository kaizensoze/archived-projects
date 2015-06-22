//
//  NSMutableDictionary+Utility.h
//  Mosaic
//
//  Created by Joe Gallo on 10/22/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Utility)

- (void)setObjectNilToNull:(id)anObject forKey:(id<NSCopying>)aKey;

@end
