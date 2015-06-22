//
//  HBSTWhoToCallItem.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/28/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTWhoToCallItem.h"

@implementation HBSTWhoToCallItem

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.subject = [dict objectForKeyNotNull:@"subject"];
        self.title = [dict objectForKeyNotNull:@"title"];
        self.name = [dict objectForKeyNotNull:@"name"];
        self.phoneNumber = [dict objectForKeyNotNull:@"phone_number"];
        self.email = [dict objectForKeyNotNull:@"email"];
    }
    return self;
}

// encode
- (void)encodeWithCoder:(NSCoder *)encoder {
    // public
    [encoder encodeObject:self.subject forKey:@"subject"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.phoneNumber forKey:@"phoneNumber"];
    [encoder encodeObject:self.email forKey:@"email"];
}

// decode
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        // public
        self.subject = [decoder decodeObjectForKey:@"subject"];
        self.title = [decoder decodeObjectForKey:@"title"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.phoneNumber = [decoder decodeObjectForKey:@"phoneNumber"];
        self.email = [decoder decodeObjectForKey:@"email"];
    }
    return self;
}

- (NSComparisonResult)compare:(HBSTWhoToCallItem *)otherObject {
    return [self.subject isEqualToString:otherObject.subject]
        && [self.title isEqualToString:otherObject.title]
        && [self.name isEqualToString:otherObject.name];
}

- (id)copyWithZone:(NSZone *)zone {
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        [copy setSubject:[self.subject copyWithZone:zone]];
        [copy setTitle:[self.title copyWithZone:zone]];
        [copy setName:[self.name copyWithZone:zone]];
        [copy setPhoneNumber:[self.phoneNumber copyWithZone:zone]];
        [copy setEmail:[self.email copyWithZone:zone]];
    }
    
    return copy;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"\n"
            "subject: %@\n"
            "title: %@\n"
            "name: %@\n"
            "phoneNumber: %@\n"
            "email: %@\n",
            self.subject,
            self.title,
            self.name,
            self.phoneNumber,
            self.email
            ];
}

@end
