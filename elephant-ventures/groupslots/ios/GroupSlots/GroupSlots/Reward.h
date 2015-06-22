//
//  Reward.h
//  GroupSlots
//
//  Created by Joe Gallo on 5/7/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Reward : NSObject <NSCoding>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *category;
@property (nonatomic) int points;
@property (strong, nonatomic) NSString *details;
@property (strong, nonatomic) NSString *terms;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *testImagePath;
@property (strong, nonatomic) NSString *redemptionCode;

- (id)initWithName:(NSString *)name category:(NSString *)category points:(int)points;
- (NSString *)formattedPoints;

@end
