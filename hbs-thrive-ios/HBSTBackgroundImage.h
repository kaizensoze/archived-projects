//
//  HBSTBackgroundImage.h
//  HBS Thrive
//
//  Created by Joe Gallo on 8/12/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBSTBackgroundImage : NSObject <NSCoding>

@property (nonatomic) int id;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) UIImage *image;
@property (nonatomic) BOOL active;

- (id)initWithDict:(NSDictionary *)dict;

@end
