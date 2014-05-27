//
//  ActivityEvent.h
//  GroupSlots
//
//  Created by Joe Gallo on 5/21/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityLogEvent : NSObject <NSCoding>

@property (strong, nonatomic) NSDate *timestamp;
@property (strong, nonatomic) NSString *eventDescription;

- (id)initWithDescription:(NSString *)description;
- (NSString *)formattedTimestamp;

@end
