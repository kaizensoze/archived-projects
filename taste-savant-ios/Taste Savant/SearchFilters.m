//
//  SearchOptions.m
//  Taste Savant
//
//  Created by Joe Gallo on 2/16/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "SearchFilters.h"
#import "Neighborhood.h"
#import "Cuisine.h"
#import "Occasion.h"

@interface SearchFilters ()
    @property (strong, nonatomic) NSArray *sortOptions;
    @property (strong, nonatomic) NSArray *distanceOptions;
@end

@implementation SearchFilters

- (id)init {
    self = [super init];
    if (self) {
        self.sortOptions = @[@"distance_in_miles", @"-critics_say", @"-savants_say", @"-friends_say", @"name"];
        [self setSortBy:0];
        
        self.distanceOptions = @[@"0.1", @"0.5", @"1", @"5"];
        [self setDistance:-1];
    }
    return self;
}

- (NSMutableArray *)selectedPrices {
    if (!_selectedPrices) {
        _selectedPrices = [[NSMutableArray alloc] init];
    }
    return _selectedPrices;
}

- (void)setSortBy:(NSInteger)sortIndex {
    @try {
        self.selectedSortBy = self.sortOptions[sortIndex];
        self.selectedSortByIndex = [NSNumber numberWithInteger:sortIndex];
    }
    @catch (NSException *e) {
    }
}

- (void)setDistance:(int)distanceIndex {
    if (distanceIndex == -1) {
        self.selectedDistance = nil;
    } else {
        self.selectedDistance = self.distanceOptions[distanceIndex];
    }
    self.selectedDistanceIndex = [NSNumber numberWithInt:distanceIndex];
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"\nKeyword(s): %@\n"
            "Neighborhood: %@\n"
            "Cuisine: %@\n"
            "Prices: %@\n"
            "Occasion: %@\n"
            "Distance: %@\n"
            "Open Now: %d\n"
            "Sort by: %@\n",
            self.keywordText, self.selectedNeighborhood, self.selectedCuisine, self.selectedPrices, self.selectedOccasion,
            self.selectedDistance, self.openNow, self.selectedSortBy];
}

@end
