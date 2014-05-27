//
//  TestModel.h
//  GroupSlots
//
//  Created by Joe Gallo on 5/15/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Group;
@class Challenge;

@interface User : NSObject <NSCoding>

@property (strong, nonatomic) NSString *playersClubId;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *shortName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSNumber *rating;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSString *facebookId;
@property (nonatomic) BOOL searchableByName;
@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) Challenge *challenge;
@property (strong, nonatomic) NSMutableArray *rewards;
@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) NSMutableArray *activityLog;
@property (strong, nonatomic) NSMutableArray *inboxMessages;
@property (strong, nonatomic) NSMutableArray *groupInvites;

- (id)initWithUsername:(NSString *)username firstName:(NSString *)firstName lastName:(NSString *)lastName;
- (NSString *)name;

@end
