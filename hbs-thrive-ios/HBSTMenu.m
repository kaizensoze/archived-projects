//
//  HBSTMenu.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/12/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTMenu.h"

@implementation HBSTMenu

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.id = [[dict objectForKeyNotNull:@"id"] intValue];
        
        // date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSString *dateString = [dict objectForKeyNotNull:@"date"];
        self.date = [dateFormatter dateFromString:dateString];
        // ---
        
        self.summary = [dict objectForKeyNotNull:@"summary"];
        self.body = [dict objectForKeyNotNull:@"body"];
    }
    return self;
}

// encode
- (void)encodeWithCoder:(NSCoder *)encoder {
    // public
    [encoder encodeInt:self.id forKey:@"id"];
    [encoder encodeObject:self.date forKey:@"date"];
    [encoder encodeObject:self.summary forKey:@"summary"];
    [encoder encodeObject:self.body forKey:@"body"];
}

// decode
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        // public
        self.id = [decoder decodeIntForKey:@"id"];
        self.date = [decoder decodeObjectForKey:@"date"];
        self.summary = [decoder decodeObjectForKey:@"summary"];
        self.body = [decoder decodeObjectForKey:@"body"];
    }
    return self;
}

- (NSString *)displayDate {
    if ([HBSTUtil isToday:self.date]) {
        return @"Today";
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM d, YYYY"];
        return [dateFormatter stringFromDate:self.date];
    }
}

- (NSComparisonResult)compare:(HBSTMenu *)otherObject {
    return self.id == otherObject.id;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"\n"
            "id: %d\n"
            "date: %@\n"
            "summary: %@\n"
            "body: %@\n",
            self.id,
            self.date,
            self.summary,
            self.body
            ];
}

@end
