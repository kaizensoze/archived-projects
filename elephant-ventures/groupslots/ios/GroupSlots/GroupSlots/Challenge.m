//
//  Challenge.m
//  GroupSlots
//
//  Created by Joe Gallo on 6/21/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "Challenge.h"
#import "Group.h"
#import "Reward.h"
#import <stdlib.h>

@implementation Challenge

- (id)init {
    self = [super init];
    if (self) {
        self.id = [NSNumber numberWithInt:arc4random()];
        self.currentPoints = 0;
        self.currentStage = 1;
    }
    return self;
}

- (id)initWithGroup:(Group *)group reward:(Reward *)reward {
    self = [super init];
    if (self) {
        self.id = [NSNumber numberWithInt:arc4random()];
        self.group = group;
        self.reward = reward;
        self.currentPoints = 0;
        self.currentStage = 1;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)anEncoder {
    [anEncoder encodeObject:self.id forKey:@"id"];
    [anEncoder encodeObject:self.group forKey:@"group"];
    [anEncoder encodeObject:self.reward forKey:@"reward"];
    [anEncoder encodeObject:self.rewardQuantityType forKey:@"rewardQuantityType"];
    [anEncoder encodeObject:self.playMode forKey:@"playMode"];
    [anEncoder encodeInt:self.currentPoints forKey:@"currentPoints"];
    [anEncoder encodeInt:self.timeLimit forKey:@"timeLimit"];
    [anEncoder encodeInt:self.numStages forKey:@"numStages"];
    [anEncoder encodeInt:self.currentStage forKey:@"currentStage"];
    [anEncoder encodeBool:self.active forKey:@"active"];
    [anEncoder encodeObject:self.activationTime forKey:@"activationTime"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.id = [aDecoder decodeObjectForKey:@"id"];
        self.group = [aDecoder decodeObjectForKey:@"group"];
        self.reward = [aDecoder decodeObjectForKey:@"reward"];
        self.rewardQuantityType = [aDecoder decodeObjectForKey:@"rewardQuantityType"];
        self.playMode = [aDecoder decodeObjectForKey:@"playMode"];
        self.currentPoints = [aDecoder decodeIntForKey:@"currentPoints"];
        self.timeLimit = [aDecoder decodeIntForKey:@"timeLimit"];
        self.numStages = [aDecoder decodeIntForKey:@"numStages"];
        self.currentStage = [aDecoder decodeIntForKey:@"currentStage"];
        self.active = [aDecoder decodeBoolForKey:@"active"];
        self.activationTime = [aDecoder decodeObjectForKey:@"activationTime"];
    }
    return self;
}

- (void) setActive:(BOOL)active {
    _active = active;
    if (_active) {
        _activationTime = [NSDate date];
    }
}

- (BOOL)isEqual:(id)other {
    if (self == other) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToChallenge:other];
}

- (BOOL)isEqualToChallenge:(Challenge *)aChallenge {
    if (self == aChallenge)
        return YES;
    
    if (![(id)[self id] isEqual:[aChallenge id]])
        return NO;
    
    return YES;
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [self.id hash];
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"\nGroup: %@\n"
            "Reward: %@\n"
            "Reward quantity type: %@\n"
            "Play mode: %@\n"
            "Current points: %d\n"
            "Time limit: %d\n"
            "Number of stages: %d\n"
            "Current stage: %d\n"
            "Active: %d\n"
            "Activation time: %@\n",
            self.group, self.reward, self.rewardQuantityType, self.playMode, self.currentPoints,
            self.timeLimit, self.numStages, self.currentStage, self.active, self.activationTime];
}

@end
