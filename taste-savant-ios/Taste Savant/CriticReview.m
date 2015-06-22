//
//  CriticReview.m
//  Taste Savant
//
//  Created by Joe Gallo on 1/15/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "CriticReview.h"
#import "Critic.h"

@interface CriticReview ()
    @property (nonatomic) BOOL criticFinished;
@end

@implementation CriticReview

- (id)init {
    self = [super init];
    if (self) {
        self.includeCritic = YES;
        self.criticFinished = NO;
    }
    return self;
}

- (id)initWithJSON:(NSDictionary *)json {
    self = [super init];
    if (self) {
        [self import:json];
    }
    return self;
}

// Encode.
- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    // private
    [encoder encodeBool:self.criticFinished forKey:@"criticFinished"];
    
    // public
    [encoder encodeObject:self.critic forKey:@"critic"];
    [encoder encodeObject:self.slug forKey:@"slug"];
    [encoder encodeObject:self.author forKey:@"author"];
    [encoder encodeObject:self.site forKey:@"site"];
    [encoder encodeObject:self.siteRating forKey:@"siteRating"];
    [encoder encodeObject:self.siteURL forKey:@"siteURL"];
}

// Decode.
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        // private
        self.criticFinished = [decoder decodeBoolForKey:@"criticFinished"];
        
        // public
        self.critic = [decoder decodeObjectForKey:@"critic"];
        self.slug = [decoder decodeObjectForKey:@"slug"];
        self.author = [decoder decodeObjectForKey:@"author"];
        self.site = [decoder decodeObjectForKey:@"site"];
        self.siteRating = [decoder decodeObjectForKey:@"siteRating"];
        self.siteURL = [decoder decodeObjectForKey:@"siteURL"];
    }
    return self;
}

- (void)import:(NSDictionary *)json {
    [super import:json restaurantDelegate:self];
    
    self.slug = [json objectForKeyNotNull:@"critic_slug"];
    self.author = [json objectForKeyNotNull:@"author"];
    self.site = [json objectForKeyNotNull:@"site"];
    self.siteRating = [json objectForKeyNotNull:@"siteRating"];
    self.siteURL = [json objectForKeyNotNull:@"siteURL"];
    
    if (self.includeCritic) {
        Critic *critic = [[Critic alloc] init];
        [critic loadFromSlug:self.slug includeReviews:NO delegate:self];
    } else {
        [self signalDelegate];
    }
}

- (void)criticDoneLoading:(Critic *)critic {
    self.critic = critic;
    self.criticFinished = YES;
    [self signalDelegate];
}

- (void)restaurantDoneLoading:(Restaurant *)restaurant {
    [super restaurantDoneLoading:restaurant];
    [self signalDelegate];
}

- (BOOL)okToSignal {
    BOOL okToSignal = [super okToSignal];
    
    if (self.includeCritic) {
        okToSignal &= self.criticFinished;
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
    self.criticFinished = NO;
}

- (NSNumber *)score {
    return super.score;
}

- (NSString *)reviewerName {
    return self.site;
}

- (NSString *)reviewText {
    return self.summary;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"%@"
            "Slug: %@\n"
            "Author: %@\n"
            "Site: %@\n"
            "Site rating: %@\n"
            "Site url: %@\n",
            [super description], self.slug, self.author, self.site, self.siteRating, self.siteURL];
}

- (BOOL)isEqual:(id)other {
    return [super isEqual:other];
}

- (NSUInteger)hash {
    return [super hash];
}

@end
