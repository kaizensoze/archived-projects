//
//  RestaurantMenuViewController.h
//  Taste Savant
//
//  Created by Joe Gallo on 5/19/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestaurantInfoDelegate.h"

@class Restaurant;

@interface RestaurantMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, RestaurantInfoDelegate>

@property (strong, nonatomic) Restaurant *restaurant;

@end
