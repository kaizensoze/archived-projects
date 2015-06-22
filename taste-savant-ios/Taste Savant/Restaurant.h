//
//  Restaurant.h
//  Taste Savant
//
//  Created by Joe Gallo on 11/30/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReviewDelegate.h"
#import "RestaurantDelegate.h"

@interface Restaurant : NSObject <ReviewDelegate>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *slug;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSNumber *criticScore;
@property (strong, nonatomic) NSNumber *userScore;
@property (strong, nonatomic) NSNumber *friendScore;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSMutableArray *hours;
@property (strong, nonatomic) NSMutableArray *occasions;
@property (strong, nonatomic) NSMutableArray *cuisines;
@property (strong, nonatomic) NSString *externalURL;
@property (strong, nonatomic) NSString *openTableURL;
@property (strong, nonatomic) NSString *menuURL;
@property (nonatomic) BOOL hasLocalMenu;
@property (nonatomic) int hits;
@property (strong, nonatomic) NSMutableArray *neighborhoods;
@property (strong, nonatomic) CLLocation *location;
@property (nonatomic) BOOL isOpen;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *zipCode;
@property (strong, nonatomic) NSString *foursquareId;
@property (strong, nonatomic) NSString *singlePlatformId;
@property (strong, nonatomic) NSString *seamlessDirectURL;
@property (strong, nonatomic) NSString *seamlessMobileURL;
@property (strong, nonatomic) NSNumber *distance;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSMutableArray *criticReviews;
@property (strong, nonatomic) NSMutableArray *userReviews;
@property (strong, nonatomic) NSMutableArray *friendReviews;
@property (strong, nonatomic) NSNumber *numReviews;
@property (strong, nonatomic) NSNumber *numCriticReviews;
@property (strong, nonatomic) NSNumber *numUserReviews;
@property (strong, nonatomic) NSNumber *numFriendReviews;
@property id<RestaurantDelegate> delegate;
@property (nonatomic) BOOL includeReviews;

- (void)loadFromURL:(NSString *)url;
- (void)loadFromSlug:(NSString *)slug;

- (void)import:(NSDictionary *)json;

- (void)getNextBatchOfReviews;

@end
