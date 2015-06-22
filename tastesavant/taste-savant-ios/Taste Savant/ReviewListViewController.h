//
//  ReviewListViewController.h
//  Taste Savant
//
//  Created by Joe Gallo on 2/3/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileDelegate.h"
#import "RestaurantDelegate.h"
#import "CriticDelegate.h"

@class Critic;
@class User;
@class Restaurant;

@interface ReviewListViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, ProfileDelegate, RestaurantDelegate, CriticDelegate>

@property (strong, nonatomic) Critic *critic;
@property (strong, nonatomic) User *profile;
@property (strong, nonatomic) Restaurant *restaurant;
@property (strong, nonatomic) NSString *restaurantReviewType;

@end
