//
//  HBSTWhoToCallItem.h
//  HBS Thrive
//
//  Created by Joe Gallo on 8/28/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBSTWhoToCallItem : NSObject <NSCopying>

@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *email;

- (id)initWithDict:(NSDictionary *)dict;

@end
