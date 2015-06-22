//
//  UIImage+Utility.h
//  Mosaic
//
//  Created by Joe Gallo on 11/8/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utility)

- (UIImage *)cropFromRect:(CGRect)fromRect;
- (UIColor *)averageColor;
- (float)percentageDark;

@end
