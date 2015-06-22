//
//  ILUCollection.h
//  illuminex
//
//  Created by Joe Gallo on 11/11/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ILUCollection : NSObject <NSCoding>

@property (nonatomic) int id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *items;

- (id)initWithId:(int)id name:(NSString *)name;

@end
