//
//  Cuisine.m
//  Taste Savant
//
//  Created by Joe Gallo on 2/18/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "Cuisine.h"

@implementation Cuisine

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _id = [[dict objectForKeyNotNull:@"id"] intValue];
        _name = [dict objectForKeyNotNull:@"name"];
    }
    return self;
}

// encode
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.id forKey:@"id"];
    [encoder encodeObject:self.name forKey:@"name"];
}

// decode
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.id = [decoder decodeIntForKey:@"id"];
        self.name = [decoder decodeObjectForKey:@"name"];
    }
    return self;
}

- (NSComparisonResult)compare:(Cuisine *)otherObject {
    return [self.name compare:otherObject.name];
}

- (NSString *)description {
    return [NSString stringWithFormat: @"%d %@", self.id, self.name];
}

@end
