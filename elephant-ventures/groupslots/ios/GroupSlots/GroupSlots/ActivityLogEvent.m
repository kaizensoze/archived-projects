//
//  ActivityEvent.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/21/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "ActivityLogEvent.h"

@implementation ActivityLogEvent

- (id)init {
    self = [super init];
    if (self) {
        self.timestamp = [NSDate date];
    }
    return self;
}

- (id)initWithDescription:(NSString *)description {
    self = [self init];
    self.eventDescription = description;
    return self;
}

- (void)encodeWithCoder:(NSCoder *)anEncoder {
    [anEncoder encodeObject:self.timestamp forKey:@"timestamp"];
    [anEncoder encodeObject:self.eventDescription forKey:@"eventDescription"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.timestamp = [aDecoder decodeObjectForKey:@"timestamp"];
        self.eventDescription = [aDecoder decodeObjectForKey:@"eventDescription"];
    }
    return self;
}

- (NSString *)formattedTimestamp {
    return [Util dateToString:self.timestamp dateFormat:@"MM/dd/yyyy HH:mm"];
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"\nTimestamp: %@\n"
            "Description: %@\n",
            [self formattedTimestamp], self.eventDescription];
}

@end
