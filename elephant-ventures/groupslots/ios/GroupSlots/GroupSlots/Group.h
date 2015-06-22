//
//  Group.h
//  GroupSlots
//
//  Created by Joe Gallo on 5/28/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@interface Group : NSObject <NSCoding>

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *members;

- (id)initWithId:(NSNumber *)id;
- (id)initWithName:(NSString *)name;
- (id)initWithId:(NSNumber *)id name:(NSString *)name;
- (BOOL)hasUser:(User *)user;

@end
