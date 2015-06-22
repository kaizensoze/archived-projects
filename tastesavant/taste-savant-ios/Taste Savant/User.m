//
//  Profile.m
//  Taste Savant
//
//  Created by Joe Gallo on 11/19/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "User.h"
#import "Review.h"
#import "UserReview.h"

@interface User ()
    @property (strong, nonatomic) NSString *urlPattern;
    @property (nonatomic) BOOL reviewsFinished;
    @property (nonatomic) BOOL followingFinished;
    @property (nonatomic) BOOL followersFinished;
    @property (nonatomic) BOOL suggestionsFinished;
    @property (strong, nonatomic) NSString *nextReviewsBatchUrl;
@end

@implementation User

@synthesize numReviewsToImport = _numReviewsToImport;
@synthesize numReviewsImported = _numReviewsImported;

- (id)init {
    self = [super init];
    if (self) {
        self.urlPattern = @"%@/users/%@/";
        
        self.numReviewsToImport = 0;
        self.numReviewsImported = 0;
        
        self.includeFollowingFollowers = YES;
        self.includeReviews = YES;
        
        self.viaSocialAuth = NO;
        
        self.followingFinished = NO;
        self.followersFinished = NO;
        self.suggestionsFinished = NO;
        self.reviewsFinished = NO;
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    // Private
    [encoder encodeObject:self.urlPattern forKey:@"urlPattern"];
    [encoder encodeBool:self.followingFinished forKey:@"followingFinished"];
    [encoder encodeBool:self.followersFinished forKey:@"followersFinished"];
    [encoder encodeBool:self.suggestionsFinished forKey:@"suggestionsFinished"];
    [encoder encodeBool:self.reviewsFinished forKey:@"reviewsFinished"];
    [encoder encodeObject:self.nextReviewsBatchUrl forKey:@"nextReviewsBatchUrl"];
    
    // Public
    [encoder encodeObject:self.username forKey:@"username"];
    [encoder encodeObject:self.url forKey:@"url"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.firstName forKey:@"firstName"];
    [encoder encodeObject:self.lastName forKey:@"lastName"];
    [encoder encodeObject:self.gender forKey:@"gender"];
    [encoder encodeObject:self.birthday forKey:@"birthday"];
    [encoder encodeObject:self.zipcode forKey:@"zipcode"];
    [encoder encodeObject:self.location forKey:@"location"];
    [encoder encodeObject:self.typeExpert forKey:@"typeExpert"];
    [encoder encodeObject:self.reviewerType forKey:@"reviewerType"];
    [encoder encodeObject:self.favoriteFood forKey:@"favoriteFood"];
    [encoder encodeObject:self.favoriteRestaurant forKey:@"favoriteRestaurant"];
    [encoder encodeObject:self.imageURL forKey:@"imageURL"];
    [encoder encodeObject:self.image forKey:@"imageLocal"];
    [encoder encodeObject:self.followingURL forKey:@"followingURL"];
    [encoder encodeObject:self.followersURL forKey:@"followersURL"];
    [encoder encodeObject:self.suggestionsURL forKey:@"suggestionsURL"];
    [encoder encodeObject:self.reviewsURL forKey:@"reviewsURL"];
    [encoder encodeObject:self.followURL forKey:@"followURL"];
    [encoder encodeObject:self.unfollowURL forKey:@"unfollowURL"];
    [encoder encodeObject:self.following forKey:@"following"];
    [encoder encodeObject:self.followers forKey:@"followers"];
    [encoder encodeObject:self.suggestions forKey:@"suggestions"];
    [encoder encodeObject:self.reviews forKey:@"reviews"];
    [encoder encodeInteger:self.numReviews forKey:@"numReviews"];
    [encoder encodeBool:self.includeFollowingFollowers forKey:@"includeFollowingFollowers"];
    [encoder encodeBool:self.includeReviews forKey:@"includeReviews"];
    [encoder encodeBool:self.viaSocialAuth forKey:@"viaSocialAuth"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        // Private
        self.urlPattern = [decoder decodeObjectForKey:@"urlPattern"];
        self.followingFinished = [decoder decodeBoolForKey:@"followingFinished"];
        self.followingFinished = [decoder decodeBoolForKey:@"followersFinished"];
        self.suggestionsFinished = [decoder decodeBoolForKey:@"suggestionsFinished"];
        self.followingFinished = [decoder decodeBoolForKey:@"reviewsFinished"];
        self.nextReviewsBatchUrl = [decoder decodeObjectForKey:@"nextReviewsBatchUrl"];
        
        // Public
        self.username = [decoder decodeObjectForKey:@"username"];
        self.url = [decoder decodeObjectForKey:@"url"];
        self.email = [decoder decodeObjectForKey:@"email"];
        self.firstName = [decoder decodeObjectForKey:@"firstName"];
        self.lastName = [decoder decodeObjectForKey:@"lastName"];
        self.gender = [decoder decodeObjectForKey:@"gender"];
        self.birthday = [decoder decodeObjectForKey:@"birthday"];
        self.zipcode = [decoder decodeObjectForKey:@"zipcode"];
        self.location = [decoder decodeObjectForKey:@"location"];
        self.typeExpert = [decoder decodeObjectForKey:@"typeExpert"];
        self.reviewerType = [decoder decodeObjectForKey:@"reviewerType"];
        self.favoriteFood = [decoder decodeObjectForKey:@"favoriteFood"];
        self.favoriteRestaurant = [decoder decodeObjectForKey:@"favoriteRestaurant"];
        self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
        self.image = [decoder decodeObjectForKey:@"imageLocal"];
        self.followingURL = [decoder decodeObjectForKey:@"followingURL"];
        self.followersURL = [decoder decodeObjectForKey:@"followersURL"];
        self.suggestionsURL = [decoder decodeObjectForKey:@"suggestionsURL"];
        self.reviewsURL = [decoder decodeObjectForKey:@"reviewsURL"];
        self.followURL = [decoder decodeObjectForKey:@"followURL"];
        self.unfollowURL = [decoder decodeObjectForKey:@"unfollowURL"];
        self.following = [decoder decodeObjectForKey:@"following"];
        self.followers = [decoder decodeObjectForKey:@"followers"];
        self.suggestions = [decoder decodeObjectForKey:@"suggestions"];
        self.reviews = [decoder decodeObjectForKey:@"reviews"];
        self.numReviews = [decoder decodeIntegerForKey:@"numReviews"];
        self.includeFollowingFollowers = [decoder decodeBoolForKey:@"includeFollowingFollowers"];
        self.includeReviews = [decoder decodeBoolForKey:@"includeReviews"];
        self.viaSocialAuth = [decoder decodeBoolForKey:@"viaSocialAuth"];
    }
    return self;
}

#pragma mark - Load

- (void)loadFromURL:(NSString *)url {
    [self load:url];
}

- (void)loadFromUsername:(NSString *)username {
    NSString *profileURL = [NSString stringWithFormat: self.urlPattern, API_URL_PREFIX, username];
    [self load:profileURL];
}

- (void)load:(NSString *)url {
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"GET" path:url parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        [self import:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

#pragma mark - Import

- (void)import:(NSDictionary *)json {
    self.username = [json objectForKeyNotNull:@"username"];
    self.url = [NSString stringWithFormat: self.urlPattern, API_URL_PREFIX, self.username];
    self.email = [json objectForKeyNotNull:@"email"];
    self.firstName = [json objectForKeyNotNull:@"first_name"];
    self.lastName = [json objectForKeyNotNull:@"last_name"];
    self.gender = [json objectForKeyNotNull:@"gender"];
    self.birthday = [json objectForKeyNotNull:@"birthday"];
    self.zipcode = [json objectForKeyNotNull:@"zipcode"];
    self.location = [json objectForKeyNotNull:@"location"];
    self.typeExpert = [json objectForKeyNotNull:@"type_expert"];
    self.reviewerType = [json objectForKeyNotNull:@"type_reviewer"];
    self.favoriteFood = [json objectForKeyNotNull:@"favorite_food"];
    self.favoriteRestaurant = [json objectForKeyNotNull:@"favorite_restaurant"];
    
#if defined(LOCAL) || defined(PLAYGROUND)
    // relative path
    self.imageURL = [json objectForKeyNotNull:@"avatar"] ? [NSString stringWithFormat:@"%@%@", SITE_DOMAIN, [json objectForKeyNotNull:@"avatar"]] : nil;
#else
    // S3 absolute url (PRODUCTION)
    self.imageURL = [json objectForKeyNotNull:@"avatar"];
#endif
    
    self.followingURL = [json objectForKeyNotNull:@"following"];
    self.followersURL = [json objectForKeyNotNull:@"followers"];
    self.suggestionsURL = [json objectForKeyNotNull:@"suggestions"];
    self.reviewsURL = [json objectForKeyNotNull:@"reviews"];
    self.numReviews = [[json objectForKeyNotNull:@"total_review_count"] intValue];
    self.followURL = [json objectForKeyNotNull:@"follow"];
    self.unfollowURL = [json objectForKeyNotNull:@"unfollow"];
    self.nextReviewsBatchUrl = [NSString stringWithFormat: @"%@/users/%@/reviews/?page=1", API_URL_PREFIX, self.username];
    
    if (self.includeReviews) {
        [self importReviews];
    }
    
    if (self.includeFollowingFollowers) {
        [self importFollowing];
        [self importFollowers];
        [self importSuggestions];
    }
    
    if (!(self.includeFollowingFollowers && self.includeReviews)) {
        [self signalDelegate];
    }
}

- (void)importReviews {
    if (self.reviews == nil) {
        self.reviews = [[NSMutableArray alloc] init];
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
        self.numReviewsToImport += numReviewsCheck;
        
        if (numReviewsCheck == 0) {
            self.reviewsFinished = YES;
            [self signalDelegate];
            return;
        }
        
        for (id reviewDict in JSON[@"results"]) {
            UserReview *review = [[UserReview alloc] init];
            review.includeUser = NO;
            review.delegate = self;
            [review import:reviewDict];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

- (void)importFollowing {
    if (self.following == nil) {
        self.following = [[NSMutableArray alloc] init];
    }
    
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"GET" path:self.followingURL parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        for (id profileDict in JSON) {
            User *profile = [[User alloc] init];
            profile.includeFollowingFollowers = NO;
            profile.includeReviews = NO;
            [profile import:profileDict];
            [self.following addObject:profile];
        }
        self.followingFinished = YES;
        [self signalDelegate];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

- (void)importFollowers {
    if (self.followers == nil) {
        self.followers = [[NSMutableArray alloc] init];
    }
    
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"GET" path:self.followersURL parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        for (id profileDict in JSON) {
            User *profile = [[User alloc] init];
            profile.includeFollowingFollowers = NO;
            profile.includeReviews = NO;
            [profile import:profileDict];
            [self.followers addObject:profile];
        }
        self.followersFinished = YES;
        [self signalDelegate];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

- (void)importSuggestions {
    if (self.suggestions == nil) {
        self.suggestions = [[NSMutableDictionary alloc] init];
    }
    
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"GET" path:self.suggestionsURL parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        for (id suggestionType in JSON) {
            NSArray *suggestionTypeProfiles = JSON[suggestionType];
            NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
            for (id suggestionTypeProfileDict in suggestionTypeProfiles) {
                User *profile = [[User alloc] init];
                profile.includeFollowingFollowers = NO;
                profile.includeReviews = NO;
                [profile import:suggestionTypeProfileDict];
                [tmpArray addObject:profile];
            }
            [self.suggestions setObject:tmpArray forKey:suggestionType];
        }
        
        self.suggestionsFinished = YES;
        [self signalDelegate];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

#pragma mark - ReviewDelegate

- (void)reviewDoneLoading:(Review *)review {
    [self.reviews addObject:review];
    self.numReviewsImported++;
    
    if (self.numReviewsImported >= self.numReviewsToImport) {
        [self.reviews sortUsingSelector:@selector(compare:)];
        self.reviewsFinished = YES;
        [self signalDelegate];
    }
}

- (void)getNextBatchOfReviews {
    self.followingFinished = YES;
    self.followersFinished = YES;
    self.suggestionsFinished = YES;
    [self importReviews];
}

#pragma mark - Signal delegate

- (void)signalDelegate {
    BOOL okToSignal = YES;
    
    if (self.includeReviews) {
        okToSignal &= self.reviewsFinished;
    }
    
    if (self.includeFollowingFollowers) {
        okToSignal &= self.followingFinished && self.followersFinished && self.suggestionsFinished;
    }
    
    if (okToSignal && self.delegate) {
        [self resetFinishedFlags];
        [self.delegate profileDoneLoading:self];
    }
}

- (void)resetFinishedFlags {
    self.followingFinished = NO;
    self.followersFinished = NO;
    self.suggestionsFinished = NO;
    self.reviewsFinished = NO;
}

#pragma mark - Custom accessors

- (NSString *)shortName {
    NSString *shortie = [Util getShortName:_firstName lastName:_lastName];
    if ([Util isEmpty:shortie]) {
        shortie = _username;
    }
    return shortie;
}

- (NSString *)name {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

- (NSString *)genderDisplay {
    return [Util genderLabelForValue:self.gender];
}

- (NSString *)reviewerTypeDisplay {
    return [Util reviewerTypeLabelForValue:self.reviewerType];
}

#pragma mark - Empty user check

- (BOOL)isEmpty {
    BOOL isEmpty = [Util isEmpty:self.firstName] && [Util isEmpty:self.lastName]
                    && [Util isEmpty:self.imageURL] && self.image == nil;
    return isEmpty;
}

#pragma mark - Missing required info

- (BOOL)missingRequiredInfo {
    BOOL missingInfo = [Util isEmpty:self.firstName] || [Util isEmpty:self.lastName] || [Util isEmpty:self.email];
    return missingInfo;
}

#pragma mark - isEqual

- (BOOL)isEqualToProfile:(User *)aProfile {
    if (self == aProfile)
        return YES;
    if (![(id)[self username] isEqual:[aProfile username]])
        return NO;
    return YES;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToProfile:other];
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [self.username hash];
    return result;
}

#pragma mark - Description

- (NSString *)description {
    NSString *result = @"";
    
    result = [result stringByAppendingFormat:
              @"\nUsername: %@\n"
              "Email: %@\n"
              "First name: %@\n"
              "Last name: %@\n"
              "Gender: %@\n"
              "Birthday: %@\n"
              "Location: %@\n"
              "Zipcode: %@\n"
              "Type expert: %@\n"
              "Type of Reviewer: %@\n"
              "Favorite food: %@\n"
              "Favorite restaurant: %@\n"
              "Num reviews: %ld\n"
              "Image url: %@\n"
              "Follow url: %@\n"
              "Unfollow url: %@\n"
              "Delegate: %@\n",
              self.username, self.email, self.firstName, self.lastName, self.gender, self.birthday, self.location,
              self.zipcode, self.typeExpert, self.reviewerType, self.favoriteFood, self.favoriteRestaurant,
              (long)self.numReviews, self.imageURL, self.followURL, self.unfollowURL, self.delegate];
    
    result = [result stringByAppendingString:@"\nFollowing:\n"];
    for (User *profile in self.following) {
        result = [result stringByAppendingFormat:@"%@\n", profile.username];
    }
    
    result = [result stringByAppendingString:@"\nFollowers:\n"];
    for (User *profile in self.followers) {
        result = [result stringByAppendingFormat:@"%@\n", profile.username];
    }
    
    result = [result stringByAppendingString:@"\n"];
    
    return result;
}

@end
