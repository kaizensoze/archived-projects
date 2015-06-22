//
//  BFKCustomStyler.h
//  Mosaic
//
//  Created by Joe Gallo on 10/22/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#ifndef Mosaic_BFKCustomStyler_h
#define Mosaic_BFKCustomStyler_h

#import <UIKit/UIKit.h>

@interface BFKCustomStyler : NSObject

+ (void)styleButton:(UIButton *)button;
+ (void)adjustButton:(UIButton *)button;

+ (void)setTextFieldHeight:(UITextField *)textField height:(float)height;

@end

#endif
