//
//  RestaurantViewController.h
//  Taste Savant
//
//  Created by Joe Gallo on 4/27/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestaurantDelegate.h"
#import "RestaurantInfoDelegate.h"

@interface RestaurantViewController : UIViewController <RestaurantDelegate, RestaurantInfoDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSString *restaurantId;

@end
