//
//  Group.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/28/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "Group.h"
#import "User.h"
#import <stdlib.h>

@implementation Group

- (id)initWithId:(NSNumber *)id {
    self = [super init];
    if (self) {
        self.id = id;
    }
    return self;
}

- (id)initWithName:(NSString *)name {
    return [self initWithId:[NSNumber numberWithInt:arc4random()] name:name];
}

- (id)initWithId:(NSNumber *)id name:(NSString *)name {
    self = [super init];
    if (self) {
        self.id = id;
        self.name = name;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)anEncoder {
    [anEncoder encodeObject:self.id forKey:@"id"];
    [anEncoder encodeObject:self.name forKey:@"name"];
    [anEncoder encodeObject:self.members forKey:@"members"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.id = [aDecoder decodeObjectForKey:@"id"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.members = [aDecoder decodeObjectForKey:@"members"];
    }
    return self;
}

- (NSMutableArray *)members {
    if (!_members) {
        _members = [[NSMutableArray alloc] init];
    }
    return _members;
}

- (BOOL)hasUser:(User *)user {
    return [self.members containsObject:user];
}

- (BOOL)isEqual:(id)other {
    if (self == other) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToGroup:other];
}

- (BOOL)isEqualToGroup:(Group *)aGroup {
    if (self == aGroup)
        return YES;
    
    if (![(id)[self id] isEqual:[aGroup id]])
        return NO;
    
    return YES;
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [self.id hash];
    return result;
}

- (NSString *)description {
    NSArray *groupMemberUsernames = [self.members valueForKey:@"username"];
    
    return [NSString stringWithFormat:
            @"\nId: %@\n"
            "Name: %@\n"
            "Members: %@\n",
            self.id, self.name, groupMemberUsernames];
}

@end
