//
//  GroupInvite.h
//  GroupSlots
//
//  Created by Joe Gallo on 6/12/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface GroupInvite : NSObject

@property (strong, nonatomic) User *inviter;
@property (nonatomic) GroupInviteStatus status;


- (id)initWithInviter:(User *)inviter;

@end
