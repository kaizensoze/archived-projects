//
//  ReviewDetailViewController.h
//  Taste Savant
//
//  Created by Joe Gallo on 5/12/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CriticDelegate.h"

@interface ReviewDetailViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) Review *review;

@end
