//
//  Critic.h
//  Taste Savant
//
//  Created by Joe Gallo on 7/5/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CriticDelegate.h"
#import "ReviewDelegate.h"

@interface Critic : NSObject <NSCoding, ReviewDelegate>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *slug;
@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) NSURL *webURL;
@property (strong, nonatomic) NSURL *logoURL;
@property (strong, nonatomic) NSURL *logoLargeURL;
@property (strong, nonatomic) NSMutableArray *reviews;
@property (strong, nonatomic) NSNumber *totalReviewCount;
@property id<CriticDelegate> delegate;

- (void)loadFromSlug:(NSString *)slug delegate:(id<CriticDelegate>)delegate;
- (void)loadFromSlug:(NSString *)slug includeReviews:(BOOL)includeReviews delegate:(id<CriticDelegate>)delegate;

- (void)getNextBatchOfReviews;

@end
