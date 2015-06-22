//
//  GroupInviteBumpViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 6/20/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "GroupInviteBumpViewController.h"
#import "User.h"

@interface GroupInviteBumpViewController ()
    @property (strong, nonatomic) BumpAPI *bumpObject;
    @property (strong, nonatomic) UIViewController *parentController;
@end

@implementation GroupInviteBumpViewController

- (id)initWithParent:(UIViewController *)parentController {
    self = [super init];
    if (self) {
        self.parentController = parentController;
        [self configureBump];
        
    }
    return self;
}

- (void)configureBump {
    self.bumpObject = [BumpAPI sharedInstance];
    [self.bumpObject configAPIKey:@"447aae24584e4853a5f7a9641a5ced3a"];
    [self.bumpObject configDelegate:self];
    [self.bumpObject configParentView:self.parentController.view];
    [self.bumpObject configUserName: appDelegate.loggedInUser.username];
}

- (void)startBumpSession {
    [self.bumpObject requestSession];
}

- (void)endBumpSession {
    [self.bumpObject endSession];
}

- (void) bumpSessionStartedWith:(Bumper*)otherBumper {
    NSString *otherUsername = [[self.bumpObject otherBumper] userName];
    [self inviteToGroup:otherUsername];
}

- (void)inviteToGroup:(NSString *)username {
    #warning TODO: get user object from username
    #warning TODO: try to invite them and go through the different cases
    // (!inGroup-!inGroup, !inGroup-inGroup, inGroup-!inGroup, inGroup-inGroup)
    DDLogInfo(@"Inviting to group.");
}

- (void) bumpDataReceived:(NSData *)chunk {
}

- (void) bumpSessionEnded:(BumpSessionEndReason)reason {
}

- (void) bumpSessionFailedToStart:(BumpSessionStartFailedReason)reason {
}

@end
