//
//  Review.m
//  Taste Savant
//
//  Created by Joe Gallo on 11/30/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "Review.h"
#import "Restaurant.h"

@interface Review ()
@end

@implementation Review

- (id)init {
    self = [super init];
    if (self) {
        self.includeRestaurant = YES;
        self.restaurantFinished = NO;
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
}

// Encode.
- (void)encodeWithCoder:(NSCoder *)encoder {
    // Private
    [encoder encodeBool:self.restaurantFinished forKey:@"restaurantFinished"];
    
    // Public
    [encoder encodeInt:self.reviewId forKey:@"reviewId"];
    [encoder encodeObject:self.restaurant forKey:@"restaurant"];
    [encoder encodeObject:self.score forKey:@"score"];
    [encoder encodeObject:self.goodDishes forKey:@"goodDishes"];
    [encoder encodeObject:self.badDishes forKey:@"badDishes"];
    [encoder encodeObject:self.runWalkDitch forKey:@"runWalkDitch"];
    [encoder encodeBool:self.active forKey:@"active"];
    [encoder encodeObject:self.publishDate forKey:@"publishDate"];
    [encoder encodeObject:self.summary forKey:@"summary"];
    [encoder encodeObject:self.delegate forKey:@"delegate"];
    [encoder encodeBool:self.includeRestaurant forKey:@"includeRestaurant"];
}

// Decode.
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        // Private
        self.restaurantFinished = [decoder decodeBoolForKey:@"restaurantFinished"];
        
        // Public
        self.reviewId = [decoder decodeIntForKey:@"reviewId"];
        self.restaurant = [decoder decodeObjectForKey:@"restaurant"];
        self.score = [decoder decodeObjectForKey:@"score"];
        self.goodDishes = [decoder decodeObjectForKey:@"goodDishes"];
        self.badDishes = [decoder decodeObjectForKey:@"badDishes"];
        self.runWalkDitch = [decoder decodeObjectForKey:@"runWalkDitch"];
        self.active = [decoder decodeBoolForKey:@"active"];
        self.publishDate = [decoder decodeObjectForKey:@"publishDate"];
        self.summary = [decoder decodeObjectForKey:@"summary"];
        self.delegate = [decoder decodeObjectForKey:@"delegate"];
        self.includeRestaurant = [decoder decodeBoolForKey:@"includeRestaurant"];
    }
    return self;
}

- (void)import:(NSDictionary *)json {
    [self import:json restaurantDelegate:nil];
}

- (void)import:(NSDictionary *)json restaurantDelegate:(id<RestaurantDelegate>)delegate {
    self.reviewId = [[json objectForKeyNotNull:@"id"] intValue];
    self.score = [json objectForKeyNotNull:@"score"];
    self.goodDishes = [json objectForKeyNotNull:@"good_dishes"];
    self.badDishes = [json objectForKeyNotNull:@"bad_dishes"];
    self.runWalkDitch = [json objectForKeyNotNull:@"rwd"];
    self.active = [[json objectForKeyNotNull:@"active"] boolValue];
    
    NSString *created = [json objectForKeyNotNull:@"created"];
    NSString *published = [json objectForKeyNotNull:@"published"];
    
    if (published) {
        self.publishDate = [Util stringToDate:published dateFormat:@"yyyy-MM-dd"];
    } else {
        self.publishDate = [Util stringToDate:created dateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    }
    
    self.summary = [json objectForKeyNotNull:@"summary"];
    
    if (self.includeRestaurant) {
        NSString *restaurantURL = [json objectForKeyNotNull:@"restaurant"];
        
        Restaurant *restaurant =[[Restaurant alloc] init];
        restaurant.includeReviews = NO;
        restaurant.delegate = delegate;
        [restaurant loadFromURL:restaurantURL];
    } else {
        if (delegate) {
            [delegate restaurantDoneLoading:nil];
        }
    }
}

- (void)setRunWalkDitchValue {
    self.runWalkDitch = [Util runWalkDitch:self.score];
}

- (void)restaurantDoneLoading:(Restaurant *)restaurant {
    self.restaurant = restaurant;
    self.restaurantFinished = YES;
}

- (BOOL)okToSignal {
    BOOL okToSignal = YES;
    
    if (self.includeRestaurant) {
        okToSignal &= self.restaurantFinished;
    }
    
    return okToSignal;
}

- (void)resetFinishedFlags {
    self.restaurantFinished = NO;
}

- (NSNumber *)score {
    return _score;
}

- (NSString *)reviewerName {
    return @"";
}

- (NSString *)reviewText {
    return self.summary;
}

- (NSComparisonResult)compare:(Review *)aReview {
    return [self.publishDate compare:aReview.publishDate] * -1;
}

- (BOOL)isEqualToReview:(Review *)aReview {
    if (self == aReview)
        return YES;
    if (![(id)[NSNumber numberWithInt:[self reviewId]] isEqual:[NSNumber numberWithInt:[aReview reviewId]]])
        return NO;
    return YES;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToReview:other];
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [[NSNumber numberWithInt:self.reviewId] hash];
    return result;
}

- (NSString *)description {
    return [NSString stringWithFormat:
           @"\nReview id: %d\n"
            "Restaurant: %@\n"
            "Score: %@\n"
            "Good dishes: %@\n"
            "Bad dishes: %@\n"
            "RunWalkDitch: %@\n"
            "Publish date: %@\n"
            "Active: %d\n"
            "Summary: %@\n"
            "Include restaurant: %d\n",
            self.reviewId, self.restaurant.name, self.score, self.goodDishes, self.badDishes, self.runWalkDitch,
            self.publishDate, self.active, self.summary, self.includeRestaurant];
}

@end
