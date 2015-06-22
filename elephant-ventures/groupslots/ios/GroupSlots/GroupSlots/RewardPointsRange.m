//
//  RewardPointsRange.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/10/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "RewardPointsRange.h"

@interface RewardPointsRange ()
    @property (nonatomic) NSRange pointsRange;
@end

@implementation RewardPointsRange

- (id)initWithMin:(NSNumber *)minValue max:(NSNumber *)maxValue {
    self = [super init];
    if (self) {
        self.minValue = minValue;
        self.maxValue = maxValue;
        self.pointsRange = NSMakeRange([self.minValue intValue], [self.maxValue intValue] - [self.minValue intValue]);
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%d-%d", [self.minValue intValue], [self.maxValue intValue]];
}

@end
