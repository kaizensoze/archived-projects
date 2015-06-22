//
//  HBSTDidYouKnowItem.h
//  HBS Thrive
//
//  Created by Joe Gallo on 8/28/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBSTDidYouKnowItem : NSObject <NSCopying>

@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *website;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phoneNumber;

- (id)initWithDict:(NSDictionary *)dict;

@end
