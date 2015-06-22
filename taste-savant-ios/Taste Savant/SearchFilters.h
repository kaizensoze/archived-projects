//
//  SearchOptions.h
//  Taste Savant
//
//  Created by Joe Gallo on 2/16/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Neighborhood;
@class Cuisine;
@class Occasion;

@interface SearchFilters : NSObject

@property (strong, nonatomic) NSString *keywordText;
@property (strong, nonatomic) Neighborhood *selectedNeighborhood;
@property (strong, nonatomic) Cuisine *selectedCuisine;
@property (strong, nonatomic) NSMutableArray *selectedPrices;
@property (strong, nonatomic) Occasion *selectedOccasion;
@property (strong, nonatomic) NSString *selectedDistance;
@property (strong, nonatomic) NSNumber *selectedDistanceIndex;
@property (strong, nonatomic) NSString *selectedSortBy;
@property (strong, nonatomic) NSNumber *selectedSortByIndex;
@property (nonatomic) BOOL openNow;

- (void)setDistance:(int)distanceIndex;
- (void)setSortBy:(NSInteger)sortIndex;

@end
