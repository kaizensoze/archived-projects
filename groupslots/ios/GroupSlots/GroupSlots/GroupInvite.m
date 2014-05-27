//
//  GroupInvite.m
//  GroupSlots
//
//  Created by Joe Gallo on 6/12/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "GroupInvite.h"
#import "User.h"
#import "Group.h"

@implementation GroupInvite

- (id)init {
    self = [super init];
    if (self) {
        self.status = INVITE_PENDING;
    }
    return self;
}

- (id)initWithInviter:(User *)inviter {
    self = [self init];
    if (self) {
        self.inviter = inviter;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)anEncoder {
    [anEncoder encodeObject:self.inviter forKey:@"inviter"];
    [anEncoder encodeObject:[NSNumber numberWithInt:self.status] forKey:@"status"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.inviter = [aDecoder decodeObjectForKey:@"inviter"];
        self.status = [[aDecoder decodeObjectForKey:@"status"] intValue];
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (self == other) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToGroupInvite:other];
}

- (BOOL)isEqualToGroupInvite:(GroupInvite *)aGroupInvite {
    if (self == aGroupInvite)
        return YES;
    
    if (![(id)[self inviter] isEqual:[aGroupInvite inviter]])
        return NO;
    
    if (![(id)[self.inviter group] isEqual:[aGroupInvite.inviter group]])
        return NO;
    
    return YES;
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [self.inviter hash];
    result = prime * result + [self.inviter.group hash];
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"\nInviter: %@\n"
            "Status: %@\n",
            self.inviter, [Util enumToString:self.status]];
}

@end
