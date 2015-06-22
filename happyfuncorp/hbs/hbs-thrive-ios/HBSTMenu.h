//
//  HBSTMenu.h
//  HBS Thrive
//
//  Created by Joe Gallo on 8/12/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBSTMenu : NSObject <NSCoding>

@property (nonatomic) int id;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) NSString *body;

- (id)initWithDict:(NSDictionary *)dict;
- (NSString *)displayDate;

@end
