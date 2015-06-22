//
//  ILUCollection.m
//  illuminex
//
//  Created by Joe Gallo on 11/11/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "ILUCollection.h"

@implementation ILUCollection

- (id)initWithId:(int)id name:(NSString *)name {
    self = [super init];
    if (self) {
        _id = id;
        _name = name;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.id = [decoder decodeIntForKey:@"id"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.items = [decoder decodeObjectForKey:@"items"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.id forKey:@"id"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.items forKey:@"items"];
}

- (NSMutableArray *)items {
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}

- (BOOL)isEqualToCollection:(ILUCollection *)aCollection {
    if (self == aCollection)
        return YES;
    if (self.id != aCollection.id)
        return NO;
    return YES;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToCollection:other];
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + self.id;
    return result;
}

- (NSString *)description {
    return self.name;
}

@end
