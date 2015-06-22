//
//  Neighborhood.m
//  Taste Savant
//
//  Created by Joe Gallo on 2/18/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "Neighborhood.h"

@implementation Neighborhood

- (id)initWithId:(int)id name:(NSString *)name {
    return [self initWithId:id name:name parentName:nil];
}

- (id)initWithId:(int)id name:(NSString *)name parentName:(NSString *)parentName {
    self = [super init];
    if (self) {
        self.id = id;
        self.name = name;
        self.parentName = parentName;
    }
    return self;
}

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.id = [dict[@"id"] intValue];
        self.name = [dict objectForKeyNotNull:@"name"];
        self.parentName = [dict objectForKeyNotNull:@"parent"];
        self.borough = [dict objectForKeyNotNull:@"borough"];
        self.city = [dict objectForKeyNotNull:@"city"];
        self.children = [dict objectForKeyNotNull:@"children"];
    }
    return self;
}

// encode
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.id forKey:@"id"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeInt:self.parentId forKey:@"parentId"];
    [encoder encodeObject:self.parentName forKey:@"parentName"];
    [encoder encodeObject:self.borough forKey:@"borough"];
    [encoder encodeObject:self.city forKey:@"city"];
    [encoder encodeObject:self.children forKey:@"children"];
}

// decode
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.id = [decoder decodeIntForKey:@"id"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.parentId = [decoder decodeIntForKey:@"parentId"];
        self.parentName = [decoder decodeObjectForKey:@"parentName"];
        self.borough = [decoder decodeObjectForKey:@"borough"];
        self.city = [decoder decodeObjectForKey:@"city"];
        self.children = [decoder decodeObjectForKey:@"children"];
    }
    return self;
}

+ (Neighborhood *)currentLocation {
    Neighborhood *neighborhood = [[Neighborhood alloc] initWithId:[NSNumber numberWithInt:-1]
                                                             name:@"Current Location"
                                                           parentName:nil];
    return neighborhood;
}

- (id)copyWithZone:(NSZone *)zone {
    Neighborhood *copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.id = self.id;
        copy.name = self.name;
        copy.parentId = self.parentId;
        copy.parentName = self.parentName;
        copy.borough = self.borough;
        copy.city = self.city;
        copy.children = self.children;
    }
    
    return copy;
}

- (NSComparisonResult)compare:(Neighborhood *)otherObject {
    return [self.name compare:otherObject.name];
}

- (BOOL)isEqualToNeighborhood:(Neighborhood *)aNeighborhood {
    if (self == aNeighborhood)
        return YES;
    if (![(id)[NSNumber numberWithInt:[self id]] isEqual:[NSNumber numberWithInt:[aNeighborhood id]]])
        return NO;
    return YES;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToNeighborhood:other];
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [[NSNumber numberWithInt:self.id] hash];
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"%@ : %@ : %@ (%d)",
            self.city, self.parentName, self.name, self.id];
}

@end
