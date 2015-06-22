//
//  User.h
//  AwasuPromptr
//
//  Created by Joe Gallo on 7/1/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject <NSCoding>

@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSMutableArray *favorites;
@property (strong, nonatomic) NSMutableArray *prompts;
@property (strong, nonatomic) NSMutableArray *notes;

- (id)initWithId:(NSString *)id;

@end
