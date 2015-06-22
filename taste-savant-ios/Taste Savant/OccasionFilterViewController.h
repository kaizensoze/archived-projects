//
//  OccasionFilterViewController.h
//  Taste Savant
//
//  Created by Joe Gallo on 12/27/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Occasion;

@protocol OccasionFilterDelegate
- (void)occasionSelected:(Occasion *)occasion;
@end

@interface OccasionFilterViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property id<OccasionFilterDelegate> delegate;

@end
