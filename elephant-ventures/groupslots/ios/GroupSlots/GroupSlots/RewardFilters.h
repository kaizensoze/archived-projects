//
//  RewardFilters.h
//  GroupSlots
//
//  Created by Joe Gallo on 5/9/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RewardPointsRange;

@interface RewardFilters : NSObject

@property (strong, nonatomic) RewardPointsRange *pointsRange;
@property (strong, nonatomic) NSString *category;

@end
