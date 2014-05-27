//
//  TestUser.m
//  GroupSlots
//
//  Created by Joe Gallo on 6/12/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "TestUser.h"
#import "Reward.h"
#import "ActivityLogEvent.h"
#import "InboxMessage.h"
#import "Group.h"
#import "Challenge.h"
#import "GroupInvite.h"

@implementation TestUser

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.playersClubId = @"1234";
    self.username = @"john.smith";
    self.firstName = @"John";
    self.lastName = @"Smith";
    self.email = @"john.smith@gmail.com";
    self.status = @"Gold Playa";
    self.rating = [NSNumber numberWithFloat:5];
    self.imageURL = nil;
    
    [self createAndJoinGroup];
//    [self createChallenge];
    [self addRewards];
    [self addActivityLogEvents];
    [self addInboxMessages];
    [self addGroupInvites];
}

- (void)createAndJoinGroup {
    Group *group = [[Group alloc] initWithName:@"Spider Pigs"];
    [group.members addObjectsFromArray:appDelegate.testUsers.allValues];
//    [group.members addObject:self];
    self.group = group;
}

- (void)createChallenge {
    Reward *reward = appDelegate.testRewards[@"cancun"];
    
    Challenge *challenge = [[Challenge alloc] initWithGroup:self.group reward:reward];
    challenge.rewardQuantityType = @"One per player";
    challenge.playMode = @"Scavenger Hunt";
    challenge.timeLimit = 30*60;
    challenge.numStages = 2;
    
    self.challenge = challenge;
}

- (void)addRewards {
    [self.rewards addObject:appDelegate.testRewards[@"buffet"]];
    [self.rewards addObject:appDelegate.testRewards[@"cabaret"]];
}

- (void)addActivityLogEvents {
    ActivityLogEvent *event = [[ActivityLogEvent alloc] initWithDescription:@"Something happened."];
    [self.activityLog addObject:event];
    
    event = [[ActivityLogEvent alloc] initWithDescription:@"And then something else happened."];
    [self.activityLog addObject:event];
    
    event = [[ActivityLogEvent alloc] initWithDescription:@"That other thing also happened."];
    [self.activityLog addObject:event];
    
    event = [[ActivityLogEvent alloc] initWithDescription:@"This is a very very very very very very very very very very very very long activity event description."];
    [self.activityLog addObject:event];
}

- (void)addInboxMessages {
    InboxMessage *message = [[InboxMessage alloc] initWithMessage:@"Free breakfast on Tuesday from 5am-noon."
                                                         iconPath:@"free-icon.png"];
    [self.inboxMessages addObject:message];
    
    message = [[InboxMessage alloc] initWithMessage:@"Open Bar in the Casbah, Sunday Nite 8-10pm."
                                           iconPath:@"open-icon.png"];
    [self.inboxMessages addObject:message];
    
    message = [[InboxMessage alloc] initWithMessage:@"Congrats your team won! Come claim your Coach Haley Satchel."
                                           iconPath:@"ribbon-icon.png"];
    [self.inboxMessages addObject:message];
    
    message = [[InboxMessage alloc] initWithMessage:@"Happy hour(s) at the Lounge tonight from 4:30pm-7pm!"
                                           iconPath:@"open-icon.png"];
    [self.inboxMessages addObject:message];
    
    message = [[InboxMessage alloc] initWithMessage:@"Come to the Players club to pick up your Dinner vouchers."
                                           iconPath:@"ribbon-icon.png"];
    [self.inboxMessages addObject:message];
    
    message = [[InboxMessage alloc] initWithMessage:@"Free breakfast on Thursday from 5am-noon."
                                           iconPath:@"free-icon.png"];
    [self.inboxMessages addObject:message];
}

- (void)addGroupInvites {
    User *inviter;
    GroupInvite* groupInvite;
    
    inviter = [[User alloc] initWithUsername:@"kim.martin" firstName:@"Kim" lastName:@"Martin"];
    inviter.group = [[Group alloc] initWithName:@"High Rollers"];
    groupInvite = [[GroupInvite alloc] initWithInviter:inviter];
    [self.groupInvites addObject:groupInvite];
    
    inviter = [[User alloc] initWithUsername:@"steph.griffin" firstName:@"Steph" lastName:@"Griffin"];
    inviter.group = [[Group alloc] initWithName:@"French Toast Mafia"];
    groupInvite = [[GroupInvite alloc] initWithInviter:inviter];
    [self.groupInvites addObject:groupInvite];
}

@end
