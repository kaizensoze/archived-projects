//
//  Reward.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/7/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "Reward.h"

@implementation Reward

- (id)init {
    self = [super init];
    if (self) {
        self.details = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. In pellentesque erat non ipsum"
                       @" dapibus, eu porttitor odio molestie.";
        self.terms = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. In pellentesque erat non ipsum"
                     @" dapibus, eu porttitor odio molestie.";
        self.redemptionCode = @"1ZAW84DKF";
    }
    return self;
}

- (id)initWithName:(NSString *)name category:(NSString *)category points:(int)points {
    self = [self init];
    if (self) {
        self.name = name;
        self.category = category;
        self.points = points;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)anEncoder {
    [anEncoder encodeObject:self.name forKey:@"name"];
    [anEncoder encodeObject:self.category forKey:@"category"];
    [anEncoder encodeInt:self.points forKey:@"points"];
    [anEncoder encodeObject:self.details forKey:@"details"];
    [anEncoder encodeObject:self.terms forKey:@"terms"];
    [anEncoder encodeObject:self.imageURL forKey:@"imageURL"];
    [anEncoder encodeObject:self.redemptionCode forKey:@"redemptionCode"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.category = [aDecoder decodeObjectForKey:@"category"];
        self.points = [aDecoder decodeIntForKey:@"points"];
        self.details = [aDecoder decodeObjectForKey:@"details"];
        self.terms = [aDecoder decodeObjectForKey:@"terms"];
        self.imageURL = [aDecoder decodeObjectForKey:@"imageURL"];
        self.redemptionCode = [aDecoder decodeObjectForKey:@"redemptionCode"];
    }
    return self;
}

- (NSString *)formattedPoints {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter stringFromNumber:[NSNumber numberWithInt:self.points]];
}

- (BOOL)isEqual:(id)other {
    if (self == other) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToReward:other];
}

- (BOOL)isEqualToReward:(Reward *)aReward {
    if (self == aReward)
        return YES;
    
    if (![(id)[self name] isEqual:[aReward name]])
        return NO;
    
    return YES;
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [self.name hash];
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"\nName: %@\n"
            "Category: %@\n"
            "Points: %d\n"
            "Details: %@\n"
            "Terms: %@\n"
            "ImageURL: %@\n"
            "Redemption Code: %@",
            self.name, self.category, self.points, self.details, self.terms, self.imageURL, self.redemptionCode];
}

@end
