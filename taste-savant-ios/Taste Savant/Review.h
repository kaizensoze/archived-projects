//
//  Review.h
//  Taste Savant
//
//  Created by Joe Gallo on 11/30/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestaurantDelegate.h"
#import "ReviewDelegate.h"

@interface Review : NSObject <NSCoding, RestaurantDelegate>

@property (nonatomic) int reviewId;
@property (strong, nonatomic) Restaurant *restaurant;
@property (strong, nonatomic) NSMutableArray *goodDishes;
@property (strong, nonatomic) NSMutableArray *badDishes;
@property (strong, nonatomic) NSNumber *runWalkDitch;
@property (nonatomic) BOOL active;
@property (strong, nonatomic) NSDate *publishDate;
@property (strong, nonatomic) NSString *summary;
@property id<ReviewDelegate> delegate;
@property (nonatomic) BOOL includeRestaurant;
@property (nonatomic) BOOL restaurantFinished;
@property (nonatomic) BOOL okToSignal;
@property (strong, nonatomic) NSNumber *score;
@property (strong, nonatomic) NSString *reviewerName;
@property (strong, nonatomic) NSString *reviewText;

- (void)import:(NSDictionary *)json;
- (void)import:(NSDictionary *)json restaurantDelegate:(id<RestaurantDelegate>)delegate;
- (void)setRunWalkDitchValue;
- (void)resetFinishedFlags;

@end
