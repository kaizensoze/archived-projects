//
//  Prompt.h
//  AwasuPromptr
//
//  Created by Joe Gallo on 7/1/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Conference;

@interface Prompt : NSObject <NSCoding>

@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) Conference *conference;
@property (nonatomic) PromptType type;
@property (strong, nonatomic) NSString *detail;
@property (strong, nonatomic) NSString *shortDetail;
@property (strong, nonatomic) NSNumber *numDaysLeft;

- (id)initWithId:(NSString *)id;

@end
