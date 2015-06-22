//
//  LocationFilterViewController.h
//  Taste Savant
//
//  Created by Joe Gallo on 12/13/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Neighborhood;

@protocol NeighborhoodFilterDelegate
- (void)neighborhoodSelected:(Neighborhood *)neighborhood;
@end

@interface NeighborhoodFilterViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) Neighborhood *selectedNeighborhood;
@property id<NeighborhoodFilterDelegate> delegate;
@property (strong, nonatomic) NSString *referrer;

@end
