//
//  CriticReview.h
//  Taste Savant
//
//  Created by Joe Gallo on 1/15/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "Review.h"
#import "CriticDelegate.h"

@class Critic;

@interface CriticReview : Review <NSCoding, CriticDelegate>

@property (strong, nonatomic) Critic *critic;
@property (strong, nonatomic) NSString *slug;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSString *site;
@property (strong, nonatomic) NSString *siteRating;
@property (strong, nonatomic) NSString *siteURL;
@property (nonatomic) BOOL includeCritic;

- (id)initWithJSON:(NSDictionary *)json;

@end
