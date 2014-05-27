//
//  Challenge.h
//  GroupSlots
//
//  Created by Joe Gallo on 6/21/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Group;
@class Reward;

@interface Challenge : NSObject <NSCoding>

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) Reward *reward;
@property (strong, nonatomic) NSString *rewardQuantityType;
@property (strong, nonatomic) NSString *playMode;
@property (nonatomic) int currentPoints;
@property (nonatomic) int timeLimit; // in seconds
@property (nonatomic) int numStages;
@property (nonatomic) int currentStage;
@property (nonatomic) BOOL active;
@property (strong, nonatomic) NSDate *activationTime;

- (id)initWithGroup:(Group *)group reward:(Reward *)reward;

@end
