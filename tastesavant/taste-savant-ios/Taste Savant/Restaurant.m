//
//  Restaurant.m
//  Taste Savant
//
//  Created by Joe Gallo on 11/30/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "Restaurant.h"
#import "Review.h"
#import "Occasion.h"
#import "Cuisine.h"
#import "Neighborhood.h"
#import "UserReview.h"
#import "CriticReview.h"
#import "User.h"

@interface Restaurant ()
    @property (strong, nonatomic) NSString *urlPattern;
    @property (nonatomic) BOOL reviewsFinished;
    @property (strong, nonatomic) NSString *nextReviewsBatchUrl;
@end

@implementation Restaurant

@synthesize numReviewsToImport = _numReviewsToImport;
@synthesize numReviewsImported = _numReviewsImported;

- (id)init {
    self = [super init];
    if (self) {
        self.urlPattern = @"%@/restaurants/%@/";
        
        self.numReviewsToImport = 0;
        self.numReviewsImported = 0;
        
        self.includeReviews = YES;
        self.reviewsFinished = NO;
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
}

// Encode.
- (void)encodeWithCoder:(NSCoder *)encoder {
    // Private
    [encoder encodeObject:self.urlPattern forKey:@"urlPattern"];
    [encoder encodeBool:self.reviewsFinished forKey:@"reviewsFinished"];
    [encoder encodeObject:self.nextReviewsBatchUrl forKey:@"nextReviewsBatchUrl"];
    
    // Public
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.slug forKey:@"slug"];
    [encoder encodeObject:self.url forKey:@"url"];
    [encoder encodeObject:self.criticScore forKey:@"criticScore"];
    [encoder encodeObject:self.userScore forKey:@"userScore"];
    [encoder encodeObject:self.friendScore forKey:@"friendScore"];
    [encoder encodeObject:self.price forKey:@"price"];
    [encoder encodeObject:self.hours forKey:@"hours"];
    [encoder encodeObject:self.occasions forKey:@"occasions"];
    [encoder encodeObject:self.cuisines forKey:@"cuisines"];
    [encoder encodeObject:self.externalURL forKey:@"externalURL"];
    [encoder encodeObject:self.openTableURL forKey:@"openTableURL"];
    [encoder encodeObject:self.menuURL forKey:@"menuURL"];
    [encoder encodeObject:self.menuURL forKey:@"hasLocalMenu"];
    [encoder encodeInt:self.hits forKey:@"hits"];
    [encoder encodeObject:self.neighborhoods forKey:@"neighborhoods"];
    [encoder encodeObject:self.location forKey:@"location"];
    [encoder encodeBool:self.isOpen forKey:@"isOpen"];
    [encoder encodeObject:self.phoneNumber forKey:@"phoneNumber"];
    [encoder encodeObject:self.address forKey:@"address"];
    [encoder encodeObject:self.city forKey:@"city"];
    [encoder encodeObject:self.state forKey:@"state"];
    [encoder encodeObject:self.zipCode forKey:@"zipCode"];
    [encoder encodeObject:self.foursquareId forKey:@"foursquareId"];
    [encoder encodeObject:self.singlePlatformId forKey:@"singlePlatformId"];
    [encoder encodeObject:self.seamlessDirectURL forKey:@"seamlessDirectURL"];
    [encoder encodeObject:self.seamlessMobileURL forKey:@"seamlessMobileURL"];
    [encoder encodeObject:self.distance forKey:@"distance"];
    [encoder encodeObject:self.imageURL forKey:@"imageURL"];
    [encoder encodeObject:self.criticReviews forKey:@"criticReviews"];
    [encoder encodeObject:self.userReviews forKey:@"userReviews"];
    [encoder encodeObject:self.friendReviews forKey:@"friendReviews"];
    [encoder encodeObject:self.numReviews forKey:@"numReviews"];
    [encoder encodeObject:self.numCriticReviews forKey:@"numCriticReviews"];
    [encoder encodeObject:self.numUserReviews forKey:@"numUserReviews"];
    [encoder encodeObject:self.numUserReviews forKey:@"numFriendReviews"];
    [encoder encodeObject:self.delegate forKey:@"delegate"];
    [encoder encodeBool:self.includeReviews forKey:@"includeReviews"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        // Private
        self.urlPattern = [decoder decodeObjectForKey:@"urlPattern"];
        self.reviewsFinished = [decoder decodeBoolForKey:@"reviewsFinished"];
        self.nextReviewsBatchUrl = [decoder decodeObjectForKey:@"nextReviewsBatchUrl"];
        
        // Public
        self.name = [decoder decodeObjectForKey:@"name"];
        self.slug = [decoder decodeObjectForKey:@"slug"];
        self.url = [decoder decodeObjectForKey:@"url"];
        self.criticScore = [decoder decodeObjectForKey:@"criticScore"];
        self.userScore = [decoder decodeObjectForKey:@"userScore"];
        self.friendScore = [decoder decodeObjectForKey:@"friendScore"];
        self.price = [decoder decodeObjectForKey:@"price"];
        self.hours = [decoder decodeObjectForKey:@"hours"];
        self.occasions = [decoder decodeObjectForKey:@"occasions"];
        self.cuisines = [decoder decodeObjectForKey:@"cuisines"];
        self.externalURL = [decoder decodeObjectForKey:@"externalURL"];
        self.openTableURL = [decoder decodeObjectForKey:@"openTableURL"];
        self.menuURL = [decoder decodeObjectForKey:@"menuURL"];
        self.hasLocalMenu = [decoder decodeBoolForKey:@"hasLocalMenu"];
        self.hits = [decoder decodeIntForKey:@"hits"];
        self.neighborhoods = [decoder decodeObjectForKey:@"neighborhoods"];
        self.location = [decoder decodeObjectForKey:@"location"];
        self.isOpen = [decoder decodeBoolForKey:@"isOpen"];
        self.phoneNumber = [decoder decodeObjectForKey:@"phoneNumber"];
        self.address = [decoder decodeObjectForKey:@"address"];
        self.city = [decoder decodeObjectForKey:@"city"];
        self.state = [decoder decodeObjectForKey:@"state"];
        self.zipCode = [decoder decodeObjectForKey:@"zipCode"];
        self.foursquareId = [decoder decodeObjectForKey:@"foursquareId"];
        self.singlePlatformId = [decoder decodeObjectForKey:@"singlePlatformId"];
        self.seamlessDirectURL = [decoder decodeObjectForKey:@"seamlessDirectURL"];
        self.seamlessMobileURL = [decoder decodeObjectForKey:@"seamlessMobileURL"];
        self.distance = [decoder decodeObjectForKey:@"distance"];
        self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
        self.criticReviews = [decoder decodeObjectForKey:@"criticReviews"];
        self.userReviews = [decoder decodeObjectForKey:@"userReviews"];
        self.friendReviews = [decoder decodeObjectForKey:@"friendReviews"];
        self.numReviews = [decoder decodeObjectForKey:@"numReviews"];
        self.numCriticReviews = [decoder decodeObjectForKey:@"numCriticReviews"];
        self.numUserReviews = [decoder decodeObjectForKey:@"numUserReviews"];
        self.numFriendReviews = [decoder decodeObjectForKey:@"numFriendReviews"];
        self.delegate = [decoder decodeObjectForKey:@"delegate"];
        self.includeReviews = [decoder decodeBoolForKey:@"includeReviews"];
    }
    return self;
}

- (void)loadFromURL:(NSString *)url {
    [self load:url];
}

- (void)loadFromSlug:(NSString *)slug {
    NSString *url = [NSString stringWithFormat: self.urlPattern, API_URL_PREFIX, slug];
    [self load:url];
}

- (void)load:(NSString *)url {
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"GET" path:url parameters:nil];
//    DDLogInfo(@"%@", url);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        [self import:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

- (void)import:(NSDictionary *)json {
    self.name = [json objectForKeyNotNull:@"name"];
    self.slug = [json objectForKeyNotNull:@"slug"];
    self.url = [NSString stringWithFormat: self.urlPattern, API_URL_PREFIX, self.slug];
    self.criticScore = [json objectForKeyNotNull:@"critics_say"];
    self.userScore = [json objectForKeyNotNull:@"savants_say"];
    self.friendScore = [json objectForKeyNotNull:@"friends_say"];
    self.price = [json objectForKeyNotNull:@"price"];
    self.hours = [json objectForKeyNotNull:@"hours"];
    
    // occasions
    self.occasions = [[NSMutableArray alloc] init];
    for (id occasionDict in [json objectForKeyNotNull:@"occasion"]) {
        Occasion *occasion = [[Occasion alloc] initWithDict:occasionDict];
        [self.occasions addObject:occasion];
    }
    
    // cuisines
    self.cuisines = [[NSMutableArray alloc] init];
    for (id cuisineDict in [json objectForKeyNotNull:@"cuisine"]) {
        Cuisine *cuisine = [[Cuisine alloc] initWithDict:cuisineDict];
        [self.cuisines addObject:cuisine];
    }
    
    self.externalURL = [json objectForKeyNotNull:@"url"];
    self.openTableURL = [json objectForKeyNotNull:@"opentable"];
    self.menuURL = [json objectForKeyNotNull:@"menupages"];
    self.hasLocalMenu = [[json objectForKeyNotNull:@"has_local_menu"] boolValue];
    self.hits = [[json objectForKeyNotNull:@"hits"] intValue];
    
    NSArray *locations = [json objectForKeyNotNull:@"location"];
    if (locations && locations.count > 0) {
        NSDictionary *locationInfo = locations[0];
        
        // neighborhoods
        self.neighborhoods = [[NSMutableArray alloc] init];
        for (id neighborhoodDict in [locationInfo objectForKeyNotNull:@"neighborhood"]) {
            Neighborhood *neighborhood = [[Neighborhood alloc] initWithDict:neighborhoodDict];
            [self.neighborhoods addObject:neighborhood];
        }
        
        // location info
        double lat = [[locationInfo objectForKeyNotNull:@"lat"] doubleValue];
        double lng = [[locationInfo objectForKeyNotNull:@"lng"] doubleValue];
        self.location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
        
        // is open
        self.isOpen = [[json objectForKeyNotNull:@"within_open_hours"] boolValue];
        
        self.phoneNumber = [locationInfo objectForKeyNotNull:@"phone_number"];
        self.address = [locationInfo objectForKeyNotNull:@"address"];
        self.city = [locationInfo objectForKeyNotNull:@"city"];
        self.state = [locationInfo objectForKeyNotNull:@"state"];
        self.zipCode = [locationInfo objectForKeyNotNull:@"zip_code"];
        
        if ([json objectForKeyNotNull:@"distance_in_miles"]) {
            self.distance = [NSNumber numberWithFloat:[[json objectForKeyNotNull:@"distance_in_miles"] floatValue]];
        }
        
        // other stuff
        self.foursquareId = [locationInfo objectForKeyNotNull:@"foursquare_id"];
        self.singlePlatformId = [locationInfo objectForKeyNotNull:@"singleplatform_id"];
        self.seamlessDirectURL = [locationInfo objectForKeyNotNull:@"seamless_direct_url"];
        self.seamlessMobileURL = [locationInfo objectForKeyNotNull:@"seamless_mobile_url"];
    }
    
    if ([[json objectForKeyNotNull:@"image_url"] length] > 0) {
    #if defined(LOCAL) || defined(PLAYGROUND)
        // relative path
        self.imageURL = [NSString stringWithFormat:@"%@/%@", SITE_DOMAIN, [json objectForKeyNotNull:@"image_url"]];
    #else
        // S3 absolute url (PRODUCTION)
        self.imageURL = [json objectForKeyNotNull:@"image_url"];
    #endif
    }
    
    self.nextReviewsBatchUrl = [NSString stringWithFormat: @"%@/restaurants/%@/reviews/?page=1", API_URL_PREFIX, self.slug];
    
    // reviews
    self.numReviews = [json objectForKeyNotNull:@"total_review_count"];
    self.numUserReviews = [json objectForKeyNotNull:@"total_user_review_count"];
    self.numCriticReviews = [json objectForKeyNotNull:@"total_critic_review_count"];
    
    if (self.includeReviews) {
        [self importReviews];
    } else {
        [self signalDelegate];
    }
}

- (void)importReviews {
    if (self.criticReviews == nil) {
        self.criticReviews = [[NSMutableArray alloc] init];
    }
    if (self.userReviews == nil) {
        self.userReviews = [[NSMutableArray alloc] init];
    }
    if (self.friendReviews == nil) {
        self.friendReviews = [[NSMutableArray alloc] init];
    }
    
    NSString *url = self.nextReviewsBatchUrl;
    if (url == nil) {
        self.reviewsFinished = YES;
        [self signalDelegate];
        return;
    }
    
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"GET" path:self.nextReviewsBatchUrl parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        self.nextReviewsBatchUrl = JSON[@"next"];
        
        NSUInteger numReviewsCheck = [JSON[@"results"] count];
        if (numReviewsCheck < 20) {
            self.numReviewsToImport += numReviewsCheck;
        } else {
            self.numReviewsToImport += 20;
        }
        
        if (numReviewsCheck == 0) {
            self.reviewsFinished = YES;
            [self signalDelegate];
            return;
        }
        
        for (id reviewDict in JSON[@"results"]) {
            Review *review;
            if ([reviewDict objectForKeyNotNull:@"user"] != nil) {
                review = [[UserReview alloc] init];
            } else {
                review = [[CriticReview alloc] init];
            }
            review.includeRestaurant = NO;
            review.delegate = self;
            [review import:reviewDict];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

- (void)getNextBatchOfReviews {
    [self importReviews];
}

- (void)reviewDoneLoading:(Review *)review {
    if ([review isKindOfClass:[UserReview class]]) {
        [self.userReviews addObject:review];
        [self checkIfFriendReview:(UserReview *)review];
    } else if ([review isKindOfClass:[CriticReview class]]) {
        [self.criticReviews addObject:review];
    }
    self.numReviewsImported++;
    
    if (self.numReviewsImported >= self.numReviewsToImport) {
        [self.userReviews sortUsingSelector:@selector(compare:)];
        [self.criticReviews sortUsingSelector:@selector(compare:)];
        self.reviewsFinished = YES;
        [self signalDelegate];
    }
}

- (void)checkIfFriendReview:(UserReview *)review {
    if (appDelegate.loggedInUser != nil) {
        if ([appDelegate.loggedInUser.following containsObject:review.user]) {
            [self.friendReviews addObject:review];
            self.numFriendReviews = [NSNumber numberWithInt:[self.numFriendReviews intValue] + 1];
        }
    }
}

- (void)signalDelegate {
    BOOL okToSignal = YES;
    
    if (self.includeReviews) {
        okToSignal &= self.reviewsFinished;
    }
    
    if (okToSignal && self.delegate) {
        [self resetFinishedFlags];
        [self.delegate restaurantDoneLoading:self];
    }
}

- (void)resetFinishedFlags {
    self.reviewsFinished = NO;
}

- (BOOL)isEqualToRestaurant:(Restaurant *)aRestaurant {
    if (self == aRestaurant)
        return YES;
    if (![(id)[self slug] isEqual:[aRestaurant slug]])
        return NO;
    return YES;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToRestaurant:other];
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [self.slug hash];
    return result;
}

- (NSString *)description {
    NSString *result = @"";
    
    result = [result stringByAppendingFormat:
              @"\nName: %@\n"
              "Slug: %@\n"
              "Critic score: %@\n"
              "User score: %@\n"
              "Friend score: %@\n"
              "Price: %@\n"
              "Hours: %@\n"
              "Occasions: %@\n"
              "Cuisines: %@\n"
              "External url: %@\n"
              "Open table url: %@\n"
              "Menu url: %@\n"
              "Has local menu: %d\n"
              "Hits: %d\n"
              "Neighborhoods: %@\n"
              "Location: %@\n"
              "Is open: %d\n"
              "Phone number: %@\n"
              "Address: %@\n"
              "City: %@\n"
              "State: %@\n"
              "Zipcode: %@\n"
              "Foursquare id: %@\n"
              "Single platform id: %@\n"
              "Seamless direct url: %@\n"
              "Seamless mobile url: %@\n"
              "Distance: @%@\n"
              "Image url: %@\n"
              "Delegate: %@\n"
              "Include reviews: %d\n",
              self.name, self.slug, self.criticScore, self.userScore, self.friendScore, self.price, self.hours,
              self.occasions, self.cuisines, self.externalURL, self.openTableURL, self.menuURL, self.hasLocalMenu, self.hits,
              self.neighborhoods, self.location, self.isOpen, self.phoneNumber, self.address, self.city, self.state, self.zipCode,
              self.foursquareId, self.singlePlatformId, self.seamlessDirectURL, self.seamlessMobileURL, self.distance,
              self.imageURL, self.delegate, self.includeReviews];
    
    result = [result stringByAppendingString:@"\nCritic reviews:\n"];
    for (CriticReview *review in self.criticReviews) {
        result = [result stringByAppendingFormat:@"%@\n", review];
    }
    
    result = [result stringByAppendingString:@"\nUser reviews:\n"];
    for (UserReview *review in self.userReviews) {
        result = [result stringByAppendingFormat:@"%@\n", review];
    }
    
    result = [result stringByAppendingString:@"\nFriend reviews:\n"];
    for (UserReview *review in self.friendReviews) {
        result = [result stringByAppendingFormat:@"%@\n", review];
    }
    
    result = [result stringByAppendingString:@"\n"];
    
    return result;
}

@end
