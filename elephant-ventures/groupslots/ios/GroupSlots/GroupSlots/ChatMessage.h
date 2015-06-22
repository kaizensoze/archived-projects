//
//  ChatMessage.h
//  GroupSlots
//
//  Created by Joe Gallo on 5/3/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatMessage : NSObject

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSDate *timeCreated;

- (id)initWithUser:(User *)user message:(NSString *)message;

@end
