//
//  Occasion.h
//  Taste Savant
//
//  Created by Joe Gallo on 2/18/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Occasion : NSObject <NSCoding>

@property (nonatomic) int id;
@property (strong, nonatomic) NSString *name;

- (id)initWithDict:(NSDictionary *)dict;

@end
