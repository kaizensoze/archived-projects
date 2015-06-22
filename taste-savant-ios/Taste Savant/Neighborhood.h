//
//  Neighborhood.h
//  Taste Savant
//
//  Created by Joe Gallo on 2/18/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Neighborhood : NSObject <NSCoding, NSCopying>

@property (nonatomic) int id;
@property (strong, nonatomic) NSString *name;
@property (nonatomic) int parentId;
@property (strong, nonatomic) NSString *parentName;
@property (strong, nonatomic) NSString *borough;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSArray *children;

- (id)initWithId:(int)id name:(NSString *)name;
- (id)initWithId:(int)id name:(NSString *)name parentName:(NSString *)parentName;
- (id)initWithDict:(NSDictionary *)dict;
+ (Neighborhood *)currentLocation;

@end
