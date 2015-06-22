//
//  RewardPointsRange.h
//  GroupSlots
//
//  Created by Joe Gallo on 5/10/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RewardPointsRange : NSObject

@property (strong, nonatomic) NSNumber *minValue;
@property (strong, nonatomic) NSNumber *maxValue;

- (id)initWithMin:(NSNumber *)minValue max:(NSNumber *)maxValue;

@end
