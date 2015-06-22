//
//  HBSTHelpNowItem.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/28/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTHelpNowItem.h"

@implementation HBSTHelpNowItem

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.title = [dict objectForKeyNotNull:@"title"];
        self.body = [dict objectForKeyNotNull:@"body"];
        self.phoneNumber = [dict objectForKeyNotNull:@"phone_number"];
    }
    return self;
}

// encode
- (void)encodeWithCoder:(NSCoder *)encoder {
    // public
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.body forKey:@"body"];
    [encoder encodeObject:self.phoneNumber forKey:@"phoneNumber"];
}

// decode
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        // public
        self.title = [decoder decodeObjectForKey:@"title"];
        self.body = [decoder decodeObjectForKey:@"body"];
        self.phoneNumber = [decoder decodeObjectForKey:@"phoneNumber"];
    }
    return self;
}

- (NSComparisonResult)compare:(HBSTHelpNowItem *)otherObject {
    return [self.title isEqualToString:otherObject.title];
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"\n"
            "title: %@\n"
            "body: %@\n"
            "phoneNumber: %@\n",
            self.title,
            self.body,
            self.phoneNumber
            ];
}

@end
