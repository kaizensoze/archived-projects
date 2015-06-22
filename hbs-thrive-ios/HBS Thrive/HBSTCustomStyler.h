//
//  HBSTCustomStyler.h
//  HBS Thrive
//
//  Created by Joe Gallo on 8/21/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBSTCustomStyler : NSObject

+ (void)styleButton:(UIButton *)button;

+ (void)styleTextField:(UITextField *)textField;

+ (void)roundCorners:(UIView *)view radius:(float)radius;

@end
