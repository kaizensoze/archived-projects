//
//  ChatMessage.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/3/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "ChatMessage.h"
#import "User.h"

@implementation ChatMessage

- (id)initWithUser:(User *)user message:(NSString *)message {
    self = [super init];
    if (self) {
        self.user = user;
        self.message = message;
        self.timeCreated = [NSDate date];
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
    return [self isEqualToChatMessage:other];
}

- (BOOL)isEqualToChatMessage:(ChatMessage *)aChatMessage {
    if (self == aChatMessage)
        return YES;
    
    if (![(id)[self user] isEqual:[aChatMessage user]] || ![(id)[self message] isEqual:[aChatMessage message]])
        return NO;
    
    return YES;
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [self.user hash];
    result = prime * result + [self.message hash];
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"\nUser: %@\n"
            "Message: %@\n",
            self.user, self.message];
}

@end
