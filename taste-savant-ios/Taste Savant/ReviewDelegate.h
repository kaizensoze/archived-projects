//
//  ReviewDelegate.h
//  Taste Savant
//
//  Created by Joe Gallo on 1/27/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Review;

@protocol ReviewDelegate <NSObject>

@property (nonatomic) NSUInteger numReviewsToImport;
@property (nonatomic) NSUInteger numReviewsImported;
- (void)reviewDoneLoading:(Review *)review;

@end
