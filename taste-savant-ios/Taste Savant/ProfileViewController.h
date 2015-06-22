//
//  ProfileViewController.h
//  Taste Savant
//
//  Created by Joe Gallo on 10/26/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileDelegate.h"
#import "ProfileEditViewController.h"
#import "CriticDelegate.h"

@class Critic;

@interface ProfileViewController : UIViewController <ProfileDelegate, CriticDelegate, ProfileEditDelegate, UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate, NSLayoutManagerDelegate>

@property (strong, nonatomic) NSString *requestedProfileId;
@property (strong, nonatomic) NSString *requestedCriticId;
@property (strong, nonatomic) User *profile;
@property (strong, nonatomic) Critic *critic;
@property (nonatomic) BOOL editProfile;

@end
