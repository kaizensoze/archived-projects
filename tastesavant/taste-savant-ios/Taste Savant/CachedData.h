//
//  CachedData.h
//  Taste Savant
//
//  Created by Joe Gallo on 1/23/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CachedData : NSObject

@property (strong, nonatomic) NSDictionary *supportedCities;
@property (strong, nonatomic) NSString *nearestCity;

@property (strong, nonatomic) NSDictionary *neighborhoodData;
@property (strong, nonatomic) NSDictionary *priceData;
@property (strong, nonatomic) NSArray *cuisines;
@property (strong, nonatomic) NSArray *occasions;
@property (strong, nonatomic) NSArray *brooklynNeighborhoods;

- (void)loadSupportedCities;

@end
