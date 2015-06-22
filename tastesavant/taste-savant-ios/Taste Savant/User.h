//
//  Profile.h
//  Taste Savant
//
//  Created by Joe Gallo on 11/19/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReviewDelegate.h"
#import "ProfileDelegate.h"

@interface User : NSObject <NSCoding, ReviewDelegate>

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *shortName;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *birthday;
@property (strong, nonatomic) NSString *zipcode;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *typeExpert;
@property (strong, nonatomic) NSString *reviewerType;
@property (strong, nonatomic) NSString *favoriteFood;
@property (strong, nonatomic) NSString *favoriteRestaurant;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) NSString *reviewsURL;
@property (strong, nonatomic) NSString *followingURL;
@property (strong, nonatomic) NSString *followersURL;
@property (strong, nonatomic) NSString *suggestionsURL;

@property (strong, nonatomic) NSMutableArray *reviews;
@property (nonatomic) NSInteger numReviews;
@property (strong, nonatomic) NSMutableArray *following;
@property (strong, nonatomic) NSMutableArray *followers;
@property (strong, nonatomic) NSMutableDictionary *suggestions;

@property (strong, nonatomic) NSString *followURL;
@property (strong, nonatomic) NSString *unfollowURL;

@property id<ProfileDelegate> delegate;

@property (nonatomic) BOOL includeReviews;
@property (nonatomic) BOOL includeFollowingFollowers;

@property (nonatomic) BOOL viaSocialAuth;

- (NSString *)genderDisplay;
- (NSString *)reviewerTypeDisplay;
- (BOOL)isEmpty;
- (BOOL)missingRequiredInfo;

- (void)loadFromUsername:(NSString *)username;
- (void)loadFromURL:(NSString *)url;

- (void)import:(NSDictionary *)json;

- (void)getNextBatchOfReviews;

@end
