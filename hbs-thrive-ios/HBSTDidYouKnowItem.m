//
//  HBSTDidYouKnowItem.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/28/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTDidYouKnowItem.h"

@implementation HBSTDidYouKnowItem

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.subject = [dict objectForKeyNotNull:@"subject"];
        self.title = [dict objectForKeyNotNull:@"title"];
        self.website = [dict objectForKeyNotNull:@"website"];
        self.email = [dict objectForKeyNotNull:@"email"];
        self.phoneNumber = [dict objectForKeyNotNull:@"phone_number"];
    }
    return self;
}

// encode
- (void)encodeWithCoder:(NSCoder *)encoder {
    // public
    [encoder encodeObject:self.subject forKey:@"subject"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.website forKey:@"website"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.phoneNumber forKey:@"phoneNumber"];
}

// decode
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        // public
        self.subject = [decoder decodeObjectForKey:@"subject"];
        self.title = [decoder decodeObjectForKey:@"title"];
        self.website = [decoder decodeObjectForKey:@"website"];
        self.email = [decoder decodeObjectForKey:@"email"];
        self.phoneNumber = [decoder decodeObjectForKey:@"phoneNumber"];
    }
    return self;
}

- (NSComparisonResult)compare:(HBSTDidYouKnowItem *)otherObject {
    return [self.subject isEqualToString:otherObject.subject]
        && [self.title isEqualToString:otherObject.title];
}

- (id)copyWithZone:(NSZone *)zone {
    id copy = [[[self class] alloc] init];
    
    if (copy) {
        [copy setSubject:[self.subject copyWithZone:zone]];
        [copy setTitle:[self.title copyWithZone:zone]];
        [copy setWebsite:[self.website copyWithZone:zone]];
        [copy setEmail:[self.email copyWithZone:zone]];
        [copy setPhoneNumber:[self.phoneNumber copyWithZone:zone]];
    }
    
    return copy;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"\n"
            "subject: %@\n"
            "title: %@\n"
            "website: %@\n"
            "email: %@\n"
            "phoneNumber: %@\n",
            self.subject,
            self.title,
            self.website,
            self.email,
            self.phoneNumber
            ];
}

@end
