//
//  ReviewFormViewController.h
//  Taste Savant
//
//  Created by Joe Gallo on 4/7/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestaurantDelegate.h"
#import "RestaurantInfoDelegate.h"
#import "ReviewDelegate.h"

@interface ReviewFormViewController : UIViewController <RestaurantInfoDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, ReviewDelegate>

@property (strong, nonatomic) Restaurant *restaurant;

@end
