//
//  Note.h
//  AwasuPromptr
//
//  Created by Joe Gallo on 7/1/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Conference;

@interface Note : NSObject <NSCoding>

@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) Conference *conference;
@property (strong, nonatomic) NSString *content;

- (id)initWithId:(NSString *)id;

@end
