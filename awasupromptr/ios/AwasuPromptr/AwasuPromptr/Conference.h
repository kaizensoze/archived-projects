//
//  Conference.h
//  AwasuPromptr
//
//  Created by Joe Gallo on 7/1/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Conference : NSObject <NSCoding>

@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *stateAbbrev;
@property (strong, nonatomic) NSString *details;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSURL *webURL;
@property (strong, nonatomic) NSMutableArray *prompts;

- (id)initWithId:(NSString *)id;
- (NSString *)startDateString;
- (NSString *)startDateShortString;
- (NSString *)endDateString;
- (NSString *)dateRangeString;
- (NSString *)locationString;

@end
