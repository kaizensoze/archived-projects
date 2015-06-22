//
//  HBSTHelpNowItem.h
//  HBS Thrive
//
//  Created by Joe Gallo on 8/28/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBSTHelpNowItem : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSString *phoneNumber;

- (id)initWithDict:(NSDictionary *)dict;

@end
