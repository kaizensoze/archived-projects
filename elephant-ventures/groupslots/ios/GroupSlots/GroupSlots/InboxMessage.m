//
//  InboxMessage.m
//  GroupSlots
//
//  Created by Joe Gallo on 6/11/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "InboxMessage.h"

@implementation InboxMessage

- (id)initWithMessage:(NSString *)message iconPath:(NSString *)iconPath {
    self = [super init];
    if (self) {
        self.message = message;
        self.iconPath = iconPath;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)anEncoder {
    [anEncoder encodeObject:self.message forKey:@"message"];
    [anEncoder encodeObject:self.iconPath forKey:@"iconPath"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.message = [aDecoder decodeObjectForKey:@"message"];
        self.iconPath = [aDecoder decodeObjectForKey:@"iconPath"];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"\nMessage: %@\n"
            @"\nIcon path: %@\n",
            self.message, self.iconPath];
}

@end
