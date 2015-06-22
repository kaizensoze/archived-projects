//
//  UserReview.m
//  Taste Savant
//
//  Created by Joe Gallo on 1/15/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "UserReview.h"
#import "User.h"

@interface UserReview ()
    @property (nonatomic) BOOL userFinished;
@end

@implementation UserReview

- (id)init {
    self = [super init];
    if (self) {
        self.includeUser = YES;
        self.userFinished = NO;
    }
    return self;
}

// Encode.
- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    // Private
    [encoder encodeBool:self.userFinished forKey:@"userFinished"];
    
    // Public
    [encoder encodeObject:self.user forKey:@"user"];
    [encoder encodeObject:self.moreTips forKey:@"moreTips"];
    [encoder encodeInt:self.foodScore forKey:@"foodScore"];
    [encoder encodeInt:self.ambienceScore forKey:@"ambienceScore"];
    [encoder encodeInt:self.serviceScore forKey:@"serviceScore"];
    [encoder encodeInt:self.overallScore forKey:@"overallScore"];
    [encoder encodeObject:self.body forKey:@"body"];
}

// Decode.
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        // Private
        self.userFinished = [decoder decodeBoolForKey:@"userFinished"];
        
        // Public
        self.user = [decoder decodeObjectForKey:@"user"];
        self.moreTips = [decoder decodeObjectForKey:@"moreTips"];
        self.foodScore = [decoder decodeIntForKey:@"foodScore"];
        self.ambienceScore = [decoder decodeIntForKey:@"ambienceScore"];
        self.serviceScore = [decoder decodeIntForKey:@"serviceScore"];
        self.overallScore = [decoder decodeIntForKey:@"overallScore"];
        self.body = [decoder decodeObjectForKey:@"body"];
    }
    return self;
}

- (void)import:(NSDictionary *)json {
    [super import:json restaurantDelegate:self];
    self.moreTips = [json objectForKeyNotNull:@"more_tips"];
    self.foodScore = [[json objectForKeyNotNull:@"food_score"] intValue];
    self.ambienceScore = [[json objectForKeyNotNull:@"ambience_score"] intValue];
    self.serviceScore = [[json objectForKeyNotNull:@"service_score"] intValue];
    self.overallScore = [[json objectForKeyNotNull:@"overall_score"] intValue];
    self.body = [json objectForKeyNotNull:@"body"];
    
    if (self.includeUser) {
        NSString *userURL = [json objectForKeyNotNull:@"user"];
        
        User *user =[[User alloc] init];
        user.includeFollowingFollowers = NO;
        user.includeReviews = NO;
        user.delegate = self;
        [user loadFromURL:userURL];
    } else {
        [self signalDelegate];
    }
}

- (void)profileDoneLoading:(User *)profile {
    self.user = profile;
    self.userFinished = YES;
    [self signalDelegate];
}

- (void)restaurantDoneLoading:(Restaurant *)restaurant {
    [super restaurantDoneLoading:restaurant];
    [self signalDelegate];
}

- (BOOL)okToSignal {
    BOOL okToSignal = [super okToSignal];
    
    if (self.includeUser) {
        okToSignal &= self.userFinished;
    }
    
    return okToSignal;
}

- (void)signalDelegate {
    if ([self okToSignal] && self.delegate) {
        [self resetFinishedFlags];
        [self.delegate reviewDoneLoading:self];
    }
}

- (void)resetFinishedFlags {
    [super resetFinishedFlags];
    self.userFinished = NO;
}

- (NSNumber *)score {
    return [NSNumber numberWithFloat:self.overallScore];
}

- (NSString *)reviewerName {
    return self.user.shortName;
}

- (NSString *)reviewText {
    return self.body;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"%@"
            "More tips: %@\n"
            "Food score: %d\n"
            "Ambience score: %d\n"
            "Service score: %d\n"
            "Overall score: %d\n"
            "Body: %@\n"
            "Include user: %d\n",
            [super description], self.moreTips, self.foodScore, self.ambienceScore, self.serviceScore,
            self.overallScore, self.body, self.includeUser];
}

- (BOOL)isEqual:(id)other {
    return [super isEqual:other];
}

- (NSUInteger)hash {
    return [super hash];
}

@end
