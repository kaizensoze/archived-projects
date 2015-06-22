//
//  RewardFilters.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/9/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "RewardFilters.h"
#import "RewardPointsRange.h"

@implementation RewardFilters

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@", self.pointsRange, self.category];
}

- (id)copyWithZone: (NSZone *)zone {
    RewardFilters *copy = [[[self class] alloc] init];
    [copy setPointsRange:_pointsRange];
    [copy setCategory:_category];
    return copy;
}

@end
