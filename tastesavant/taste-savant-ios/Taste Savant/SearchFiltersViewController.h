//
//  SearchFilterViewController.h
//  Taste Savant
//
//  Created by Joe Gallo on 12/27/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CuisineFilterViewController.h"
#import "OccasionFilterViewController.h"
#import "NeighborhoodFilterViewController.h"

@class SearchFilters;

@protocol SearchFiltersDelegate
- (void)filter:(SearchFilters *)searchFilters;
- (void)resetFilters;
@end

@interface SearchFiltersViewController : UIViewController <CuisineFilterDelegate, OccasionFilterDelegate, NeighborhoodFilterDelegate>

@property (strong, nonatomic) SearchFilters *searchFilters;
@property id<SearchFiltersDelegate> delegate;

@end
