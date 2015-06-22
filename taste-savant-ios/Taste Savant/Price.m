//
//  Price.m
//  Taste Savant
//
//  Created by Joe Gallo on 6/2/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "Price.h"

@implementation Price

- (id)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
        _id = [appDelegate.cachedData.priceData[_name] intValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.id forKey:@"id"];
    [encoder encodeObject:self.name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.id = [decoder decodeIntForKey:@"id"];
        self.name = [decoder decodeObjectForKey:@"name"];
    }
    return self;
}

- (BOOL)isEqualToPrice:(Price *)aPrice {
    if (self == aPrice)
        return YES;
    if (![(id)[self name] isEqual:[aPrice name]])
        return NO;
    return YES;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToPrice:other];
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [self.name hash];
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"%d %@", self.id, self.name];
}

@end
