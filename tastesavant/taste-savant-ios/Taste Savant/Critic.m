//
//  Critic.m
//  Taste Savant
//
//  Created by Joe Gallo on 7/5/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "Critic.h"
#import "CriticReview.h"

@interface Critic ()
    @property (strong, nonatomic) NSNumber *includeReviews;
    @property (strong, nonatomic) NSNumber *reviewsPageIndex;
@end

@implementation Critic

@synthesize numReviewsToImport = _numReviewsToImport;
@synthesize numReviewsImported = _numReviewsImported;

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.name = [decoder decodeObjectForKey:@"name"];
        self.slug = [decoder decodeObjectForKey:@"slug"];
        self.summary = [decoder decodeObjectForKey:@"summary"];
        self.webURL = [decoder decodeObjectForKey:@"webURL"];
        self.logoURL = [decoder decodeObjectForKey:@"logoURL"];
        self.logoLargeURL = [decoder decodeObjectForKey:@"logoLargeURL"];
        self.includeReviews = [decoder decodeObjectForKey:@"includeReviews"];
        self.totalReviewCount = [decoder decodeObjectForKey:@"totalReviewCount"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.slug forKey:@"slug"];
    [encoder encodeObject:self.summary forKey:@"summary"];
    [encoder encodeObject:self.webURL forKey:@"webURL"];
    [encoder encodeObject:self.logoURL forKey:@"logoURL"];
    [encoder encodeObject:self.logoLargeURL forKey:@"logoLargeURL"];
    [encoder encodeObject:self.includeReviews forKey:@"includeReviews"];
    [encoder encodeObject:self.totalReviewCount forKey:@"totalReviewCount"];
}

- (void)dealloc {
    self.delegate = nil;
}

- (void)loadFromJSON {
    NSString *url = [NSString stringWithFormat:@"%@/critics/%@", API_URL_PREFIX, self.slug];
    
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"GET" path:url parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        [self import:JSON];
        
        if ([self.includeReviews boolValue]) {
            [self loadReviews];
        } else {
            [self.delegate criticDoneLoading:self];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

- (void)loadFromSlug:(NSString *)slug delegate:(id<CriticDelegate>)delegate {
    [self loadFromSlug:slug includeReviews:@YES delegate:delegate];
}

- (void)loadFromSlug:(NSString *)slug includeReviews:(BOOL)includeReviews delegate:(id<CriticDelegate>)delegate {
    self.slug = slug;
    self.includeReviews = [NSNumber numberWithBool:includeReviews];
    self.reviewsPageIndex = @1;
    self.delegate = delegate;
    
    self.totalReviewCount = @0;
    self.numReviewsToImport = 0;
    self.numReviewsImported = 0;
    
    [self loadFromJSON];
}

- (void)loadReviews {
    if (!self.reviewsPageIndex) {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/critics/%@/reviews/?page=%@",
                     API_URL_PREFIX,
                     self.slug,
                     [self.reviewsPageIndex stringValue]];
    
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"GET" path:url parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        self.totalReviewCount = @([JSON[@"count"] intValue]);
        
        NSArray *results = [JSON objectForKeyNotNull:@"results"];
        
        NSUInteger numReviewsCheck = [results count];
        self.numReviewsToImport += numReviewsCheck;
        
        if (numReviewsCheck == 0) {
            [self.delegate criticDoneLoading:self];
            return;
        }
        
        for (NSDictionary *criticReviewJSON in results) {
            CriticReview *criticReview = [[CriticReview alloc] init];
            criticReview.delegate = self;
            criticReview.includeCritic = NO;
            [criticReview import:criticReviewJSON];
        }
        
        NSString *next = [JSON objectForKeyNotNull:@"next"];
        if (!next) {
            self.reviewsPageIndex = nil;
        } else {
            self.reviewsPageIndex = [NSNumber numberWithInt:[self.reviewsPageIndex intValue] + 1];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

- (void)getNextBatchOfReviews {
    [self loadReviews];
}

- (void)import:(id)json {
    self.name = [json objectForKeyNotNull:@"name"];
    self.slug = [json objectForKeyNotNull:@"slug"];
    self.summary = [json objectForKeyNotNull:@"description"];
    self.webURL = [NSURL URLWithString:[json objectForKeyNotNull:@"url"]];
    self.logoURL = [NSURL URLWithString:[json objectForKeyNotNull:@"logo"]];
    self.logoLargeURL = [NSURL URLWithString:[json objectForKeyNotNull:@"large_logo"]];
}

- (void)reviewDoneLoading:(Review *)review {
    [self.reviews addObject:review];
    self.numReviewsImported++;
    
    if (self.numReviewsImported >= self.numReviewsToImport) {
        [self.reviews sortUsingSelector:@selector(compare:)];
        [self.delegate criticDoneLoading:self];
    }
}

- (NSMutableArray *)reviews {
    if (!_reviews) {
        _reviews = [[NSMutableArray alloc] init];
    }
    return _reviews;
}

- (BOOL)isEqual:(id)other {
    if (self == other) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [self isEqualToCritic:other];
}

- (BOOL)isEqualToCritic:(Critic *)aCritic {
    if (self == aCritic)
        return YES;
    
    if (![(id)[self slug] isEqual:[aCritic slug]])
        return NO;
    
    return YES;
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [self.slug hash];
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n"
            "Name: %@\n"
            "Slug: %@\n"
            "Description: %@\n"
            "Web URL: %@\n"
            "Logo URL: %@\n"
            "Logo large URL: %@\n"
            "Include reviews: %@\n"
            "Reviews page index: %@\n"
            "Reviews: %@\n"
            "Delegate: %@\n"
            , self.name
            , self.slug
            , self.summary
            , self.webURL
            , self.logoURL
            , self.logoLargeURL
            , self.includeReviews
            , self.reviewsPageIndex
            , self.reviews
            , self.delegate
            ];
}

@end
