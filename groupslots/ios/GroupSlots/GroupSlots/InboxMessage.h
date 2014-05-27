//
//  InboxMessage.h
//  GroupSlots
//
//  Created by Joe Gallo on 6/11/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InboxMessage : NSObject


@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *iconPath;

- (id)initWithMessage:(NSString *)message iconPath:(NSString *)iconPath;

@end
