//
//  CuisineFilterViewController.h
//  Taste Savant
//
//  Created by Joe Gallo on 12/27/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Cuisine;

@protocol CuisineFilterDelegate
- (void)cuisineSelected:(Cuisine *)cuisine;
@end

@interface CuisineFilterViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property id<CuisineFilterDelegate> delegate;

@end
