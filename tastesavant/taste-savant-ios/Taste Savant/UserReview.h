//
//  UserReview.h
//  Taste Savant
//
//  Created by Joe Gallo on 1/15/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "Review.h"

@class User;

@interface UserReview : Review <NSCoding, ProfileDelegate>

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSMutableArray *moreTips;
@property (nonatomic) int foodScore;
@property (nonatomic) int ambienceScore;
@property (nonatomic) int serviceScore;
@property (nonatomic) int overallScore;
@property (strong, nonatomic) NSString *body;
@property (nonatomic) BOOL includeUser;

@end
