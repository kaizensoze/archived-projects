//
//  TestModel.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/15/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "User.h"
#import "Group.h"
#import "Challenge.h"

@implementation User

- (id)init {
    self = [super init];
    if (self) {
        self.searchableByName = YES;
    }
    return self;
}

- (id)initWithUsername:(NSString *)username firstName:(NSString *)firstName lastName:(NSString *)lastName {
    self = [self init];
    if (self) {
        self.username = username;
        self.firstName = firstName;
        self.lastName = lastName;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)anEncoder {
    [anEncoder encodeObject:self.playersClubId forKey:@"playersClubId"];
    [anEncoder encodeObject:self.username forKey:@"username"];
    [anEncoder encodeObject:self.firstName forKey:@"firstName"];
    [anEncoder encodeObject:self.lastName forKey:@"lastName"];
    [anEncoder encodeObject:self.email forKey:@"email"];
    [anEncoder encodeObject:self.status forKey:@"status"];
    [anEncoder encodeObject:self.rating forKey:@"rating"];
    [anEncoder encodeObject:self.imageURL forKey:@"imageURL"];
    [anEncoder encodeObject:self.facebookId forKey:@"facebookId"];
    [anEncoder encodeObject:[NSNumber numberWithBool:self.searchableByName] forKey:@"searchableByName"];
    [anEncoder encodeObject:self.group forKey:@"group"];
    [anEncoder encodeObject:self.challenge forKey:@"challenge"];
    [anEncoder encodeObject:self.rewards forKey:@"rewards"];
    [anEncoder encodeObject:self.friends forKey:@"friends"];
    [anEncoder encodeObject:self.activityLog forKey:@"activityLog"];
    [anEncoder encodeObject:self.inboxMessages forKey:@"inboxMessages"];
    [anEncoder encodeObject:self.groupInvites forKey:@"groupInvites"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.playersClubId = [aDecoder decodeObjectForKey:@"playersClubId"];
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.firstName = [aDecoder decodeObjectForKey:@"firstName"];
        self.lastName = [aDecoder decodeObjectForKey:@"lastName"];
        self.email = [aDecoder decodeObjectForKey:@"email"];
        self.status = [aDecoder decodeObjectForKey:@"status"];
        self.rating = [aDecoder decodeObjectForKey:@"rating"];
        self.imageURL = [aDecoder decodeObjectForKey:@"imageURL"];
        self.facebookId = [aDecoder decodeObjectForKey:@"facebookId"];
        self.searchableByName = [[aDecoder decodeObjectForKey:@"searchableByName"] boolValue];
        self.group = [aDecoder decodeObjectForKey:@"group"];
        self.challenge = [aDecoder decodeObjectForKey:@"challenge"];
        self.rewards = [aDecoder decodeObjectForKey:@"rewards"];
        self.friends = [aDecoder decodeObjectForKey:@"friends"];
        self.activityLog = [aDecoder decodeObjectForKey:@"activityLog"];
        self.inboxMessages = [aDecoder decodeObjectForKey:@"inboxMessages"];
        self.groupInvites = [aDecoder decodeObjectForKey:@"groupInvites"];
    }
    return self;
}

- (NSMutableArray *)rewards {
    if (!_rewards) {
        _rewards = [[NSMutableArray alloc] init];
    }
    return _rewards;
}

- (NSMutableArray *)friends {
    if (!_friends) {
        _friends = [[NSMutableArray alloc] init];
    }
    return _friends;
}

- (NSMutableArray *)activityLog {
    if (!_activityLog) {
        _activityLog = [[NSMutableArray alloc] init];
    }
    return _activityLog;
}

- (NSMutableArray *)inboxMessages {
    if (!_inboxMessages) {
        _inboxMessages = [[NSMutableArray alloc] init];
    }
    return _inboxMessages;
}

- (NSMutableArray *)groupInvites {
    if (!_groupInvites) {
        _groupInvites = [[NSMutableArray alloc] init];
    }
    return _groupInvites;
}

- (NSString *)name {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

- (NSString *)shortName {
    return [Util shortName:self.firstName lastName:self.lastName];
}

- (NSComparisonResult)compare:(User *)aUser {
    return [self.name compare:aUser.name];
}

- (BOOL)isEqual:(id)other {
    if (self == other) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToUser:other];
}

- (BOOL)isEqualToUser:(User *)aUser {
    if (self == aUser)
        return YES;
    
    if (![(id)[self username] isEqual:[aUser username]])
        return NO;
    
    return YES;
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [self.username hash];
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"\nPlayers Club Id: %@\n"
            "Username: %@\n"
            "First name: %@\n"
            "Last name: %@\n"
            "Email: %@\n"
            "Status: %@\n"
            "Rating: %@\n"
            "Image url: %@\n"
            "Facebook Id: %@\n"
            "Searchable by name: %@\n"
            "Group: %@\n"
            "Challenge: %@\n"
            "Rewards: %@\n"
            "Friends: %@\n"
            "Activity log: %@\n"
            "Inbox messages: %@\n"
            "Group invites: %@\n",
            self.playersClubId, self.username, self.firstName, self.lastName, self.email, self.status, self.rating,
            self.imageURL, self.facebookId, [NSNumber numberWithBool:self.searchableByName], self.group,
            self.challenge, self.rewards, self.friends, self.activityLog, self.inboxMessages, self.groupInvites];
}

@end
