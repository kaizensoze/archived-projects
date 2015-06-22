//
//  Price.h
//  Taste Savant
//
//  Created by Joe Gallo on 6/2/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Price : NSObject <NSCoding>

@property (nonatomic) int id;
@property (strong, nonatomic) NSString *name;

- (id)initWithName:(NSString *)name;

@end
